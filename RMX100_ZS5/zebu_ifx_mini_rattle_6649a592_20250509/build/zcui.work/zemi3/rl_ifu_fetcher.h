#ifndef rl_ifu_fetcher_H
#define rl_ifu_fetcher_H

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif


extern void *rl_ifu_fetcher_init ();

#ifdef __cplusplus
} /* of extern-C */
#endif


#ifdef __cplusplus
#include "libZebuZEMI3.hh"

namespace ZEMI3_USER {

class rl_ifu_fetcher : public ZEBU::ZEMI3Xtor
{
public:
	rl_ifu_fetcher ();
};

} // of namespace
#endif

#endif // rl_ifu_fetcher_H
