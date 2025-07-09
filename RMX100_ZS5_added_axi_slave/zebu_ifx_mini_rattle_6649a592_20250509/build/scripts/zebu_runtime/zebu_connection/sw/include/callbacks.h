#pragma once

#include "TcpServer.h"
#include "thread"
#include <stdio.h>
#include <iostream>
#include <pthread.h>
#include <signal.h>
#include "xtor_jtag_t32_svs.hh"
#include "xtor_amba_slave_axi3_svs.h"
#include "xtor_amba_slave_svs.hh"
#include <libZebu.hh>
// #include "zRci_types.hh"
#include "zRci.hh"
#include "string.h"
#include "libZebuZEMI3.hh"
#include "svt_c_runtime_cfg.hh"
#include "svt_pthread_threading.hh"
#include "svt_zebu_platform.hh"
#include "ZEMI3Xtor.hh"
#include "ZEMI3Manager.hh"
#include <unordered_map>
#include <functional>
#include <vector>
#include "handlers.h"
#include "dataTypes.h"
#include <typeinfo>

using namespace std;
using namespace ZEBU;
using namespace ZEBU_IP;
using namespace XTOR_AMBA_SLAVE_SVS;
using namespace ZRCI;

/******************************************* Functions Prototypes *********************************************************/
#if AXI_XTOR_TCP_IP == 1
void startServer();
void check_client_state(void);
#endif
void set_rdata_resp(const void* data, bool setDataFlag=false);
void cb_raddr(void* xtor, ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIChanInfo addr);
void cb_wrtxn(void* xtor,ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIChanInfo addr, ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIData* data);
void fillMemWithData();
bool send_res(std::unordered_map<ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t, uint8_t>&m_slaveMemory, int resSz);


