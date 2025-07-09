/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#ifndef _TOP_zebu_rtl_clock_debug_HH
#define _TOP_zebu_rtl_clock_debug_HH
#include "libZebu.hh"

typedef struct {
} ZEBU_zebu_rtl_clock_debug_Top;
extern ZEBU::Memory **zebu_rtl_clock_debug_memtbl;

extern ZEBU_zebu_rtl_clock_debug_Top zebu_rtl_clock_debug;

int ZEBU_zebu_rtl_clock_debug_Init(ZEBU::Board *zebu);

#endif
