/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#ifndef _TOP_LICENSE_HH
#define _TOP_LICENSE_HH
#include "libZebu.hh"

typedef struct {
} ZEBU_LICENSE_Top;
extern ZEBU::Memory **LICENSE_memtbl;

extern ZEBU_LICENSE_Top LICENSE;

int ZEBU_LICENSE_Init(ZEBU::Board *zebu);

#endif
