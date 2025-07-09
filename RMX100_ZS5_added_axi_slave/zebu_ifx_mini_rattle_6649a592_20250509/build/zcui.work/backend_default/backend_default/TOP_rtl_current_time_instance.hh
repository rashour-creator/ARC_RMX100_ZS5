/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#ifndef _TOP_rtl_current_time_instance_HH
#define _TOP_rtl_current_time_instance_HH
#include "libZebu.hh"

typedef struct {
} ZEBU_rtl_current_time_instance_Top;
extern ZEBU::Memory **rtl_current_time_instance_memtbl;

extern ZEBU_rtl_current_time_instance_Top rtl_current_time_instance;

int ZEBU_rtl_current_time_instance_Init(ZEBU::Board *zebu);

#endif
