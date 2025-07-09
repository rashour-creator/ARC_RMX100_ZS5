#include "TcpServer.h"
TcpServer::TcpServer()
{
    signal(SIGINT, TcpServer::handleCtrlC);
    client_Server_State_t state;
    serverSock = createSocket(state);
    // if (state == SOCKET_CREATED_SUCCESSFULLY)
    //     state = startServer(port);   
}
client_Server_State_t TcpServer::startServer(int port)
{
    struct sockaddr_in serverAddr;
    int reuseOption = 1;
    if (setsockopt(serverSock, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &reuseOption, sizeof(reuseOption)) == -1)
    {
        fprintf(stderr, "[SERVER] setsockopt failed");
        close(serverSock);
        return SET_SOCK_OPT_FAILED;
    }

    // Configure server address 
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = htons(INADDR_ANY);
    serverAddr.sin_port = htons(port); // convert host endianess bytes to match the network endianess bytes.

    // Bind the socket to the server address
    if (bind(serverSock, (struct sockaddr *)&serverAddr, sizeof(serverAddr)) == -1)
    {
        printf("[SERVER] binding Error \n");
        return SOCK_BIND_ERROR;
    }

    // Listen for incoming connections
    if (listen(serverSock, 5) == -1)
    {
        printf("[SERVER] listening Error.\n");
        return SOCK_LISTEN_ERROR;
    }
    
    printf("Server successfully!\n");
    return SERVER_STARTED_SUCCESSFULLY;

}


client_Server_State_t TcpServer::acceptClient()
{
    struct sockaddr_in clientAddr;
    socklen_t clientAddrLen = sizeof(clientAddr);
    clientSock= accept(serverSock, (struct sockaddr *)&clientAddr, &clientAddrLen);
    TcpCommon::current_opened_sockets.push_back(std::make_pair(serverSock,clientSock));
    if (clientSock == -1)
    {
        printf("[SERVER] Error accepting client connection.\n");
        return ACCEPT_CLIENT_ERROR;
    }
    char ipString[INET_ADDRSTRLEN]; // INET_ADDRSTRLEN is the maximum length of an IPv4 address string
    // Convert binary IP address to human-readable string
    inet_ntop(AF_INET, &(clientAddr.sin_addr), ipString, INET_ADDRSTRLEN);
    // Print the IP address and port of the client connected.
    printf("[SERVER]Client with ip address: \"%s\" connected successfully!\n",ipString);
    return ACCPETED_CLIENT_SUCCESSFULLY;
}
TcpServer::~TcpServer()
{
    close(clientSock);
    close(serverSock);
}
