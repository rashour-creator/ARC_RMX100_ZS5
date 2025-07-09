// Following needed to suppress b0, b1 defines
#define ZEBU_NDEF_BINARY_VALUE

#include <string.h>
#include "xtor_amba_master_axi3_svs.h"
#include "libZebuZEMI3.hh"

using namespace ZEBU;

// Anonymous namespace
namespace {

class ZEMI3ImportHandler13 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_error_code);
public:
	ZEMI3ImportHandler13 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_error__notifier", zemi3_func_id)
	{
		this->setArgCount(1);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_error_code = (int*)actual;
				*_arg_error_code = getSmallSlice (31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			int _arg_error_code = 0;
			handler->getArgValue (0, (void*)&_arg_error_code, INT_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_error_code);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler11 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_resp, int _arg_bid, const svBitVecVal* _arg_buser);
public:
	ZEMI3ImportHandler11 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_dpi__write_resp", zemi3_func_id)
	{
		this->setArgCount(3);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_resp = (int*)actual;
				*_arg_resp = getSmallSlice (31, 0);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_bid = (int*)actual;
				*_arg_bid = getSmallSlice (63, 32);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_buser = (svBitVecVal*)actual;
				getSlice (_arg_buser, 65, 64);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			int _arg_resp = 0;
			int _arg_bid = 0;
			svBitVecVal _arg_buser[SV_PACKED_DATA_NELEMS(2)];
			memset ((void*)_arg_buser, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(2));
			handler->getArgValue (0, (void*)&_arg_resp, INT_TYPE);
			handler->getArgValue (1, (void*)&_arg_bid, INT_TYPE);
			handler->getArgValue (2, (void*)_arg_buser, BITVEC_TYPE);
			handler->enter ();
			dpi_func (_arg_resp, _arg_bid, _arg_buser);
			handler->leave ();
		}
		return 0;
	}
};

class ZEMI3ImportHandler12 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_resp, int _arg_bid, const svBitVecVal* _arg_buser);
public:
	ZEMI3ImportHandler12 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp", zemi3_func_id)
	{
		this->setArgCount(3);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_resp = (int*)actual;
				*_arg_resp = getSmallSlice (31, 0);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_bid = (int*)actual;
				*_arg_bid = getSmallSlice (63, 32);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_buser = (svBitVecVal*)actual;
				getSlice (_arg_buser, 65, 64);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			int _arg_resp = 0;
			int _arg_bid = 0;
			svBitVecVal _arg_buser[SV_PACKED_DATA_NELEMS(2)];
			memset ((void*)_arg_buser, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(2));
			handler->getArgValue (0, (void*)&_arg_resp, INT_TYPE);
			handler->getArgValue (1, (void*)&_arg_bid, INT_TYPE);
			handler->getArgValue (2, (void*)_arg_buser, BITVEC_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_resp, _arg_bid, _arg_buser);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler9 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_rid, int _arg_resp, svBit _arg_rlast, const svBitVecVal* _arg_rdata, const svBitVecVal* _arg_ruser);
public:
	ZEMI3ImportHandler9 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_dpi__read_resp", zemi3_func_id)
	{
		this->setArgCount(5);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_rid = (int*)actual;
				*_arg_rid = getSmallSlice (543, 512);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_resp = (int*)actual;
				*_arg_resp = getSmallSlice (575, 544);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, BIT_TYPE))
					return;
				svBit *_arg_rlast = (svBit*)actual;
				*_arg_rlast = getSmallSlice (578, 578);
			}
			break;
		case (3):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_rdata = (svBitVecVal*)actual;
				getSlice (_arg_rdata, 511, 0);
			}
			break;
		case (4):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_ruser = (svBitVecVal*)actual;
				getSlice (_arg_ruser, 577, 576);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			int _arg_rid = 0;
			int _arg_resp = 0;
			svBit _arg_rlast = 0;
			svBitVecVal _arg_rdata[SV_PACKED_DATA_NELEMS(512)];
			svBitVecVal _arg_ruser[SV_PACKED_DATA_NELEMS(2)];
			memset ((void*)_arg_rdata, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(512));
			memset ((void*)_arg_ruser, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(2));
			handler->getArgValue (0, (void*)&_arg_rid, INT_TYPE);
			handler->getArgValue (1, (void*)&_arg_resp, INT_TYPE);
			handler->getArgValue (2, (void*)&_arg_rlast, BIT_TYPE);
			handler->getArgValue (3, (void*)_arg_rdata, BITVEC_TYPE);
			handler->getArgValue (4, (void*)_arg_ruser, BITVEC_TYPE);
			handler->enter ();
			dpi_func (_arg_rid, _arg_resp, _arg_rlast, _arg_rdata, _arg_ruser);
			handler->leave ();
		}
		return 0;
	}
};

class ZEMI3ImportHandler10 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_rid, int _arg_resp, svBit _arg_rlast, const svBitVecVal* _arg_rdata, const svBitVecVal* _arg_ruser);
public:
	ZEMI3ImportHandler10 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp", zemi3_func_id)
	{
		this->setArgCount(5);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_rid = (int*)actual;
				*_arg_rid = getSmallSlice (543, 512);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_resp = (int*)actual;
				*_arg_resp = getSmallSlice (575, 544);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, BIT_TYPE))
					return;
				svBit *_arg_rlast = (svBit*)actual;
				*_arg_rlast = getSmallSlice (578, 578);
			}
			break;
		case (3):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_rdata = (svBitVecVal*)actual;
				getSlice (_arg_rdata, 511, 0);
			}
			break;
		case (4):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_ruser = (svBitVecVal*)actual;
				getSlice (_arg_ruser, 577, 576);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			int _arg_rid = 0;
			int _arg_resp = 0;
			svBit _arg_rlast = 0;
			svBitVecVal _arg_rdata[SV_PACKED_DATA_NELEMS(512)];
			svBitVecVal _arg_ruser[SV_PACKED_DATA_NELEMS(2)];
			memset ((void*)_arg_rdata, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(512));
			memset ((void*)_arg_ruser, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(2));
			handler->getArgValue (0, (void*)&_arg_rid, INT_TYPE);
			handler->getArgValue (1, (void*)&_arg_resp, INT_TYPE);
			handler->getArgValue (2, (void*)&_arg_rlast, BIT_TYPE);
			handler->getArgValue (3, (void*)_arg_rdata, BITVEC_TYPE);
			handler->getArgValue (4, (void*)_arg_ruser, BITVEC_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_rid, _arg_resp, _arg_rlast, _arg_rdata, _arg_ruser);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler8 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler8 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo", zemi3_func_id)
	{
		this->setArgCount(0);
		this->setIsContext ();
	}
	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func ();
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler7 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler7 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo", zemi3_func_id)
	{
		this->setArgCount(0);
		this->setIsContext ();
	}
	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func ();
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler6 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_wid);
public:
	ZEMI3ImportHandler6 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo", zemi3_func_id)
	{
		this->setArgCount(1);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_wid = (int*)actual;
				*_arg_wid = getSmallSlice (31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			int _arg_wid = 0;
			handler->getArgValue (0, (void*)&_arg_wid, INT_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_wid);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler5 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (const svBitVecVal* _arg_data);
public:
	ZEMI3ImportHandler5 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_SNPS_UDPI__BuildSerialNumber", zemi3_func_id)
	{
		this->setArgCount(1);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_data = (svBitVecVal*)actual;
				getSlice (_arg_data, 31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			svBitVecVal _arg_data[SV_PACKED_DATA_NELEMS(32)];
			memset ((void*)_arg_data, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(32));
			handler->getArgValue (0, (void*)_arg_data, BITVEC_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_data);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler4 : public ZEMI3ImportHandler {
	typedef int (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler4 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_SNPS_UDPI__rst_assert", zemi3_func_id)
	{
		this->setIsTask();
		this->setArgCount(0);
		this->setIsContext ();
	}
	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			handler->enter ();
			dpi_func ();
			handler->leave ();
		}
		return 0;
	}
};

class ZEMI3ImportHandler3 : public ZEMI3ImportHandler {
	typedef int (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler3 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_SNPS_UDPI__rst_deassert", zemi3_func_id)
	{
		this->setIsTask();
		this->setArgCount(0);
		this->setIsContext ();
	}
	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			handler->enter ();
			dpi_func ();
			handler->leave ();
		}
		return 0;
	}
};

class ZEMI3ImportHandler2 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler2 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_SNPS_UDPI__unlockSw", zemi3_func_id)
	{
		this->setArgCount(0);
		this->setIsContext ();
	}
	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func ();
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler1 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler1 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_SNPS_UDPI__clkTick", zemi3_func_id)
	{
		this->setArgCount(0);
		this->setIsContext ();
	}
	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func ();
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ExportHandler1 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler1 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_MASTER_dpi__getconfig", 1)
	{
		this->setArgCount(17);
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_amba_mode = (int*)actual;
				*_arg_amba_mode = getSmallSlice (31, 0);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_data_width = (int*)actual;
				*_arg_data_width = getSmallSlice (63, 32);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_addr_width = (int*)actual;
				*_arg_addr_width = getSmallSlice (95, 64);
			}
			break;
		case (3):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_id_w_width = (int*)actual;
				*_arg_id_w_width = getSmallSlice (127, 96);
			}
			break;
		case (4):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_id_r_width = (int*)actual;
				*_arg_id_r_width = getSmallSlice (159, 128);
			}
			break;
		case (5):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_blen_width = (int*)actual;
				*_arg_blen_width = getSmallSlice (191, 160);
			}
			break;
		case (6):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_interleave_depth = (int*)actual;
				*_arg_interleave_depth = getSmallSlice (223, 192);
			}
			break;
		case (7):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_user_req_width = (int*)actual;
				*_arg_user_req_width = getSmallSlice (255, 224);
			}
			break;
		case (8):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_user_data_width = (int*)actual;
				*_arg_user_data_width = getSmallSlice (287, 256);
			}
			break;
		case (9):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_user_resp_width = (int*)actual;
				*_arg_user_resp_width = getSmallSlice (319, 288);
			}
			break;
		case (10):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_loop_w_width = (int*)actual;
				*_arg_loop_w_width = getSmallSlice (351, 320);
			}
			break;
		case (11):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_loop_r_width = (int*)actual;
				*_arg_loop_r_width = getSmallSlice (383, 352);
			}
			break;
		case (12):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_sid_width = (int*)actual;
				*_arg_sid_width = getSmallSlice (415, 384);
			}
			break;
		case (13):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_ssid_width = (int*)actual;
				*_arg_ssid_width = getSmallSlice (447, 416);
			}
			break;
		case (14):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_snp_addr_width = (int*)actual;
				*_arg_snp_addr_width = getSmallSlice (479, 448);
			}
			break;
		case (15):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_snp_data_width = (int*)actual;
				*_arg_snp_data_width = getSmallSlice (511, 480);
			}
			break;
		case (16):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_is_haps = (int*)actual;
				*_arg_is_haps = getSmallSlice (543, 512);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler2 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler2 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_MASTER_dpi__driveRready", 2)
	{
		this->setArgCount(1);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_value = (const int*)actual;
				putSmallSlice (*_arg_value, 31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler3 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler3 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_MASTER_dpi__driveBready", 3)
	{
		this->setArgCount(1);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_value = (const int*)actual;
				putSmallSlice (*_arg_value, 31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler4 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler4 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_MASTER_dpi__setparam", 4)
	{
		this->setArgCount(2);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_param = (const int*)actual;
				putSmallSlice (*_arg_param, 31, 0);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_val = (const int*)actual;
				putSmallSlice (*_arg_val, 63, 32);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler5 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler5 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_MASTER_dpi__getResetStatus", 5)
	{
		this->setArgCount(1);
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_value = (int*)actual;
				*_arg_value = getSmallSlice (31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler6 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler6 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__fromSwtoHwData", 6)
	{
		this->setIsTask();
		this->setArgCount(3);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				const svBitVecVal *_arg_sw_message = (const svBitVecVal*)actual;
				putSlice (_arg_sw_message, 149, 64);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_valid_size = (const int*)actual;
				putSmallSlice (*_arg_valid_size, 31, 0);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_queue_num = (const int*)actual;
				putSmallSlice (*_arg_queue_num, 63, 32);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler7 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler7 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__fromSwtoHwData", 7)
	{
		this->setIsTask();
		this->setArgCount(3);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				const svBitVecVal *_arg_sw_message = (const svBitVecVal*)actual;
				putSlice (_arg_sw_message, 2515, 64);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_valid_size = (const int*)actual;
				putSmallSlice (*_arg_valid_size, 31, 0);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_queue_num = (const int*)actual;
				putSmallSlice (*_arg_queue_num, 63, 32);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler8 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler8 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__waitResetComplete", 8)
	{
		this->setIsTask();
		this->setArgCount(0);
	}
};

class ZEMI3ExportHandler9 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler9 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__runClk_sw", 9)
	{
		this->setIsTask();
		this->setArgCount(1);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const unsigned int *_arg_numclock = (const unsigned int*)actual;
				putSmallSlice (*_arg_numclock, 31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler10 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler10 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__resetDetectEnable", 10)
	{
		this->setArgCount(1);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BIT_TYPE))
					return;
				const svBit *_arg_ena = (const svBit*)actual;
				putSmallSlice (*_arg_ena, 0, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/void getReturnValue (void *actual, ZEMI3ArgType argType)
	{
		if (!checkTypeMatch (-1, argType, LOGIC_TYPE))
			return;
		unsigned char *_ZEBU_VS_SNPS_UDPI__resetDetectEnable_retval = (unsigned char*)actual;
		*_ZEBU_VS_SNPS_UDPI__resetDetectEnable_retval = getSmallSlice (0, 0);
	}

};

class ZEMI3ExportHandler11 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler11 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__getClkCount", 11)
	{
		this->setArgCount(1);
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_counter = (svBitVecVal*)actual;
				getSlice (_arg_counter, 63, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/void getReturnValue (void *actual, ZEMI3ArgType argType)
	{
		if (!checkTypeMatch (-1, argType, LOGIC_TYPE))
			return;
		unsigned char *_ZEBU_VS_SNPS_UDPI__getClkCount_retval = (unsigned char*)actual;
		*_ZEBU_VS_SNPS_UDPI__getClkCount_retval = getSmallSlice (64, 64);
	}

};

class ZEMI3ExportHandler12 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler12 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod", 12)
	{
		this->setArgCount(1);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const unsigned int *_arg_period = (const unsigned int*)actual;
				putSmallSlice (*_arg_period, 31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/void getReturnValue (void *actual, ZEMI3ArgType argType)
	{
		if (!checkTypeMatch (-1, argType, LOGIC_TYPE))
			return;
		unsigned char *_ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_retval = (unsigned char*)actual;
		*_ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_retval = getSmallSlice (0, 0);
	}

};

class ZEMI3ExportHandler13 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler13 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__setTickPeriod", 13)
	{
		this->setArgCount(1);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const unsigned int *_arg_period = (const unsigned int*)actual;
				putSmallSlice (*_arg_period, 31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/void getReturnValue (void *actual, ZEMI3ArgType argType)
	{
		if (!checkTypeMatch (-1, argType, LOGIC_TYPE))
			return;
		unsigned char *_ZEBU_VS_SNPS_UDPI__setTickPeriod_retval = (unsigned char*)actual;
		*_ZEBU_VS_SNPS_UDPI__setTickPeriod_retval = getSmallSlice (0, 0);
	}

};

extern "C" void ZEBU_VS_AMBA_MASTER_dpi__getconfig (int* _arg_amba_mode, int* _arg_data_width, int* _arg_addr_width, int* _arg_id_w_width, int* _arg_id_r_width, int* _arg_blen_width, int* _arg_interleave_depth, int* _arg_user_req_width, int* _arg_user_data_width, int* _arg_user_resp_width, int* _arg_loop_w_width, int* _arg_loop_r_width, int* _arg_sid_width, int* _arg_ssid_width, int* _arg_snp_addr_width, int* _arg_snp_data_width, int* _arg_is_haps)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_MASTER_dpi__getconfig");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getArgValue (0, (void*)_arg_amba_mode, INT_TYPE);
		handler->getArgValue (1, (void*)_arg_data_width, INT_TYPE);
		handler->getArgValue (2, (void*)_arg_addr_width, INT_TYPE);
		handler->getArgValue (3, (void*)_arg_id_w_width, INT_TYPE);
		handler->getArgValue (4, (void*)_arg_id_r_width, INT_TYPE);
		handler->getArgValue (5, (void*)_arg_blen_width, INT_TYPE);
		handler->getArgValue (6, (void*)_arg_interleave_depth, INT_TYPE);
		handler->getArgValue (7, (void*)_arg_user_req_width, INT_TYPE);
		handler->getArgValue (8, (void*)_arg_user_data_width, INT_TYPE);
		handler->getArgValue (9, (void*)_arg_user_resp_width, INT_TYPE);
		handler->getArgValue (10, (void*)_arg_loop_w_width, INT_TYPE);
		handler->getArgValue (11, (void*)_arg_loop_r_width, INT_TYPE);
		handler->getArgValue (12, (void*)_arg_sid_width, INT_TYPE);
		handler->getArgValue (13, (void*)_arg_ssid_width, INT_TYPE);
		handler->getArgValue (14, (void*)_arg_snp_addr_width, INT_TYPE);
		handler->getArgValue (15, (void*)_arg_snp_data_width, INT_TYPE);
		handler->getArgValue (16, (void*)_arg_is_haps, INT_TYPE);
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_MASTER_dpi__driveRready (int _arg_value)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_MASTER_dpi__driveRready");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_value, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_MASTER_dpi__driveBready (int _arg_value)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_MASTER_dpi__driveBready");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_value, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_MASTER_dpi__setparam (int _arg_param, int _arg_val)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_MASTER_dpi__setparam");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_param, INT_TYPE);
		handler->putArgValue (1, (void*)&_arg_val, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_MASTER_dpi__getResetStatus (int* _arg_value)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_MASTER_dpi__getResetStatus");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getArgValue (0, (void*)_arg_value, INT_TYPE);
		handler->leave ();
	}
}

extern "C" int ZEBU_VS_SNPS_UDPI__fromSwtoHwData (const svBitVecVal* _arg_sw_message, int _arg_valid_size, int _arg_queue_num)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_SNPS_UDPI__fromSwtoHwData");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)_arg_sw_message, BITVEC_TYPE);
		handler->putArgValue (1, (void*)&_arg_valid_size, INT_TYPE);
		handler->putArgValue (2, (void*)&_arg_queue_num, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
	return 0;
}

extern "C" int ZEBU_VS_SNPS_UDPI__waitResetComplete ()
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_SNPS_UDPI__waitResetComplete");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->errorOutExportHangScenario ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->leave ();
	}
	return 0;
}

extern "C" int ZEBU_VS_SNPS_UDPI__runClk_sw (unsigned int _arg_numclock)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_SNPS_UDPI__runClk_sw");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->errorOutExportHangScenario ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_numclock, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
	return 0;
}

extern "C" unsigned char ZEBU_VS_SNPS_UDPI__resetDetectEnable (svBit _arg_ena)
{
	unsigned char _ZEBU_VS_SNPS_UDPI__resetDetectEnable_retval = 0;
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_SNPS_UDPI__resetDetectEnable");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_ena, BIT_TYPE);
		handler->doCall ();
		handler->getReturnValue ((void*)&_ZEBU_VS_SNPS_UDPI__resetDetectEnable_retval, LOGIC_TYPE);
		handler->leave ();
	}
	return _ZEBU_VS_SNPS_UDPI__resetDetectEnable_retval;
}

extern "C" unsigned char ZEBU_VS_SNPS_UDPI__getClkCount (svBitVecVal* _arg_counter)
{
	unsigned char _ZEBU_VS_SNPS_UDPI__getClkCount_retval = 0;
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_SNPS_UDPI__getClkCount");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getArgValue (0, (void*)_arg_counter, BITVEC_TYPE);
		handler->getReturnValue ((void*)&_ZEBU_VS_SNPS_UDPI__getClkCount_retval, LOGIC_TYPE);
		handler->leave ();
	}
	return _ZEBU_VS_SNPS_UDPI__getClkCount_retval;
}

extern "C" unsigned char ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod (unsigned int _arg_period)
{
	unsigned char _ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_retval = 0;
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_period, INT_TYPE);
		handler->doCall ();
		handler->getReturnValue ((void*)&_ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_retval, LOGIC_TYPE);
		handler->leave ();
	}
	return _ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_retval;
}

extern "C" unsigned char ZEBU_VS_SNPS_UDPI__setTickPeriod (unsigned int _arg_period)
{
	unsigned char _ZEBU_VS_SNPS_UDPI__setTickPeriod_retval = 0;
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_SNPS_UDPI__setTickPeriod");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_period, INT_TYPE);
		handler->doCall ();
		handler->getReturnValue ((void*)&_ZEBU_VS_SNPS_UDPI__setTickPeriod_retval, LOGIC_TYPE);
		handler->leave ();
	}
	return _ZEBU_VS_SNPS_UDPI__setTickPeriod_retval;
}

} // of anonymous namespace

namespace ZEMI3_USER {

xtor_amba_master_axi3_svs::xtor_amba_master_axi3_svs () : ZEBU::ZEMI3Xtor ("xtor_amba_master_axi3_svs")
{
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__getconfig_in_port", 1, "ZEBU_VS_AMBA_MASTER_dpi__getconfig_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_dpi__getconfig_out_port", 1, "ZEBU_VS_AMBA_MASTER_dpi__getconfig_out_port", 544, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__driveRready_in_port", 2, "ZEBU_VS_AMBA_MASTER_dpi__driveRready_in_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__driveBready_in_port", 3, "ZEBU_VS_AMBA_MASTER_dpi__driveBready_in_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__setparam_in_port", 4, "ZEBU_VS_AMBA_MASTER_dpi__setparam_in_port", 64, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__getResetStatus_in_port", 5, "ZEBU_VS_AMBA_MASTER_dpi__getResetStatus_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_dpi__getResetStatus_out_port", 5, "ZEBU_VS_AMBA_MASTER_dpi__getResetStatus_out_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_in_port", 19, "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_out_port", 19, "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_out_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_in_port", 20, "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_out_port", 20, "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_out_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_in_port", 21, "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_out_port", 21, "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_out_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp_in_port", 23, "ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp_in_port", 25, "ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_in_port", 26, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_out_port", 26, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_0", 27, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_0", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_0", 27, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_0", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_1", 28, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_1", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_1", 28, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_1", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_2", 29, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_2", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_2", 29, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_2", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_3", 30, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_3", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_3", 30, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_3", 32, (char *)0, (char *)0);
	this->addPort ("RxProtocol", "zemi3_anon_ps1_arbiter", 31, "zemi3_anon_ps1_out_port", 128, (char *)0, (char *)0);
	this->addPort ("RxProtocol", "zemi3_anon_ps2_arbiter", 32, "zemi3_anon_ps2_out_port", 640, (char *)0, (char *)0);
	this->addPort ("TxPort", "zemi_control_in_port", 0, "zemi_control_in_port", 6, (char *)0, (char *)0);
	this->addPort ("RxPort", "zemi_status_out_port", 0, "zemi_status_out_port", 3, (char *)0, (char *)0);
	this->setControlStatusInfo (0, "zemi_control_in_port", "zemi_status_out_port");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 6, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 150, (char *)0, "swtohw_AR");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 6, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 150, (char *)0, "swtohw_AW");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 7, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2516, (char *)0, "wr_data_schd.gen_wdata_fifo_0__swtohw_W");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__waitResetComplete_in_port", 8, "ZEBU_VS_SNPS_UDPI__waitResetComplete_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__waitResetComplete_out_port", 8, "ZEBU_VS_SNPS_UDPI__waitResetComplete_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__runClk_sw_in_port", 9, "ZEBU_VS_SNPS_UDPI__runClk_sw_in_port", 32, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__runClk_sw_out_port", 9, "ZEBU_VS_SNPS_UDPI__runClk_sw_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__resetDetectEnable_in_port", 10, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__resetDetectEnable_out_port", 10, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__getClkCount_in_port", 11, "ZEBU_VS_SNPS_UDPI__getClkCount_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__getClkCount_out_port", 11, "ZEBU_VS_SNPS_UDPI__getClkCount_out_port", 65, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_in_port", 12, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_in_port", 32, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_out_port", 12, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__setTickPeriod_in_port", 13, "ZEBU_VS_SNPS_UDPI__setTickPeriod_in_port", 32, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__setTickPeriod_out_port", 13, "ZEBU_VS_SNPS_UDPI__setTickPeriod_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__clkTick_in_port", 14, "ZEBU_VS_SNPS_UDPI__clkTick_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__clkTick_out_port", 14, "ZEBU_VS_SNPS_UDPI__clkTick_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__unlockSw_in_port", 15, "ZEBU_VS_SNPS_UDPI__unlockSw_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__unlockSw_out_port", 15, "ZEBU_VS_SNPS_UDPI__unlockSw_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__rst_deassert_in_port", 16, "ZEBU_VS_SNPS_UDPI__rst_deassert_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__rst_deassert_out_port", 16, "ZEBU_VS_SNPS_UDPI__rst_deassert_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__rst_assert_in_port", 17, "ZEBU_VS_SNPS_UDPI__rst_assert_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__rst_assert_out_port", 17, "ZEBU_VS_SNPS_UDPI__rst_assert_out_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_in_port", 18, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_in_port", 1, (char *)0, "reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_out_port", 18, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_out_port", 32, (char *)0, "reset_and_clock_i");
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler1 (14);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__clkTick_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__clkTick_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__clkTick_out_port", 1, "ZEBU_VS_SNPS_UDPI__clkTick_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler2 (15);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__unlockSw_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__unlockSw_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__unlockSw_out_port", 1, "ZEBU_VS_SNPS_UDPI__unlockSw_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler3 (16);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_deassert_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_deassert_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__rst_deassert_out_port", 1, "ZEBU_VS_SNPS_UDPI__rst_deassert_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler4 (17);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_assert_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_assert_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__rst_assert_out_port", 1, "ZEBU_VS_SNPS_UDPI__rst_assert_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler5 (18);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__BuildSerialNumber_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__BuildSerialNumber_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_out_port", 32, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler6 (19);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_out_port", 32, "ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler7 (20);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_out_port", 1, "ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler8 (21);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_out_port", 1, "ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler9 (22);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__read_resp_tx_wait_counter");
		this->addImport (hdlr, "zemi3_anon_ps2_arbiter", 579, (char*)0, 0, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler10 (23);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp_rx_wait_counter");
		this->addImport (hdlr, "zemi3_anon_ps2_arbiter", 579, "ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler11 (24);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__write_resp_tx_wait_counter");
		this->addImport (hdlr, "zemi3_anon_ps1_arbiter", 66, (char*)0, 0, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler12 (25);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp_rx_wait_counter");
		this->addImport (hdlr, "zemi3_anon_ps1_arbiter", 66, "ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler13 (26);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port", 32, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler13 (27);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_tx_wait_counter_0");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_rx_wait_counter_0");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_0", 32, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_0", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler13 (28);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_tx_wait_counter_1");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_rx_wait_counter_1");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_1", 32, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_1", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler13 (29);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_tx_wait_counter_2");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_rx_wait_counter_2");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_2", 32, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_2", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler13 (30);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_tx_wait_counter_3");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_MASTER_error__notifier_rx_wait_counter_3");
		this->addImport (hdlr, "ZEBU_VS_AMBA_MASTER_error__notifier_out_port_3", 32, "ZEBU_VS_AMBA_MASTER_error__notifier_in_port_3", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler1;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__getconfig_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_AMBA_MASTER_dpi__getconfig_out_port", 544, "ZEBU_VS_AMBA_MASTER_dpi__getconfig_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler2;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_AMBA_MASTER_dpi__driveRready_in_port", 32, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler3;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_AMBA_MASTER_dpi__driveBready_in_port", 32, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler4;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_AMBA_MASTER_dpi__setparam_in_port", 64, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler5;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 151);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_MASTER_dpi__getResetStatus_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_AMBA_MASTER_dpi__getResetStatus_out_port", 32, "ZEBU_VS_AMBA_MASTER_dpi__getResetStatus_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler6;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 150, "swtohw_AR");
		hdlr = new ZEMI3ExportHandler6;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 150, "swtohw_AW");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler7;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2516, "wr_data_schd.gen_wdata_fifo_0__swtohw_W");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler8;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__waitResetComplete_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__waitResetComplete_out_port", 1, "ZEBU_VS_SNPS_UDPI__waitResetComplete_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler9;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__runClk_sw_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__runClk_sw_out_port", 1, "ZEBU_VS_SNPS_UDPI__runClk_sw_in_port", 32, "reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler10;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__resetDetectEnable_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_out_port", 1, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler11;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__getClkCount_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__getClkCount_out_port", 65, "ZEBU_VS_SNPS_UDPI__getClkCount_in_port", 1, "reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler12;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_out_port", 1, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_in_port", 32, "reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler13;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__setTickPeriod_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__setTickPeriod_out_port", 1, "ZEBU_VS_SNPS_UDPI__setTickPeriod_in_port", 32, "reset_and_clock_i");
	}
}

} // of namespace

extern "C" void *xtor_amba_master_axi3_svs_init ()
{
	return (void *)(new ZEMI3_USER::xtor_amba_master_axi3_svs);
}

