// ---------------------------------------------------------------------
// COPYRIGHT (C) 2024 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
// ---------------------------------------------------------------------

// This file implements a client-server protocol for remote direct memory
// access. The server is a program that can read/write the target memory
// bypassing the core. The client is usually a debugger that wants to speed up
// memory access.
//
// This file is split into 4 sections:
//   - [Helpers] - Variuous functions and classes mostly related to TCP socket
//                 communications.
//   - [Protocol] - Defines all data structures sent/received via sockets.
//   - [Server] - DMAServer class which is supposed to be inherited by the
//                server.
//   - [Client] - DMAClient final class which is supposed to be used by a
//                debugger.
//
//  Search for the section names in this file to get more info.

#ifndef REMOTE_DMA_HPP
#define REMOTE_DMA_HPP

#include <atomic>
#include <chrono>
#include <cstdint>
#include <sstream>
#include <string>
#include <vector>

#ifdef _WIN32

#define ULONG WIN_ULONG
#include <winsock2.h>
#include <ws2tcpip.h>
#undef ULONG

#else

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#endif

namespace rdma {

// [Helpers]
// The purpose of this section is to implement 2 classes:
// - SocketIO - The main communication channel used by both the client and
//              the server.
// - ServerSocket - The class supposed to be used by the server to accept
//                  client connections.
//
// Here is an example of usage:
// <Server>
//    std::atomic_bool keep_processing = true;
//
//    rdma::ServerSocket server(INADDR_LOOPBACK, 12345);
//
//    auto error = server.Open();
//    if (!error.empty()) {
//      // Handle the error.
//    }
//
//    auto io = server.Accept(keep_processing);
//    error = io.GetInitError();
//    if (!error.empty()) {
//      // Handle the error.
//    }
//
// <Client>
//
//    auto io = rdma::SocketIO::Connect(INADDR_LOOPBACK, 12345);
//    auto error = io.GetInitError();
//    if (!error.empty()) {
//      // Handle the error.
//    }
//
//
// After you get a SocketIO instance, you can use
// Read/Write/ReadBuffer/WriteBuffer functions to send/receive the data.
// Note that:
//   - Write and WriteBuffer functions do not send the data immediately!
//     They only add the data to a temporary buffer.
//     You need to invoke Flush function after the packet is fully formed
//     to clear the buffer and send it over the socket.
//   - Accept, Read and ReadBuffer functions require a parameter of type
//     "atomic_bool &". This parameter serves as a cancellation token.
//     While its value is "true", the function keeps waiting for incoming data.
//     As soon as its value is changed to "false", the function exits.
//     Use this parameter to terminate the server's loop at the end of
//     the program or to interrupt a client's request if it takes too long
//     to process.

const static auto DMA_TIMEOUT = std::chrono::milliseconds(500);

#ifndef _WIN32
using SOCKET = int;
const static SOCKET INVALID_SOCKET = -1;

static auto closesocket = [](SOCKET socket) { return ::close(socket); };
#endif

template <class... Args> std::string ToString(Args &&...args) {
  std::stringstream ss;
  int unused[sizeof...(args)] = {((ss << std::forward<Args>(args)), 0)...};

  if (sizeof(unused) / sizeof(int) != sizeof...(args))
    ss << "This is here just to disable the compiler warning about unused "
          "variable";

  return ss.str();
}

/// Invokes the specified function at the end of the scope.
template <class F> struct ScopeGuard final {
  bool m_active = true;
  F m_on_return;

  ScopeGuard(F &&on_return) : m_on_return(on_return) {}

  ~ScopeGuard() {
    if (m_active)
      m_on_return();
  }

  void Release() { m_active = false; }
};

template <class G> static ScopeGuard<G> MakeScopeGuard(G &&on_return) {
  return ScopeGuard<G>(std::forward<G>(on_return));
}

class SocketIO final {
public:
  static SocketIO Connect(uint32_t ip, uint16_t port) {
    auto new_socket = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (INVALID_SOCKET == new_socket)
      return SocketIO(ToString("socket syscall returned ", new_socket));

    auto socket_guard =
        MakeScopeGuard([&new_socket]() { closesocket(new_socket); });

    sockaddr_in serv_addr{};
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(ip);
    serv_addr.sin_port = htons(port);

    auto status =
        ::connect(new_socket, reinterpret_cast<sockaddr *>(&serv_addr),
                  sizeof(serv_addr));
    if (status < 0)
      return SocketIO(
          ToString("Failed to connect socket: return code ", status));

#ifdef _WIN32
    DWORD timeout_ms =
        std::chrono::duration_cast<std::chrono::milliseconds>(DMA_TIMEOUT)
            .count();
    setsockopt(new_socket, SOL_SOCKET, SO_RCVTIMEO,
               reinterpret_cast<const char *>(&timeout_ms), sizeof(timeout_ms));
#else
    timeval timeout{};
    timeout.tv_sec = 0;
    timeout.tv_usec =
        std::chrono::duration_cast<std::chrono::microseconds>(DMA_TIMEOUT)
            .count();
    setsockopt(new_socket, SOL_SOCKET, SO_RCVTIMEO,
               reinterpret_cast<const char *>(&timeout), sizeof(timeout));
#endif

    socket_guard.Release();
    return SocketIO(new_socket);
  }

  explicit SocketIO(std::string &&error) : m_init_error(std::move(error)) {}

  explicit SocketIO(SOCKET socket) : m_socket(socket) {}

  SocketIO(SocketIO &&io)
      : m_init_error(std::move(io.m_init_error)), m_socket(io.m_socket) {
    io.m_socket = INVALID_SOCKET;
  }

  std::string GetInitError() { return m_init_error; }

  ~SocketIO() { Close(); }

  void Close() {
    if (m_socket != INVALID_SOCKET)
      closesocket(m_socket);

    m_socket = INVALID_SOCKET;
  }

  std::string ReadBuffer(std::atomic_bool &keep_reading, uint8_t *output,
                         size_t to_read) {
    if (!m_init_error.empty())
      return ToString("Socket IO was not initialized: ", m_init_error);

    uint8_t *cursor = output;
    while (keep_reading.load()) {
#ifdef _WIN32
      auto received =
          ::recv(m_socket, reinterpret_cast<char *>(cursor), to_read, 0);
#else
      auto received = ::recv(m_socket, cursor, to_read, 0);
#endif

      if (received < 0) {
        bool by_timeout = false;

#ifdef _WIN32
        auto error_code = WSAGetLastError();
        by_timeout = WSAETIMEDOUT == error_code || WSAEWOULDBLOCK == error_code;
#else
        auto error_code = errno;
        by_timeout = EAGAIN == error_code || EWOULDBLOCK == error_code;
#endif

        if (by_timeout)
          continue;

        return ToString("recv returned ", received,
                        ", error code: ", error_code);
      }

      to_read -= received;
      cursor += received;

      if (0 == to_read)
        return "";
    }

    return "Cancelled";
  }

  void WriteBuffer(const uint8_t *data, size_t to_write) {
    m_send_buffer.insert(m_send_buffer.end(), data, data + to_write);
  }

  std::string Flush() {
    size_t written = 0;
    while (written < m_send_buffer.size()) {
#ifdef _WIN32
      auto written_this_time =
          ::send(m_socket,
                 reinterpret_cast<const char *>(m_send_buffer.data() + written),
                 m_send_buffer.size() - written, 0);
#else
      auto written_this_time = ::send(m_socket, m_send_buffer.data() + written,
                                      m_send_buffer.size() - written, 0);
#endif
      if (written_this_time < 0)
        return ToString("Failed to send ", m_send_buffer.size(),
                        " bytes, already sent ", written, ", send returned ",
                        written_this_time);

      written += written_this_time;
    }

    m_send_buffer.clear();

    return "";
  }

  template <class T>
  std::string Read(std::atomic_bool &keep_reading, T &dest,
                   size_t size = sizeof(T)) {
    if (sizeof(T) < size)
      return ToString("The destination size (", sizeof(T),
                      ") is less than the requested size (", size, ")");

    return ReadBuffer(keep_reading, reinterpret_cast<uint8_t *>(&dest), size);
  }

  template <class T> void Write(const T &dest, size_t size = sizeof(T)) {
    WriteBuffer(reinterpret_cast<const uint8_t *>(&dest), size);
  }

private:
  std::string m_init_error = "";
  std::vector<uint8_t> m_send_buffer;
  SOCKET m_socket = INVALID_SOCKET;
};

class ServerSocket final {
public:
  ServerSocket(uint32_t ip, uint16_t port) : m_ip(ip), m_port(port) {}

  ~ServerSocket() { Close(); }

  ServerSocket(ServerSocket &&server_socket)
      : m_socket(server_socket.m_socket) {
    server_socket.m_socket = INVALID_SOCKET;
  }

  void Close() {
    if (m_socket != INVALID_SOCKET)
      closesocket(m_socket);

    m_socket = INVALID_SOCKET;
  }

  std::string Open() {
    auto new_socket = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (INVALID_SOCKET == new_socket)
      return ToString("socket syscall returned ", new_socket);

    auto socket_guard =
        MakeScopeGuard([&new_socket]() { closesocket(new_socket); });

    sockaddr_in serv_addr{};
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(m_ip);
    serv_addr.sin_port = htons(m_port);

    auto status = ::bind(new_socket, reinterpret_cast<sockaddr *>(&serv_addr),
                         sizeof(serv_addr));
    if (status < 0)
      return ToString("Failed to bind socket: return code ", status);

    status = ::listen(new_socket, 1);
    if (status < 0)
      return ToString("Failed to listen socket: return code ", status);

    socket_guard.Release();
    m_socket = new_socket;
    return "";
  }

  SocketIO Accept(std::atomic_bool &keep_waiting) {
    SOCKET new_socket = INVALID_SOCKET;
    while (INVALID_SOCKET == new_socket) {
      if (!keep_waiting.load())
        return SocketIO("Cancelled");

      fd_set fds;
      FD_ZERO(&fds);
      FD_SET(m_socket, &fds);

      timeval timeout{};
      timeout.tv_sec = 0;
      timeout.tv_usec =
          std::chrono::duration_cast<std::chrono::microseconds>(DMA_TIMEOUT)
              .count();

      auto can_accept = select(m_socket + 1, &fds, nullptr, nullptr, &timeout);
      if (can_accept <= 0)
        continue;

      new_socket = ::accept(m_socket, nullptr, nullptr);
      if (INVALID_SOCKET == new_socket)
        return SocketIO("Failed to accept incoming socket connection");
    }

#ifdef _WIN32
    DWORD timeout_ms =
        std::chrono::duration_cast<std::chrono::milliseconds>(DMA_TIMEOUT)
            .count();
    setsockopt(new_socket, SOL_SOCKET, SO_RCVTIMEO,
               reinterpret_cast<const char *>(&timeout_ms), sizeof(timeout_ms));
#else
    timeval timeout{};
    timeout.tv_sec = 0;
    timeout.tv_usec =
        std::chrono::duration_cast<std::chrono::microseconds>(DMA_TIMEOUT)
            .count();
    setsockopt(new_socket, SOL_SOCKET, SO_RCVTIMEO,
               reinterpret_cast<const char *>(&timeout), sizeof(timeout));
#endif

    return SocketIO(new_socket);
  }

private:
  uint32_t m_ip;
  uint16_t m_port;
  SOCKET m_socket = INVALID_SOCKET;
};

// [Protocol]
//
// Immediately after connection:
//   1. The server and the client both send their versions (4 bytes).
//   2. The server and the client both receive the other side's version.
//
// After that, the server waits until the client initiates the transaction.
// To initiate the transaction, the client sends a packet in the following form:
//
// | opcode | total length of the arguments in bytes | arguments |
// | 1 byte |                4 bytes                 |    ...    |
//
// The server must respond in the following form:
//
// | recognized | response |
// |   1 byte   |   ...    |
//
// Where "recognized" is a non-zero number if the opcode is known to the server
// and is zero if the opcode is unknown. If "recognized" is 0, the response
// must be empty.
//
// Operations of version 1 of the protocol:
//
// [Read Memory]
// opcode = 1
// arguments = | address |  size   |
//             | 8 bytes | 8 bytes |
//
// response =  | the number of bytes that were actually read | the bytes that
// were read |
//             |                   8 bytes                   |    <num of read
//             bytes>   |
//
// [Write Memory]
// opcode = 2
// arguments = | address |  size   | the bytes to write |
//             | 8 bytes | 8 bytes |    <size> bytes    |
//
// response =  | the number of bytes that were actually written |
//             |                   8 bytes                      |
//

const static uint32_t DMA_REMOTE_VERSION = 1;

const static size_t VERSION_LENGTH = 4;
const static size_t OPCODE_LENGTH = 1;
const static size_t TOTAL_ARG_SIZE_LENGTH = 4;
const static size_t RECOGNIZED_LENGTH = 1;

#pragma pack(push, 1)

struct ReadMemoryReq {
  enum { ID = 1 };

  uint64_t address;
  uint64_t size;

  struct Out {
    uint64_t read;
    // Blob.
  };
};

struct WriteMemoryReq {
  enum { ID = 2 };

  uint64_t address;
  uint64_t size;

  // Blob.

  struct Out {
    uint64_t written;
  };
};

#pragma pack(pop)

// [Server]
// The real server must inherit this class and override all virtual functions.
// The server can be created using an already established SocketIO connection.
// After an instance is created, execute StartLoop function. This function
// starts listening for incoming requests.
//
// As soon as a recognized incoming request is received, DMAServer unpacks its
// arguments and invokes the corresponding virtual function.

class DMAServer {
public:
  DMAServer(SocketIO &&io) : m_io(std::move(io)) {}

  virtual size_t ReadMemory(uint64_t address, uint8_t *buffer, size_t size) = 0;

  virtual size_t WriteMemory(uint64_t address, const uint8_t *buffer,
                             size_t size) = 0;

  std::string StartLoop(std::atomic_bool &keep_running) {
    auto ignore_if_cancelled = [&keep_running](std::string &&message) {
      return keep_running.load() ? std::move(message) : "";
    };

    m_io.Write(DMA_REMOTE_VERSION, VERSION_LENGTH);
    auto error = m_io.Flush();
    if (!error.empty())
      return ToString("Failed to send the DMA server version to the client: ",
                      error);

    error = m_io.Read(keep_running, m_client_version, VERSION_LENGTH);
    if (!error.empty())
      return ToString("Failed to read the DMA client version: ", error);

    while (keep_running.load()) {
      uint32_t opcode = 0;
      error = m_io.Read(keep_running, opcode, OPCODE_LENGTH);
      if (!error.empty())
        return ignore_if_cancelled(
            ToString("Failed to read the opcode: ", error));

      uint64_t total_arg_size = 0;
      error = m_io.Read(keep_running, total_arg_size, TOTAL_ARG_SIZE_LENGTH);
      if (!error.empty())
        return ignore_if_cancelled(
            ToString("Failed to read the total size of the request: ", error));

      error = HandleRequest(keep_running, opcode, total_arg_size);
      if (!error.empty())
        return ignore_if_cancelled(ToString(
            "Failed to handle the remote DMA request with opcode=", opcode,
            ": ", error));
    }

    return "";
  }

  std::string HandleRequest(std::atomic_bool &keep_running, uint32_t opcode,
                            uint64_t total_arg_size) {
    std::string error;
    switch (opcode) {
    case ReadMemoryReq::ID: {
      m_io.Write(1, RECOGNIZED_LENGTH);

      ReadMemoryReq rm_req;
      ReadMemoryReq::Out rm_resp;

      error = m_io.Read(keep_running, rm_req);
      if (!error.empty())
        return ToString("Failed to read the args of read memory request: ",
                        error);

      m_buffer.reserve(rm_req.size);
      rm_resp.read = ReadMemory(rm_req.address, m_buffer.data(), rm_req.size);

      m_io.Write(rm_resp);
      m_io.WriteBuffer(m_buffer.data(), rm_resp.read);

      error = m_io.Flush();
      if (!error.empty())
        return ToString("Failed to write the write memory response: ", error);
    } break;

    case WriteMemoryReq::ID: {
      m_io.Write(1, RECOGNIZED_LENGTH);

      WriteMemoryReq wm_req;
      WriteMemoryReq::Out wm_resp;

      error = m_io.Read(keep_running, wm_req);
      if (!error.empty())
        return ToString("Failed to read the args of write memory request: ",
                        error);

      m_buffer.reserve(wm_req.size);
      error = m_io.ReadBuffer(keep_running, m_buffer.data(), wm_req.size);
      if (!error.empty())
        return ToString("Failed to read the data to be written: ", error);

      wm_resp.written =
          WriteMemory(wm_req.address, m_buffer.data(), wm_req.size);

      m_io.Write(wm_resp);

      error = m_io.Flush();
      if (!error.empty())
        return ToString("Failed to write the write memory response: ", error);
    } break;

    default: {
      m_io.Write(0, RECOGNIZED_LENGTH);
      error = m_io.Flush();
      if (!error.empty())
        return ToString("Failed to write the flag indicating if the request "
                        "was recognized: ",
                        error);

      m_buffer.reserve(total_arg_size);
      error = m_io.ReadBuffer(keep_running, m_buffer.data(), total_arg_size);
      if (!error.empty())
        return ToString("Failed to read the arguments: ", error);
    }
    };

    return "";
  }

private:
  SocketIO m_io;

  uint32_t m_client_version = 0;

  std::vector<uint8_t> m_buffer;
};

// [Client]
// The client can use this class to issue DMA requests via an already
// established SocketIO connection. Before starting to issue the requests,
// the client must invoke Handshake function once.
//
// After than, the client can execute other functions as many times as needed.
// All functions are blocking, they will not return the control until the
// request is fully handled by the server.
//
// To cancel a request, set the atomic_bool flag you pass to each function
// to false.

class DMAClient final {
public:
  DMAClient(SocketIO &&io) : m_io(std::move(io)) {}

  std::string Handshake(std::atomic_bool &keep_running) {
    m_io.Write(DMA_REMOTE_VERSION, VERSION_LENGTH);
    auto error = m_io.Flush();
    if (!error.empty())
      return ToString("Failed to send the DMA client version to the server: ",
                      error);

    error = m_io.Read(keep_running, m_server_version, VERSION_LENGTH);
    if (!error.empty())
      return ToString("Failed to read the DMA server version: ", error);

    return "";
  }

  virtual std::string ReadMemory(std::atomic_bool &keep_waiting,
                                 uint64_t address, uint8_t *buffer, size_t size,
                                 size_t &read) {
    m_io.Write(ReadMemoryReq::ID, OPCODE_LENGTH);

    ReadMemoryReq rm_req;
    rm_req.address = address;
    rm_req.size = size;

    m_io.Write(sizeof(rm_req), TOTAL_ARG_SIZE_LENGTH);
    m_io.Write(rm_req);

    auto error = m_io.Flush();
    if (!error.empty())
      return ToString("Failed to write the read memory request: ", error);

    uint8_t recognized = 0;
    error = m_io.Read(keep_waiting, recognized, RECOGNIZED_LENGTH);
    if (!error.empty())
      return ToString("Failed to receive the 'recognized' flag: ", error);

    if (0 == recognized)
      return "Read memory request was not recognized by the server";

    ReadMemoryReq::Out rm_resp;
    error = m_io.Read(keep_waiting, rm_resp);
    if (!error.empty())
      return ToString("Failed to receive the response: ", error);

    error = m_io.ReadBuffer(keep_waiting, buffer, rm_resp.read);
    if (!error.empty())
      return ToString("Failed to receive the response data: ", error);

    read = rm_resp.read;
    return "";
  }

  virtual std::string WriteMemory(std::atomic_bool &keep_waiting,
                                  uint64_t address, const uint8_t *buffer,
                                  size_t size, size_t &written) {
    m_io.Write(WriteMemoryReq::ID, OPCODE_LENGTH);

    WriteMemoryReq wm_req;
    wm_req.address = address;
    wm_req.size = size;

    m_io.Write(sizeof(wm_req) + size, TOTAL_ARG_SIZE_LENGTH);
    m_io.Write(wm_req);
    m_io.WriteBuffer(buffer, size);

    auto error = m_io.Flush();
    if (!error.empty())
      return ToString("Failed to write the write memory request: ", error);

    uint8_t recognized = 0;
    error = m_io.Read(keep_waiting, recognized, RECOGNIZED_LENGTH);
    if (!error.empty())
      return ToString("Failed to receive the 'recognized' flag: ", error);

    if (0 == recognized)
      return "Write memory request was not recognized by the server";

    WriteMemoryReq::Out wm_resp;
    error = m_io.Read(keep_waiting, wm_resp);
    if (!error.empty())
      return ToString("Failed to receive the response: ", error);

    written = wm_resp.written;
    return "";
  }

private:
  SocketIO m_io;

  uint32_t m_server_version = 0;
};

} // namespace rdma

#endif // REMOTE_DMA_HPP
