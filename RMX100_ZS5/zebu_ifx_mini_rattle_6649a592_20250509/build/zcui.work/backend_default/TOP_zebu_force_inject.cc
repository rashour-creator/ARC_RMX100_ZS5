/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#include <unistd.h>
#include "TOP_zebu_force_inject.hh"

ZEBU_zebu_force_inject_Top zebu_force_inject;

ZEBU::Memory **zebu_force_inject_memtbl;

int ZEBU_zebu_force_inject_Init(ZEBU::Board *zebu) {
    if(zebu == NULL) {
        return 1;
    }

    zebu_force_inject_memtbl = new ZEBU::Memory*[1];
    zebu_force_inject_memtbl[0] = NULL;
    return 0;
}
