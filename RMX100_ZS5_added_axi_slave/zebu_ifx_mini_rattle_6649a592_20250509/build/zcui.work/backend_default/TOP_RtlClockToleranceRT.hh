/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#ifndef _TOP_RtlClockToleranceRT_HH
#define _TOP_RtlClockToleranceRT_HH
#include "libZebu.hh"

typedef struct {
} ZEBU_RtlClockToleranceRT_Top;
extern ZEBU::Memory **RtlClockToleranceRT_memtbl;

extern ZEBU_RtlClockToleranceRT_Top RtlClockToleranceRT;

int ZEBU_RtlClockToleranceRT_Init(ZEBU::Board *zebu);

#endif
