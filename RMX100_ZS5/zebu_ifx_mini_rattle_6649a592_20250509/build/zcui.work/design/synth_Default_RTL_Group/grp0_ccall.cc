//  -----------------------------------------------
//
//  Copyright (C) 2015 Synopsys, Inc. All Rights Reserved.
//
//  grp0_ccall.cc
//
//  -----------------------------------------------

// Following needed to suppress b0, b1 defines\n");
#define ZEBU_NDEF_BINARY_VALUE

#include <string.h>
#include "grp0_ccall.h"
#include "libZebuCCall.hh"
using namespace ZEBU;

// Dummy function so that back-end is able to resolve the name
// for system tasks
extern "C" void grp0_dummy_import_for_pli () {};

