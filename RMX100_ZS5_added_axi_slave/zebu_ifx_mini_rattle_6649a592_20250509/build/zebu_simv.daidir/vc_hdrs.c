#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdio.h>
#include <dlfcn.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* VCS error reporting routine */
extern void vcsMsgReport1(const char *, const char *, int, void *, void*, const char *);

#ifndef _VC_TYPES_
#define _VC_TYPES_
/* common definitions shared with DirectC.h */

typedef unsigned int U;
typedef unsigned char UB;
typedef unsigned char scalar;
typedef struct { U c; U d;} vec32;

#define scalar_0 0
#define scalar_1 1
#define scalar_z 2
#define scalar_x 3

extern long long int ConvUP2LLI(U* a);
extern void ConvLLI2UP(long long int a1, U* a2);
extern long long int GetLLIresult();
extern void StoreLLIresult(const unsigned int* data);
typedef struct VeriC_Descriptor *vc_handle;

#ifndef SV_3_COMPATIBILITY
#define SV_STRING const char*
#else
#define SV_STRING char*
#endif

#endif /* _VC_TYPES_ */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_error__notifier
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_error__notifier
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_error__notifier(/* INPUT */int A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_error__notifier");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_error__notifier");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_error__notifier */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__write_resp
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__write_resp
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_dpi__write_resp(/* INPUT */int A_1, /* INPUT */int A_2, const /* INPUT */svBitVecVal *A_3)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1, /* INPUT */int A_2, const /* INPUT */svBitVecVal *A_3) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1, int A_2, const svBitVecVal* A_3)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_dpi__write_resp");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2, A_3);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_dpi__write_resp");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__write_resp */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp(/* INPUT */int A_1, /* INPUT */int A_2, const /* INPUT */svBitVecVal *A_3)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1, /* INPUT */int A_2, const /* INPUT */svBitVecVal *A_3) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1, int A_2, const svBitVecVal* A_3)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2, A_3);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__read_resp
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__read_resp
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_dpi__read_resp(/* INPUT */int A_1, /* INPUT */int A_2, /* INPUT */unsigned char A_3, const /* INPUT */svBitVecVal *A_4, const /* INPUT */svBitVecVal *A_5)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1, /* INPUT */int A_2, /* INPUT */unsigned char A_3, const /* INPUT */svBitVecVal *A_4, const /* INPUT */svBitVecVal *A_5) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1, int A_2, unsigned char A_3, const svBitVecVal* A_4, const svBitVecVal* A_5)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_dpi__read_resp");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2, A_3, A_4, A_5);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_dpi__read_resp");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__read_resp */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp(/* INPUT */int A_1, /* INPUT */int A_2, /* INPUT */unsigned char A_3, const /* INPUT */svBitVecVal *A_4, const /* INPUT */svBitVecVal *A_5)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1, /* INPUT */int A_2, /* INPUT */unsigned char A_3, const /* INPUT */svBitVecVal *A_4, const /* INPUT */svBitVecVal *A_5) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1, int A_2, unsigned char A_3, const svBitVecVal* A_4, const svBitVecVal* A_5)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2, A_3, A_4, A_5);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo()
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)() = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)()) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_();
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo()
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)() = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)()) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_();
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo
__attribute__((weak)) void ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo(/* INPUT */int A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__BuildSerialNumber
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__BuildSerialNumber
__attribute__((weak)) void ZEBU_VS_SNPS_UDPI__BuildSerialNumber(const /* INPUT */svBitVecVal *A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(const /* INPUT */svBitVecVal *A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(const svBitVecVal* A_1)) dlsym(RTLD_NEXT, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__BuildSerialNumber */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__rst_assert
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__rst_assert
__attribute__((weak)) void ZEBU_VS_SNPS_UDPI__rst_assert()
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)() = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)()) dlsym(RTLD_NEXT, "ZEBU_VS_SNPS_UDPI__rst_assert");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_();
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_SNPS_UDPI__rst_assert");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__rst_assert */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__rst_deassert
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__rst_deassert
__attribute__((weak)) void ZEBU_VS_SNPS_UDPI__rst_deassert()
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)() = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)()) dlsym(RTLD_NEXT, "ZEBU_VS_SNPS_UDPI__rst_deassert");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_();
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_SNPS_UDPI__rst_deassert");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__rst_deassert */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__unlockSw
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__unlockSw
__attribute__((weak)) void ZEBU_VS_SNPS_UDPI__unlockSw()
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)() = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)()) dlsym(RTLD_NEXT, "ZEBU_VS_SNPS_UDPI__unlockSw");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_();
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_SNPS_UDPI__unlockSw");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__unlockSw */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__clkTick
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__clkTick
__attribute__((weak)) void ZEBU_VS_SNPS_UDPI__clkTick()
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)() = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)()) dlsym(RTLD_NEXT, "ZEBU_VS_SNPS_UDPI__clkTick");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_();
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_SNPS_UDPI__clkTick");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_SNPS_UDPI__clkTick */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_error__notifier
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_error__notifier
__attribute__((weak)) void ZEBU_VS_AMBA_SLAVE_error__notifier(/* INPUT */int A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_SLAVE_error__notifier");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_SLAVE_error__notifier");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_error__notifier */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_addr
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_addr
__attribute__((weak)) void ZEBU_VS_AMBA_SLAVE_dpi__write_addr(const /* INPUT */svBitVecVal *A_1, const /* INPUT */svBitVecVal *A_2)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(const /* INPUT */svBitVecVal *A_1, const /* INPUT */svBitVecVal *A_2) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(const svBitVecVal* A_1, const svBitVecVal* A_2)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_SLAVE_dpi__write_addr");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__write_addr");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_addr */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_data
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_data
__attribute__((weak)) void ZEBU_VS_AMBA_SLAVE_dpi__write_data(const /* INPUT */svBitVecVal *A_1, const /* INPUT */svBitVecVal *A_2)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(const /* INPUT */svBitVecVal *A_1, const /* INPUT */svBitVecVal *A_2) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(const svBitVecVal* A_1, const svBitVecVal* A_2)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_SLAVE_dpi__write_data");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__write_data");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_data */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__read_addr
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__read_addr
__attribute__((weak)) void ZEBU_VS_AMBA_SLAVE_dpi__read_addr(const /* INPUT */svBitVecVal *A_1, const /* INPUT */svBitVecVal *A_2)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(const /* INPUT */svBitVecVal *A_1, const /* INPUT */svBitVecVal *A_2) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(const svBitVecVal* A_1, const svBitVecVal* A_2)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_SLAVE_dpi__read_addr");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__read_addr");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__read_addr */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__read_fifo
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__read_fifo
__attribute__((weak)) void ZEBU_VS_AMBA_SLAVE_dpi__read_fifo(/* INPUT */int A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__read_fifo */

#ifndef __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_fifo
#define __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_fifo
__attribute__((weak)) void ZEBU_VS_AMBA_SLAVE_dpi__write_fifo(/* INPUT */int A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */int A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(int A_1)) dlsym(RTLD_NEXT, "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_ZEBU_VS_AMBA_SLAVE_dpi__write_fifo */

#ifndef __VCS_IMPORT_DPI_STUB_svapfGetAttempt
#define __VCS_IMPORT_DPI_STUB_svapfGetAttempt
__attribute__((weak)) void* svapfGetAttempt(/* INPUT */unsigned int A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void* (*_vcs_dpi_fp_)(/* INPUT */unsigned int A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void* (*)(unsigned int A_1)) dlsym(RTLD_NEXT, "svapfGetAttempt");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        return _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "svapfGetAttempt");
        return 0;
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_svapfGetAttempt */

#ifndef __VCS_IMPORT_DPI_STUB_svapfReportResult
#define __VCS_IMPORT_DPI_STUB_svapfReportResult
__attribute__((weak)) void svapfReportResult(/* INPUT */unsigned int A_1, /* INPUT */void* A_2, /* INPUT */int A_3)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */unsigned int A_1, /* INPUT */void* A_2, /* INPUT */int A_3) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(unsigned int A_1, void* A_2, int A_3)) dlsym(RTLD_NEXT, "svapfReportResult");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2, A_3);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "svapfReportResult");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_svapfReportResult */

#ifndef __VCS_IMPORT_DPI_STUB_svapfGetAssertEnabled
#define __VCS_IMPORT_DPI_STUB_svapfGetAssertEnabled
__attribute__((weak)) int svapfGetAssertEnabled(/* INPUT */unsigned int A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static int (*_vcs_dpi_fp_)(/* INPUT */unsigned int A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (int (*)(unsigned int A_1)) dlsym(RTLD_NEXT, "svapfGetAssertEnabled");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        return _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "svapfGetAssertEnabled");
        return 0;
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_svapfGetAssertEnabled */

#ifndef __VCS_EXPORT_DPI_DUMMY_REFERENCES__
#define __VCS_EXPORT_DPI_DUMMY_REFERENCES__
/* Dummy references to those export DPI routines.
 * The symbols will be then exported, so the
 * import DPI routines in another shared
 * libraries can call.
 */
void __vcs_export_dpi_dummy_references__();
void __vcs_export_dpi_dummy_references__()
{
    extern void ZEBU_VS_AMBA_MASTER_dpi__getconfig(void);
    void (*fp0)(void) = (void (*)(void)) ZEBU_VS_AMBA_MASTER_dpi__getconfig;
    fp0 = fp0;
    extern void ZEBU_VS_AMBA_MASTER_dpi__driveRready(void);
    void (*fp1)(void) = (void (*)(void)) ZEBU_VS_AMBA_MASTER_dpi__driveRready;
    fp1 = fp1;
    extern void ZEBU_VS_AMBA_MASTER_dpi__driveBready(void);
    void (*fp2)(void) = (void (*)(void)) ZEBU_VS_AMBA_MASTER_dpi__driveBready;
    fp2 = fp2;
    extern void ZEBU_VS_AMBA_MASTER_dpi__setparam(void);
    void (*fp3)(void) = (void (*)(void)) ZEBU_VS_AMBA_MASTER_dpi__setparam;
    fp3 = fp3;
    extern void ZEBU_VS_AMBA_MASTER_dpi__getResetStatus(void);
    void (*fp4)(void) = (void (*)(void)) ZEBU_VS_AMBA_MASTER_dpi__getResetStatus;
    fp4 = fp4;
    extern void ZEBU_VS_SNPS_UDPI__fromSwtoHwData(void);
    void (*fp5)(void) = (void (*)(void)) ZEBU_VS_SNPS_UDPI__fromSwtoHwData;
    fp5 = fp5;
    extern void ZEBU_VS_SNPS_UDPI__resetDetectEnable(void);
    void (*fp6)(void) = (void (*)(void)) ZEBU_VS_SNPS_UDPI__resetDetectEnable;
    fp6 = fp6;
    extern void ZEBU_VS_SNPS_UDPI__getClkCount(void);
    void (*fp7)(void) = (void (*)(void)) ZEBU_VS_SNPS_UDPI__getClkCount;
    fp7 = fp7;
    extern void ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod(void);
    void (*fp8)(void) = (void (*)(void)) ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod;
    fp8 = fp8;
    extern void ZEBU_VS_SNPS_UDPI__setTickPeriod(void);
    void (*fp9)(void) = (void (*)(void)) ZEBU_VS_SNPS_UDPI__setTickPeriod;
    fp9 = fp9;
    extern void ZEBU_VS_SNPS_UDPI__waitResetComplete(void);
    void (*fp10)(void) = (void (*)(void)) ZEBU_VS_SNPS_UDPI__waitResetComplete;
    fp10 = fp10;
    extern void ZEBU_VS_SNPS_UDPI__runClk_sw(void);
    void (*fp11)(void) = (void (*)(void)) ZEBU_VS_SNPS_UDPI__runClk_sw;
    fp11 = fp11;
    extern void ZEBU_VS_AMBA_SLAVE_dpi__getconfig(void);
    void (*fp12)(void) = (void (*)(void)) ZEBU_VS_AMBA_SLAVE_dpi__getconfig;
    fp12 = fp12;
    extern void ZEBU_VS_AMBA_SLAVE_dpi__driveARready(void);
    void (*fp13)(void) = (void (*)(void)) ZEBU_VS_AMBA_SLAVE_dpi__driveARready;
    fp13 = fp13;
    extern void ZEBU_VS_AMBA_SLAVE_dpi__driveAWready(void);
    void (*fp14)(void) = (void (*)(void)) ZEBU_VS_AMBA_SLAVE_dpi__driveAWready;
    fp14 = fp14;
    extern void ZEBU_VS_AMBA_SLAVE_dpi__driveWready(void);
    void (*fp15)(void) = (void (*)(void)) ZEBU_VS_AMBA_SLAVE_dpi__driveWready;
    fp15 = fp15;
    extern void ZEBU_VS_AMBA_SLAVE_dpi__setparam(void);
    void (*fp16)(void) = (void (*)(void)) ZEBU_VS_AMBA_SLAVE_dpi__setparam;
    fp16 = fp16;
    extern void ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus(void);
    void (*fp17)(void) = (void (*)(void)) ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus;
    fp17 = fp17;
}
#endif /* __VCS_EXPORT_DPI_DUMMY_REFERENCES_ */

#ifdef __cplusplus
}
#endif

