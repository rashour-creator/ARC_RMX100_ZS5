#ifndef xtor_amba_slave_axi3_svs_H
#define xtor_amba_slave_axi3_svs_H

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void ZEBU_VS_AMBA_SLAVE_error__notifier (int _arg_error_code);
extern void ZEBU_VS_AMBA_SLAVE_dpi__write_addr (const svBitVecVal* _arg_AW_txn, const svBitVecVal* _arg_global_counter);
extern void ZEBU_VS_AMBA_SLAVE_dpi__write_data (const svBitVecVal* _arg_WDATA_txn, const svBitVecVal* _arg_global_counter);
extern void ZEBU_VS_AMBA_SLAVE_dpi__read_addr (const svBitVecVal* _arg_AR_txn, const svBitVecVal* _arg_global_counter);
extern void ZEBU_VS_AMBA_SLAVE_dpi__read_fifo (int _arg_rid);
extern void ZEBU_VS_AMBA_SLAVE_dpi__write_fifo (int _arg_wid);
extern void ZEBU_VS_SNPS_UDPI__BuildSerialNumber (const svBitVecVal* _arg_data);
extern int ZEBU_VS_SNPS_UDPI__rst_assert ();
extern int ZEBU_VS_SNPS_UDPI__rst_deassert ();
extern void ZEBU_VS_SNPS_UDPI__unlockSw ();
extern void ZEBU_VS_SNPS_UDPI__clkTick ();
extern void ZEBU_VS_AMBA_SLAVE_dpi__getconfig (int* _arg_amba_mode, int* _arg_data_width, int* _arg_addr_width, int* _arg_id_w_width, int* _arg_id_r_width, int* _arg_blen_width, int* _arg_interleave_depth, int* _arg_user_req_width, int* _arg_user_data_width, int* _arg_user_resp_width, int* _arg_is_haps, int* _arg_loop_w_width, int* _arg_loop_r_width, int* _arg_sid_width, int* _arg_ssid_width);
extern void ZEBU_VS_AMBA_SLAVE_dpi__driveARready (svBit _arg_value);
extern void ZEBU_VS_AMBA_SLAVE_dpi__driveAWready (svBit _arg_value);
extern void ZEBU_VS_AMBA_SLAVE_dpi__driveWready (svBit _arg_value);
extern void ZEBU_VS_AMBA_SLAVE_dpi__setparam (int _arg_param, int _arg_val);
extern void ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus (int* _arg_value);
extern int ZEBU_VS_SNPS_UDPI__waitResetComplete ();
extern int ZEBU_VS_SNPS_UDPI__runClk_sw (unsigned int _arg_numclock);
extern unsigned char ZEBU_VS_SNPS_UDPI__resetDetectEnable (svBit _arg_ena);
extern unsigned char ZEBU_VS_SNPS_UDPI__getClkCount (svBitVecVal* _arg_counter);
extern unsigned char ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod (unsigned int _arg_period);
extern unsigned char ZEBU_VS_SNPS_UDPI__setTickPeriod (unsigned int _arg_period);
extern int ZEBU_VS_SNPS_UDPI__fromSwtoHwData (const svBitVecVal* _arg_sw_message, int _arg_valid_size, int _arg_queue_num);

extern void *xtor_amba_slave_axi3_svs_init ();

#ifdef __cplusplus
} /* of extern-C */
#endif


#ifdef __cplusplus
#include "libZebuZEMI3.hh"

namespace ZEMI3_USER {

class xtor_amba_slave_axi3_svs : public ZEBU::ZEMI3Xtor
{
public:
	xtor_amba_slave_axi3_svs ();
};

} // of namespace
#endif

#endif // xtor_amba_slave_axi3_svs_H
