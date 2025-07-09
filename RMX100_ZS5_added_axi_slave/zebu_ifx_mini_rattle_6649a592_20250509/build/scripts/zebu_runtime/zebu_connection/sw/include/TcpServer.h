#ifndef TCP_CONNECTION_H_
#define TCP_CONNECTION_H_
#include "TcpCommon.h"
class TcpServer : public TcpCommon
{
public:
TcpServer();
client_Server_State_t acceptClient();
client_Server_State_t startServer(int port);
~TcpServer();

};

#endif // TCP_CONNECTION_H_
