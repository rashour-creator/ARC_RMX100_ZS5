#ifndef xtor_t32Jtag_svs_H
#define xtor_t32Jtag_svs_H

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern unsigned char zebu_jtag_xtor__output_reset_message (const svBitVecVal* _arg_reset_data);
extern int zebu_jtag_xtor__get_config (svLogicVecVal* _arg_config_data);
extern int zebu_jtag_xtor__set_signals (int _arg_signals, int _arg_mask);
extern int zebu_jtag_xtor__force_trst ();
extern int zebu_jtag_xtor__hard_reset ();
extern int zebu_jtag_xtor__send_and_receive (long long _arg_tdi, long long _arg_tms, int _arg_cycle_count, svBitVecVal* _arg_tdo);
extern int zebu_jtag_xtor__run (int _arg_cycle);
extern int zebu_jtag_xtor__runUntilReset ();
extern int ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw (unsigned int _arg_numclock);
extern void zebu_jtag_xtor__config (svBit _arg_trst, svBit _arg_rtck, int _arg_ratio_val, svBit _arg_shiftTDO);
extern long long zebu_jtag_xtor__get_cycles ();
extern char zebu_jtag_xtor__get_signals ();
extern unsigned char zebu_jtag_xtor__is_reset_active (int* _arg_reset_check);

extern void *xtor_t32Jtag_svs_init ();

#ifdef __cplusplus
} /* of extern-C */
#endif


#ifdef __cplusplus
#include "libZebuZEMI3.hh"

namespace ZEMI3_USER {

class xtor_t32Jtag_svs : public ZEBU::ZEMI3Xtor
{
public:
	xtor_t32Jtag_svs ();
};

} // of namespace
#endif

#endif // xtor_t32Jtag_svs_H
