// -----------------------------------------------
// COPYRIGHT (C) 2016 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
// -----------------------------------------------

#include <stdio.h>
#include <chrono>

#include <pthread.h>
#include <signal.h>
#include <libZebu.hh>
#include "string.h"
//#include "T32JtagServer.hh"
//#include "Uart.hh"
#include "zRci_types.hh"
#include <thread>

//#include "xtor_uart_svs.hh"
#include "xtor_jtag_t32_svs.hh"
//#include "TopScheduler.hh"
#include "XtorScheduler.hh"
#include "libZebuZEMI3.hh"
#include "svt_report.hh"
#include "svt_pthread_threading.hh"
#define THREADING svt_pthread_threading
//#include "svt_cr_threading.hh"
#include "svt_c_threading.hh"
#include "svt_zebu_platform.hh"
#include "svt_c_runtime_cfg.hh"

#include "xtor_amba_master_svs.hh"

// <REMOTE_AXI>
#include "RemoteDMA.hpp"
// </REMOTE_AXI>

using namespace ZEBU;
using namespace ZEBU_IP;
//using namespace XTOR_UART_SVS;
using namespace XTOR_JTAG_T32_SVS;
using namespace XTOR_AMBA_MASTER_SVS;
using namespace XTOR_AMBA_DEFINES_SVS;
using namespace ZRCI;
using namespace std;




static int SocketNumberJtag = 20010;
static int SocketNumberDAP0 = 20011;
static int SocketNumberDAP1 = 20012;
static int SocketNumberDMA = 20013;
static uint32_t config      = 1    ;

//xtor_uart_svs         *uart1      = NULL;
xtor_jtag_t32_svs     *jtag1      = NULL;
xtor_amba_master_svs *objAmba = NULL;

svt_c_threading   *threading  = NULL;
XtorScheduler     * xsched;
XtorSchedParams_t * XtorSchedParas;
svt_c_runtime_cfg * runtime;
svt_report        *reporter   = NULL;

Board             *board      = NULL;
bool terminate_threads = false;
//bool uart_cfg_done = false;
//bool uart_ratio_freezed = false;
//int det_ratio1 = 432;
//int det_ratio1_last = 432;

// <REMOTE_AXI>
std::thread remote_axi_handler;
atomic_bool keep_handling_remote_axi;
// </REMOTE_AXI>

void handler_ctrl_c (int sig) 
{
    fflush(stdout);
    fflush(stderr);
    std::cerr << "interrupted. Closing server session." << std::endl;
    //delete uart1;
    delete jtag1;
    exit (0);
}


pthread_t jtag_tid;
extern "C" void *jtag_loop(void *)
{
      //jtag1->startServer(SocketNumberJtag, SocketNumberDAP0, SocketNumberDAP1);
	  jtag1->runUntilReset();
      jtag1->startServer();
       
      printf("server started \n");
       
      while (!terminate_threads) {
        //keep thread loops
      }
      //close server when ended emu
      printf("server closed \n");
      jtag1->close();
   //terminate_threads = true;
   printf("Exit JTAG loop\n");
   fflush(stdout);
   return NULL;
}
//pthread_t uart_tid;
//extern "C" void *uart_loop(void *)
//{
//  int prev_ratio = 0;
//  int new_ratio  = 96;
//
//   uart1->setName("********UART1**********");
//   uart1->setWidth(8);
//   uart1->setConvMode(Conv_DOS_BSR);
//   uart1->setStopBit(OneStopBit);
//   uart1->setRatio(96);
//   uart1->setParity(NoParity);
//   uart1->openDumpFile("uart_dump.log");
//   uart1->dumpSetDisplayErrors(true);
//   uart1->dumpSetFormat(DumpASCII);
//   //uart1->setDebugLevel(4);
//
//   //uart1->runUntilReset();
//   printf("pre config done\n");
//   uart1->config();
//
//   printf("config done\n");
//
//   uart_cfg_done = true;
//
//   while (!terminate_threads) {
//      
//      if (uart_cfg_done == false) {
//          continue;
//      }
//
//      if (uart1->isAlive()) {
//         det_ratio1 = uart1->getDetectedRatio();
//         if ((det_ratio1 != det_ratio1_last) && (det_ratio1 != 0) ) {
//            printf("ratio updated to %d\n", det_ratio1);
//            if (!uart_ratio_freezed) {
//               uart1->setRatio(det_ratio1);
//               uart1->config();
//            }
//            det_ratio1_last = det_ratio1;
//
//            if (det_ratio1 == 96) {
//                uart_ratio_freezed = true;
//                printf("freezed !!!! !!!! \n");
//            }
//         }
////           printf("UART Term is alive\n");
////           fflush(stdout);
//      }
//      else {
//           printf("UART Term is dead\n");
//           fflush(stdout);
//           break;
//      }
//       
////           printf("UART Thread terminate_threads = %d\n", terminate_threads);
////           fflush(stdout);
//   }
//  
//   printf("Exit UART loop\n");
//   fflush(stdout);
//  return NULL;
//}

// <REMOTE_AXI>

static constexpr uint8_t AXI_CHANNEL = 6;
static constexpr uint64_t AXI_DATA_WIDTH_BYTE_BIT_SHIFT = 6;
static constexpr uint64_t AXI_DATA_WIDTH_BITS =
    8 * (1u << AXI_DATA_WIDTH_BYTE_BIT_SHIFT);

static constexpr uint64_t AXI_BOUNDARY_BYTES = 4096;
static constexpr uint64_t AXI_BOUNDARY_MASK = ~(AXI_BOUNDARY_BYTES - 1);

static constexpr uint64_t AXI_DATA_WIDTH_BYTES = AXI_DATA_WIDTH_BITS / 8;
static constexpr uint64_t AXI_ALIGNMENT_MASK = ~(AXI_DATA_WIDTH_BYTES - 1);

static constexpr uint64_t AXI_MAX_BURST_ELEMS = 1u << 4u;

static constexpr uint64_t AXI_MAX_BURST_SIZE =
    AXI_MAX_BURST_ELEMS * AXI_DATA_WIDTH_BYTES;

class AXIDMAServer : public rdma::DMAServer {
public:
  AXIDMAServer(rdma::SocketIO &&io) : rdma::DMAServer(std::move(io)) {}

  size_t ReadMemory(uint64_t address, uint8_t *buffer, size_t size) {
    size_t read = 0;

    while (read < size) {
      const uint64_t current_address = address + read;
      const size_t current_size = size - read;

      size_t read_this_time = 0;
      std::string error;

      std::tie(read_this_time, error) =
          ReadMemoryChunk(current_address, buffer + read, current_size);

      read += read_this_time;

      if (!error.empty()) {
        printf("[RDMA] Failed to read %llu bytes at 0x%llx: %s\n",
               static_cast<unsigned long long>(current_size),
               static_cast<unsigned long long>(current_address), error.c_str());
        break;
      }
    }

    return read;
  }

  size_t WriteMemory(uint64_t address, const uint8_t *buffer, size_t size) {
    size_t written = 0;

    while (written < size) {
      const uint64_t current_address = address + written;
      const size_t current_size = size - written;

      size_t written_this_time = 0;
      std::string error;

      std::tie(written_this_time, error) =
          WriteMemoryChunk(current_address, buffer + written, current_size);

      written += written_this_time;

      if (!error.empty()) {
        printf("[RDMA] Failed to write %llu bytes to 0x%llx: %s\n",
               static_cast<unsigned long long>(current_size),
               static_cast<unsigned long long>(current_address), error.c_str());
        break;
      }
    }

    return written;
  }

private:
  struct ChunkInfo {
    AXIChanInfo chan_info;
    uint64_t prefix_length;
    uint64_t data_length;
    uint64_t postfix_length;
  };

  ChunkInfo CalculateChunkInfo(uint64_t address, size_t size) {
    auto aligned_address = address & AXI_ALIGNMENT_MASK;

    const uint64_t next_boundary =
        (aligned_address & AXI_BOUNDARY_MASK) + AXI_BOUNDARY_BYTES;
    const uint64_t distance_to_boundary = next_boundary - aligned_address;

    uint64_t bytes_available =
        std::min<uint64_t>(distance_to_boundary, AXI_MAX_BURST_SIZE);
    uint64_t bytes_total = 0;

    // Add dummy bytes to move the cursor forward to the first real data byte.

    const auto prefix_length = address - aligned_address;

    bytes_available -= prefix_length;
    bytes_total += prefix_length;

    // Now add the real data.

    const auto data_length = std::min<uint64_t>(bytes_available, size);

    bytes_available -= data_length;
    bytes_total += data_length;

    // Now add more dummy bytes to make the whole packet aligned.

    uint64_t postfix_length = 0;

    const auto bytes_total_misalignment = bytes_total & ~AXI_ALIGNMENT_MASK;
    if (0 != bytes_total_misalignment) {
      postfix_length = AXI_DATA_WIDTH_BYTES - bytes_total_misalignment;

      bytes_available -= postfix_length;
      bytes_total += postfix_length;
    }

    AXIChanInfo chan_info{};
    chan_info.id = AXI_CHANNEL;
    chan_info.addr = aligned_address;
    chan_info.size = AXI_DATA_WIDTH_BYTE_BIT_SHIFT;
    chan_info.len = bytes_total / AXI_DATA_WIDTH_BYTES - 1;
    chan_info.burst = AXI_BURST_INCR;

    return {chan_info, prefix_length, data_length, postfix_length};
  }

  std::pair<size_t, std::string> ReadMemoryChunk(uint64_t address,
                                                 uint8_t *buffer, size_t size) {
    auto chunk_info = CalculateChunkInfo(address, size);

    m_axi_data.Clear();
    AXIResp axi_resp{};
    auto status = objAmba->rdTxn(chunk_info.chan_info, &m_axi_data, &axi_resp);

    // HW FIFO is full, try again.
    if (1 == status)
      return {0, ""};

    auto *axi_code = axi_resp.GetResp();
    if (nullptr == axi_code)
      return {0, "AXI response is empty"};

    if (AXI_RESP_OKAY != *axi_code)
      return {0, rdma::ToString("Unexpected AXI response code: ", *axi_code)};

    auto read = m_axi_data.GetLengthByte();
    if (read < chunk_info.prefix_length)
      return {0, rdma::ToString("The length of the returned data (", read,
                                ") is less than the length of the prefix (",
                                chunk_info.prefix_length, ")")};

    read -= chunk_info.prefix_length;
    const auto to_copy = std::min<size_t>(read, size);
    memcpy(buffer, m_axi_data.GetDataPt(chunk_info.prefix_length), to_copy);

    if (read < chunk_info.data_length)
      return {read, rdma::ToString("AXI returned less data (", read,
                                   ") than requested (", chunk_info.data_length,
                                   ")")};

    return {to_copy, ""};
  }

  std::pair<size_t, std::string>
  WriteMemoryChunk(uint64_t address, const uint8_t *buffer, size_t size) {
    auto chunk_info = CalculateChunkInfo(address, size);

    m_axi_data.Clear();

    for (size_t i = 0; i < chunk_info.prefix_length; i++)
      m_axi_data.FillByte(0, 0);

    m_axi_data.FillByteArray(buffer, chunk_info.data_length);

    for (size_t i = 0; i < chunk_info.postfix_length; i++)
      m_axi_data.FillByte(0, 0);

    // objAmba->enableTxnDump(true);
    // objAmba->setLog(stdout, true);

    AXIResp axi_resp{};
    auto status = objAmba->wrTxn(chunk_info.chan_info, &m_axi_data, &axi_resp);

    // HW FIFO is full, try again.
    if (1 == status)
      return {0, ""};

    auto *axi_code = axi_resp.GetResp();
    if (nullptr == axi_code)
      return {0, "AXI response is empty"};

    if (AXI_RESP_OKAY != *axi_code)
      return {0, rdma::ToString("Unexpected AXI response code: ", *axi_code)};

    return {chunk_info.data_length, ""};
  }

  AXIData m_axi_data;
};

void axi_loop() {
  keep_handling_remote_axi = true;

  printf("[RDMA] Opening a remote DMA server at port %llu\n",
         static_cast<unsigned long long>(SocketNumberDMA));
  fflush(stdout);

  rdma::ServerSocket server(INADDR_LOOPBACK, SocketNumberDMA);
  auto error = server.Open();
  if (!error.empty()) {
    printf("[RDMA] Failed to open the DMA server socket: %s\n", error.c_str());
    fflush(stdout);
    return;
  }

  while (keep_handling_remote_axi) {
    printf("[RDMA] Waiting for a new client...\n");
    fflush(stdout);

  auto io = server.Accept(keep_handling_remote_axi);
  error = io.GetInitError();
  if (!error.empty()) {
    printf("[RDMA] Failed to accept the client connection: %s\n",
           error.c_str());
    fflush(stdout);
    continue;
  }

  printf("[RDMA] Accepted RDMA connection, starting the RDMA loop\n");
  fflush(stdout);

  AXIDMAServer axi_dma_server(std::move(io));

  error = axi_dma_server.StartLoop(keep_handling_remote_axi);
  if (!error.empty()) {
    printf("[RDMA] Error while handling remote AXI requests: %s\n",
           error.c_str());
    fflush(stdout);
    }
  }

  printf("[RDMA] RDMA loop finished\n");
  fflush(stdout);
}

// </REMOTE_AXI>

void* zRci_pre_board_open(const ZRCI::TbOpts& param) {
  signal (SIGSEGV, &handler_ctrl_c);
  signal (SIGABRT, &handler_ctrl_c);
  signal (SIGTERM, &handler_ctrl_c);
  signal (SIGINT,  &handler_ctrl_c);

  return NULL;
}

void* zRci_post_board_open(const ZRCI::TbOpts& param) {
  return NULL;
}

void* zRci_pre_board_init(const ZRCI::TbOpts& param) {
    xsched = XtorScheduler::get();
    XtorSchedParas = xsched->getDefaultParams();
    runtime   = new svt_c_runtime_cfg();
    threading = new svt_pthread_threading();
    
    XtorSchedParas->useVcsSimulation   = false;
    XtorSchedParas->useZemiManager     = true;
    XtorSchedParas->noParams           = true;
    XtorSchedParas->zebuInitCb         = NULL;
    XtorSchedParas->zebuInitCbParams   = NULL; 
    xsched->configure(XtorSchedParas) ;

    return NULL;
}

void* zRci_post_board_init(const ZRCI::TbOpts& param) {
      runtime->set_threading_api(threading);
      runtime->set_platform(new svt_zebu_platform(param.board, false));
      svt_c_runtime_cfg::set_default(runtime);

      //cerr << "#TB : Register UART Transactor..." << param.board << endl;
      //xtor_uart_svs::Register("xtor_uart_svs");

      cerr << "#TB : Register JTAG Transactor..." << param.board << endl;
      xtor_jtag_t32_svs::Register("xtor_jtag_t32_svs");

      cerr << "#TB : Register AXI Transactor..." << param.board << endl;
      xtor_amba_master_svs::Register("xtor_amba_master_axi3_svs");

      printf("register done\n");
      fflush(stdout);
      //uart1 = static_cast<xtor_uart_svs*>(xtor_uart_svs::getInstance("xtor_uart_svs", "zebu_top.uart_driver_0", xsched, runtime));
     // uart1= static_cast<xtor_uart_svs*>(Xtor::getNewXtor("xtor_uart_svs", XtorRuntimeMode_t::XtorRuntimeZebuMode));
     // ifflush(stdout);
     // fprintf (stderr, "Found - Drivers [%s][%s] ...\n", uart1->getDriverModelName (),uart1->getDriverInstanceName ());
      //fflush(stdout);

 
      ZEBU_IP::XTOR_JTAG_T32_SVS::t32_probes probes;
	  probes.probe_JTAG_path = "zebu_top.i_t32Jtag_driver";
	  probes.probe_JTAG_port = 20010;   

      jtag1 = static_cast<xtor_jtag_t32_svs*>(xtor_jtag_t32_svs::getInstance(runtime,probes));     
      // Create instance of AMBA master
      objAmba = xtor_amba_master_svs::getInstance("zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i", runtime);

      printf("getxtor done\n");

      fprintf (stderr, "Found - Drivers [%s][%s] ...\n", jtag1->getDriverModelName (),jtag1->getDriverInstanceName ());

      //uart1->setOpMode(XtermMode);
      printf("xtorinit done\n");

      //terminate_threads = false;
      //pthread_create(&uart_tid,NULL, (void *(*) (void *)) uart_loop, (void *) param.board);

      //jtag1->init(param.board, "zebu_top.i_t32Jtag_driver",
      //           PV_UNKNOWN, "DAP0_PV_UNKNOWN",
      //           PV_UNKNOWN , "DAP1_PV_UNKNOWN",
      //           runtime
      //);
      jtag1->setDebugLevel(ZEBU_IP::DEBUG_NONE);
      //jtag1->initBFM();//runs 10 dummy CPU CLK
	  //jtag1->runUntilReset();
      
      //jtag1->startServer(SocketNumberJtag, SocketNumberDAP0, SocketNumberDAP1);
      pthread_create(&jtag_tid,NULL, (void *(*) (void *)) jtag_loop, (void *) param.board);
    
      // <REMOTE_AXI>
    remote_axi_handler = std::thread([]() { axi_loop(); });
    // </REMOTE_AXI>

    return NULL;
}

void* zRci_cleanup(const ZRCI::TbOpts& param) {
      // Close all
      printf("Ending testbench\n");
      fflush(stdout);
      terminate_threads = true;
      
      pthread_join(jtag_tid, NULL);
      printf("Ending JTAG Threads\n");
      fflush(stdout);
      
     // pthread_join(uart_tid, NULL);
     // printf("Ending UART Threads\n");
     // fflush(stdout);
        
      // <REMOTE_AXI>
     printf("[RDMA] Terminating the RDMA thread\n");
    fflush(stdout);

    keep_handling_remote_axi = false;
    if (remote_axi_handler.joinable())
        remote_axi_handler.join();

    printf("[RDMA] The RDMA thread was terminated\n");
    fflush(stdout);
    // </REMOTE_AXI>

     // if (uart1 != NULL) {
     //    printf("UART deleted\n");
     //    fflush(stdout);
     //    uart1->closeDumpFile();
     //    delete uart1;
     // }
      if (jtag1 != NULL) {
         printf("JTAG deleted\n");
         fflush(stdout);
         delete jtag1;
      }
     if(objAmba != NULL)
     delete objAmba;
      threading = NULL;
      xsched = NULL;
      XtorSchedParas = NULL;
      runtime = NULL;

      printf("########################### zRci_cleanup done ##########################\n");

  return NULL;
}


