// Following needed to suppress b0, b1 defines
#define ZEBU_NDEF_BINARY_VALUE

#include <string.h>
#include "rl_ifu_fetcher.h"
#include "libZebuZEMI3.hh"

using namespace ZEBU;

// Anonymous namespace
namespace {

} // of anonymous namespace

namespace ZEMI3_USER {

rl_ifu_fetcher::rl_ifu_fetcher () : ZEBU::ZEMI3Xtor ("rl_ifu_fetcher")
{
}

} // of namespace

extern "C" void *rl_ifu_fetcher_init ()
{
	return (void *)(new ZEMI3_USER::rl_ifu_fetcher);
}

