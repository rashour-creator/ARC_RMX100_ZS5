#pragma once 

#include "TcpServer.h"
#include "thread"
#include <stdio.h>
#include <iostream>
#include <pthread.h>
#include <signal.h>
#include "xtor_amba_slave_axi3_svs.h"
#include "xtor_amba_slave_svs.hh"
#include <libZebu.hh>
#include "zRci.hh"
#include "string.h"
#include "libZebuZEMI3.hh"
#include "svt_c_runtime_cfg.hh"
#include "svt_pthread_threading.hh"
#include "svt_zebu_platform.hh"
#include "ZEMI3Xtor.hh"
#include "ZEMI3Manager.hh"
#include <unordered_map>
#include "dataTypes.h"
 
using namespace std;
using namespace ZEBU;
using namespace ZEBU_IP;
using namespace XTOR_AMBA_SLAVE_SVS;

/*********************************** Globals *******************************************************/
extern xtor_amba_slave_svs * g_objAmbaSlave;
extern std::thread g_socketThread;
extern SynchronizationFlags g_flags;
extern TcpServer server;
extern void startServer();

class AddressHandler
{
    public:
        typedef void (AddressHandler::*MemberFunctionPointer)();
        static AddressHandler* m_addressHandler;
        static AddressHandler* getHandlerInstance();

        void handleReadCallback();
        void handleWriteCallback();

        void setReadAddress(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t ra);
        void setWriteAddress(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t wa);
        void setResponse(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIResp * r);
        void setReadData(ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIData * rd);
        void setWriteData(uint8 * wd);
        void setBurstLength(int bl);
        void setSize(int s);
        void setTotalBytes(int sz, int bl);
        void setPtrToImageBuffer(char * ptr);

    private:
        AddressHandler();
        #if AXI_XTOR_TCP_IP == 1
         void handleAxiAcceptClientRecvDataFlag();
         void handleAxiInputDataReadyFlag();
         void handleAxiImageAddress();
         
         void handleAxiTerminateApp();

         void handleAxiDetectionsAddress();
         void handleAxiSendOutputAddressFlag();

         bool sendResult();

         void fillReadAddressHandlers();
         void fillWriteAddressHandlers();
         #endif

         void handleAxiWriteDefaultAddress();
         void handleAxiReadDefaultAddress();

         void setReadDataResponse(const void* data, bool setDataFlag);
         
         int writeInMemory();

         std::map<ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t , MemberFunctionPointer> m_readAddressHandlers;
         std::map<ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t , MemberFunctionPointer> m_writeAddressHandlers;
         std::unordered_map<ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t, uint8_t> m_slaveMemory;

        ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t m_readAddress, m_writeAddress;
        ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIResp* m_response;
        ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIData* m_readData;
        uint8 * m_writeData;
        int m_burstLength, m_size, m_totalBytes;
        int m_sendDataCounter;
        char * m_ptrToImageBuffer;
};