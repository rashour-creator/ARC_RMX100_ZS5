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
#include "TOP_Zebu_Transactional_Interface.hh"

ZEBU_Zebu_Transactional_Interface_Top Zebu_Transactional_Interface;

ZEBU::Memory **Zebu_Transactional_Interface_memtbl;

int ZEBU_Zebu_Transactional_Interface_Init(ZEBU::Board *zebu) {
    if(zebu == NULL) {
        return 1;
    }

    Zebu_Transactional_Interface_memtbl = new ZEBU::Memory*[1];
    Zebu_Transactional_Interface_memtbl[0] = NULL;
    return 0;
}
