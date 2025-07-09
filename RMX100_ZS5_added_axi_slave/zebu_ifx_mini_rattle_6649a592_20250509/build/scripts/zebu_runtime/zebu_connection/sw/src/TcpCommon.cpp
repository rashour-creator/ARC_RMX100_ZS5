#include "TcpCommon.h"
std::vector<std::pair<int,int>> TcpCommon::current_opened_sockets;
int TcpCommon::createSocket(client_Server_State_t& state)
{
    int _socket = -1;
    // Create socket
    _socket = socket(AF_INET, SOCK_STREAM, 0);
    if (_socket < 0)
    {
        fprintf(stderr, "Error creating socket.\n");
        state =  ERROR_IN_CREATING_SOCK;
    }
    state = SOCKET_CREATED_SUCCESSFULLY;
    return _socket;
}

send_recv_state_t TcpCommon::sendData(void *data, int dataSize , int& bytesSent)
{
    int bytesTx = send(clientSock, data, dataSize, 0);
    if (bytesTx == -1)
    {
        std::cerr << "[ERROR]: error: " << std::strerror(errno) << std::endl;
        fprintf(stderr, "Error sending data.\n");
        return ERROR_IN_SENDING;
    }
    printf("Number of bytes_sent are %d\n", bytesTx);
	bytesSent = bytesTx;
    return SEND_OR_RECV_SUCCESSFULLY;
}
send_recv_state_t TcpCommon::recvData(void *buffer, int bufferSize , int& bytesRecv)
{
    // to hold the number of bytes received
    int bytesRx = recv(clientSock, buffer, bufferSize, 0);
    if (bytesRx == -1)
    {
        std::cerr << "[ERROR]: error: " << std::strerror(errno) << std::endl;
        printf("Error receiving data\n");
        return ERROR_IN_RECEIVING;
    }
    else if (bytesRx == 0)
    {
        printf("Client or Server disconnected.\n");
        return CLIENT_DISCONNECTED;
    }
	bytesRecv = bytesRx;
    return SEND_OR_RECV_SUCCESSFULLY;
}
void TcpCommon::handleCtrlC(int signum) 
{
    printf("\nCtrl+C pressed.\nExiting gracefully...\n");
    for (auto& sock_pair:current_opened_sockets)
    {
        if (sock_pair.first != -1)
            close(sock_pair.first);
         if (sock_pair.second != -1)
            close(sock_pair.second);

    }
    exit(0);
}



