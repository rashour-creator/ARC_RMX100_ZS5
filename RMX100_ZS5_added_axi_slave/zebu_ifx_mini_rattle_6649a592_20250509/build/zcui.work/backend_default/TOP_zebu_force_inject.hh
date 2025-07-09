/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#ifndef _TOP_zebu_force_inject_HH
#define _TOP_zebu_force_inject_HH
#include "libZebu.hh"

typedef struct {
} ZEBU_zebu_force_inject_Top;
extern ZEBU::Memory **zebu_force_inject_memtbl;

extern ZEBU_zebu_force_inject_Top zebu_force_inject;

int ZEBU_zebu_force_inject_Init(ZEBU::Board *zebu);

#endif
