#ifndef _VC_HDRS_H
#define _VC_HDRS_H

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdio.h>
#include <dlfcn.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _VC_TYPES_
#define _VC_TYPES_
/* common definitions shared with DirectC.h */

typedef unsigned int U;
typedef unsigned char UB;
typedef unsigned char scalar;
typedef struct { U c; U d;} vec32;

#define scalar_0 0
#define scalar_1 1
#define scalar_z 2
#define scalar_x 3

extern long long int ConvUP2LLI(U* a);
extern void ConvLLI2UP(long long int a1, U* a2);
extern long long int GetLLIresult();
extern void StoreLLIresult(const unsigned int* data);
typedef struct VeriC_Descriptor *vc_handle;

#ifndef SV_3_COMPATIBILITY
#define SV_STRING const char*
#else
#define SV_STRING char*
#endif

#endif /* _VC_TYPES_ */


 extern void ZEBU_VS_AMBA_MASTER_error__notifier(/* INPUT */int error_code);

 extern void ZEBU_VS_AMBA_MASTER_dpi__getconfig(/* OUTPUT */int *amba_mode, /* OUTPUT */int *data_width, /* OUTPUT */int *addr_width, /* OUTPUT */int *id_w_width, /* OUTPUT */int *id_r_width, /* OUTPUT */int *blen_width, /* OUTPUT */int *interleave_depth, /* OUTPUT */int *user_req_width, /* OUTPUT */int *user_data_width, /* OUTPUT */int *user_resp_width, 
/* OUTPUT */int *loop_w_width, /* OUTPUT */int *loop_r_width, /* OUTPUT */int *sid_width, /* OUTPUT */int *ssid_width, /* OUTPUT */int *snp_addr_width, /* OUTPUT */int *snp_data_width, /* OUTPUT */int *is_haps);

 extern void ZEBU_VS_AMBA_MASTER_dpi__driveRready(/* INPUT */int value);

 extern void ZEBU_VS_AMBA_MASTER_dpi__driveBready(/* INPUT */int value);

 extern void ZEBU_VS_AMBA_MASTER_dpi__setparam(/* INPUT */int param, /* INPUT */int val);

 extern void ZEBU_VS_AMBA_MASTER_dpi__getResetStatus(/* OUTPUT */int *value);

 extern void ZEBU_VS_AMBA_MASTER_dpi__write_resp(/* INPUT */int resp, /* INPUT */int bid, const /* INPUT */svBitVecVal *buser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp(/* INPUT */int resp, /* INPUT */int bid, const /* INPUT */svBitVecVal *buser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__read_resp(/* INPUT */int rid, /* INPUT */int resp, /* INPUT */unsigned char rlast, const /* INPUT */svBitVecVal *rdata, const /* INPUT */svBitVecVal *ruser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp(/* INPUT */int rid, /* INPUT */int resp, /* INPUT */unsigned char rlast, const /* INPUT */svBitVecVal *rdata, const /* INPUT */svBitVecVal *ruser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo();

 extern void ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo();

 extern void ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo(/* INPUT */int wid);

 extern void ZEBU_VS_SNPS_UDPI__fromSwtoHwData(const /* INPUT */svBitVecVal *sw_message, /* INPUT */int valid_size, /* INPUT */int queue_num);

 extern void ZEBU_VS_SNPS_UDPI__BuildSerialNumber(const /* INPUT */svBitVecVal *data);

 extern void ZEBU_VS_SNPS_UDPI__rst_assert();

 extern void ZEBU_VS_SNPS_UDPI__rst_deassert();

 extern unsigned char ZEBU_VS_SNPS_UDPI__resetDetectEnable(/* INPUT */unsigned char ena);

 extern unsigned char ZEBU_VS_SNPS_UDPI__getClkCount(/* OUTPUT */svBitVecVal *counter);

 extern void ZEBU_VS_SNPS_UDPI__unlockSw();

 extern unsigned char ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod(/* INPUT */unsigned int period);

 extern void ZEBU_VS_SNPS_UDPI__clkTick();

 extern unsigned char ZEBU_VS_SNPS_UDPI__setTickPeriod(/* INPUT */unsigned int period);

 extern void ZEBU_VS_SNPS_UDPI__waitResetComplete();

 extern void ZEBU_VS_SNPS_UDPI__runClk_sw(/* INPUT */unsigned int numclock);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__getconfig(/* OUTPUT */int *amba_mode, /* OUTPUT */int *data_width, /* OUTPUT */int *addr_width, /* OUTPUT */int *id_w_width, /* OUTPUT */int *id_r_width, /* OUTPUT */int *blen_width, /* OUTPUT */int *interleave_depth, /* OUTPUT */int *user_req_width, /* OUTPUT */int *user_data_width, /* OUTPUT */int *user_resp_width, 
/* OUTPUT */int *is_haps, /* OUTPUT */int *loop_w_width, /* OUTPUT */int *loop_r_width, /* OUTPUT */int *sid_width, /* OUTPUT */int *ssid_width);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__driveARready(/* INPUT */unsigned char value);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__driveAWready(/* INPUT */unsigned char value);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__driveWready(/* INPUT */unsigned char value);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__setparam(/* INPUT */int param, /* INPUT */int val);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus(/* OUTPUT */int *value);

 extern void ZEBU_VS_AMBA_SLAVE_error__notifier(/* INPUT */int error_code);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__write_addr(const /* INPUT */svBitVecVal *AW_txn, const /* INPUT */svBitVecVal *global_counter);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__write_data(const /* INPUT */svBitVecVal *WDATA_txn, const /* INPUT */svBitVecVal *global_counter);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__read_addr(const /* INPUT */svBitVecVal *AR_txn, const /* INPUT */svBitVecVal *global_counter);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__read_fifo(/* INPUT */int rid);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__write_fifo(/* INPUT */int wid);

 extern void* svapfGetAttempt(/* INPUT */unsigned int assertHandle);

 extern void svapfReportResult(/* INPUT */unsigned int assertHandle, /* INPUT */void* ptrAttempt, /* INPUT */int result);

 extern int svapfGetAssertEnabled(/* INPUT */unsigned int assertHandle);
void SdisableFork();

#ifdef __cplusplus
}
#endif


#endif //#ifndef _VC_HDRS_H

