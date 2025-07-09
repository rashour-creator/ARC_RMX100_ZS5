#ifndef TCP_COMMON_H_
#define TCP_COMMON_H_
#include <stdio.h>
#include <iostream>
#include <errno.h>
#include <cerrno>
#include <cstring>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <signal.h>
#include <vector>
typedef enum
{

    CLIENT_DISCONNECTED = -3,
    ERROR_IN_SENDING = -2,
    ERROR_IN_RECEIVING =-1,
    SEND_OR_RECV_SUCCESSFULLY = 0

}send_recv_state_t;

typedef enum 
{
    ACCEPT_CLIENT_ERROR = -6,
    SOCK_LISTEN_ERROR = -5,
    SOCK_BIND_ERROR = -4,
    SET_SOCK_OPT_FAILED = -3,
    ERROR_IN_CONNECTING_SERVER = -2,
    ERROR_IN_CREATING_SOCK = -1,
    CONNECTED_SUCCESSFULLY = 0,
    SERVER_STARTED_SUCCESSFULLY = 1,
    ACCPETED_CLIENT_SUCCESSFULLY = 2,
    SOCKET_CREATED_SUCCESSFULLY = 3
}client_Server_State_t; 

class TcpCommon
{
    public :
    send_recv_state_t sendData(void *data, int dataSize ,int& bytesSent);
    send_recv_state_t recvData(void *buffer, int bufferSize ,  int& bytesRecv);
    protected :
    int clientSock = -1;
    int serverSock = -1;
    int createSocket(client_Server_State_t& state);
    static std::vector<std::pair<int,int>>current_opened_sockets;
    static void handleCtrlC(int signum); 

};
#endif // TCP_COMMON_H_
