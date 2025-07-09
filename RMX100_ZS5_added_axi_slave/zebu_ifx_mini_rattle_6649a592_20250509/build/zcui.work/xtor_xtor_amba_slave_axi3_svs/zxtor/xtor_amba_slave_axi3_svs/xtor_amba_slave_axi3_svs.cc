// Following needed to suppress b0, b1 defines
#define ZEBU_NDEF_BINARY_VALUE

#include <string.h>
#include "xtor_amba_slave_axi3_svs.h"
#include "libZebuZEMI3.hh"

using namespace ZEBU;

// Anonymous namespace
namespace {

class ZEMI3ImportHandler21 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_error_code);
public:
	ZEMI3ImportHandler21 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_SLAVE_error__notifier", zemi3_func_id)
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

class ZEMI3ImportHandler24 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (const svBitVecVal* _arg_AW_txn, const svBitVecVal* _arg_global_counter);
public:
	ZEMI3ImportHandler24 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__write_addr", zemi3_func_id)
	{
		this->setArgCount(2);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_AW_txn = (svBitVecVal*)actual;
				getSlice (_arg_AW_txn, 121, 64);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_global_counter = (svBitVecVal*)actual;
				getSlice (_arg_global_counter, 63, 0);
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
			svBitVecVal _arg_AW_txn[SV_PACKED_DATA_NELEMS(58)];
			svBitVecVal _arg_global_counter[SV_PACKED_DATA_NELEMS(64)];
			memset ((void*)_arg_AW_txn, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(58));
			memset ((void*)_arg_global_counter, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(64));
			handler->getArgValue (0, (void*)_arg_AW_txn, BITVEC_TYPE);
			handler->getArgValue (1, (void*)_arg_global_counter, BITVEC_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_AW_txn, _arg_global_counter);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler23 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (const svBitVecVal* _arg_WDATA_txn, const svBitVecVal* _arg_global_counter);
public:
	ZEMI3ImportHandler23 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__write_data", zemi3_func_id)
	{
		this->setArgCount(2);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_WDATA_txn = (svBitVecVal*)actual;
				getSlice (_arg_WDATA_txn, 152, 64);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_global_counter = (svBitVecVal*)actual;
				getSlice (_arg_global_counter, 63, 0);
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
			svBitVecVal _arg_WDATA_txn[SV_PACKED_DATA_NELEMS(89)];
			svBitVecVal _arg_global_counter[SV_PACKED_DATA_NELEMS(64)];
			memset ((void*)_arg_WDATA_txn, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(89));
			memset ((void*)_arg_global_counter, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(64));
			handler->getArgValue (0, (void*)_arg_WDATA_txn, BITVEC_TYPE);
			handler->getArgValue (1, (void*)_arg_global_counter, BITVEC_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_WDATA_txn, _arg_global_counter);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler22 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (const svBitVecVal* _arg_AR_txn, const svBitVecVal* _arg_global_counter);
public:
	ZEMI3ImportHandler22 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__read_addr", zemi3_func_id)
	{
		this->setArgCount(2);
		this->setIsContext ();
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_AR_txn = (svBitVecVal*)actual;
				getSlice (_arg_AR_txn, 121, 64);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_global_counter = (svBitVecVal*)actual;
				getSlice (_arg_global_counter, 63, 0);
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
			svBitVecVal _arg_AR_txn[SV_PACKED_DATA_NELEMS(58)];
			svBitVecVal _arg_global_counter[SV_PACKED_DATA_NELEMS(64)];
			memset ((void*)_arg_AR_txn, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(58));
			memset ((void*)_arg_global_counter, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(64));
			handler->getArgValue (0, (void*)_arg_AR_txn, BITVEC_TYPE);
			handler->getArgValue (1, (void*)_arg_global_counter, BITVEC_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_AR_txn, _arg_global_counter);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler20 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_rid);
public:
	ZEMI3ImportHandler20 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__read_fifo", zemi3_func_id)
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
				int *_arg_rid = (int*)actual;
				*_arg_rid = getSmallSlice (31, 0);
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
			handler->getArgValue (0, (void*)&_arg_rid, INT_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			dpi_func (_arg_rid);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
		}
		return 0;
	}
};

class ZEMI3ImportHandler19 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (int _arg_wid);
public:
	ZEMI3ImportHandler19 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__write_fifo", zemi3_func_id)
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

class ZEMI3ImportHandler18 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) (const svBitVecVal* _arg_data);
public:
	ZEMI3ImportHandler18 (unsigned int zemi3_func_id) :
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

class ZEMI3ImportHandler17 : public ZEMI3ImportHandler {
	typedef int (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler17 (unsigned int zemi3_func_id) :
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

class ZEMI3ImportHandler16 : public ZEMI3ImportHandler {
	typedef int (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler16 (unsigned int zemi3_func_id) :
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

class ZEMI3ImportHandler15 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler15 (unsigned int zemi3_func_id) :
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

class ZEMI3ImportHandler14 : public ZEMI3ImportHandler {
	typedef void (*DPI_FUNC_TYPE) ();
public:
	ZEMI3ImportHandler14 (unsigned int zemi3_func_id) :
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

class ZEMI3ExportHandler14 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler14 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__getconfig", 33)
	{
		this->setArgCount(15);
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
				int *_arg_is_haps = (int*)actual;
				*_arg_is_haps = getSmallSlice (351, 320);
			}
			break;
		case (11):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_loop_w_width = (int*)actual;
				*_arg_loop_w_width = getSmallSlice (383, 352);
			}
			break;
		case (12):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_loop_r_width = (int*)actual;
				*_arg_loop_r_width = getSmallSlice (415, 384);
			}
			break;
		case (13):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_sid_width = (int*)actual;
				*_arg_sid_width = getSmallSlice (447, 416);
			}
			break;
		case (14):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				int *_arg_ssid_width = (int*)actual;
				*_arg_ssid_width = getSmallSlice (479, 448);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler15 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler15 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__driveARready", 34)
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
				const svBit *_arg_value = (const svBit*)actual;
				putSmallSlice (*_arg_value, 0, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler16 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler16 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__driveAWready", 35)
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
				const svBit *_arg_value = (const svBit*)actual;
				putSmallSlice (*_arg_value, 0, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler17 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler17 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__driveWready", 36)
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
				const svBit *_arg_value = (const svBit*)actual;
				putSmallSlice (*_arg_value, 0, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler18 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler18 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__setparam", 37)
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

class ZEMI3ExportHandler19 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler19 () :
		ZEMI3ExportHandler ("ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus", 38)
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

class ZEMI3ExportHandler20 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler20 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__waitResetComplete", 39)
	{
		this->setIsTask();
		this->setArgCount(0);
	}
};

class ZEMI3ExportHandler21 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler21 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__runClk_sw", 40)
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

class ZEMI3ExportHandler22 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler22 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__resetDetectEnable", 41)
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

class ZEMI3ExportHandler23 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler23 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__getClkCount", 42)
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

class ZEMI3ExportHandler24 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler24 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod", 43)
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

class ZEMI3ExportHandler25 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler25 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__setTickPeriod", 44)
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

class ZEMI3ExportHandler26 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler26 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__fromSwtoHwData", 45)
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
				putSlice (_arg_sw_message, 179, 64);
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

class ZEMI3ExportHandler27 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler27 () :
		ZEMI3ExportHandler ("ZEBU_VS_SNPS_UDPI__fromSwtoHwData", 46)
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
				putSlice (_arg_sw_message, 2959, 64);
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

extern "C" void ZEBU_VS_AMBA_SLAVE_dpi__getconfig (int* _arg_amba_mode, int* _arg_data_width, int* _arg_addr_width, int* _arg_id_w_width, int* _arg_id_r_width, int* _arg_blen_width, int* _arg_interleave_depth, int* _arg_user_req_width, int* _arg_user_data_width, int* _arg_user_resp_width, int* _arg_is_haps, int* _arg_loop_w_width, int* _arg_loop_r_width, int* _arg_sid_width, int* _arg_ssid_width)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_SLAVE_dpi__getconfig");
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
		handler->getArgValue (10, (void*)_arg_is_haps, INT_TYPE);
		handler->getArgValue (11, (void*)_arg_loop_w_width, INT_TYPE);
		handler->getArgValue (12, (void*)_arg_loop_r_width, INT_TYPE);
		handler->getArgValue (13, (void*)_arg_sid_width, INT_TYPE);
		handler->getArgValue (14, (void*)_arg_ssid_width, INT_TYPE);
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_SLAVE_dpi__driveARready (svBit _arg_value)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_SLAVE_dpi__driveARready");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_value, BIT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_SLAVE_dpi__driveAWready (svBit _arg_value)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_SLAVE_dpi__driveAWready");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_value, BIT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_SLAVE_dpi__driveWready (svBit _arg_value)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_SLAVE_dpi__driveWready");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_value, BIT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_SLAVE_dpi__setparam (int _arg_param, int _arg_val)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_SLAVE_dpi__setparam");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_param, INT_TYPE);
		handler->putArgValue (1, (void*)&_arg_val, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" void ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus (int* _arg_value)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getArgValue (0, (void*)_arg_value, INT_TYPE);
		handler->leave ();
	}
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

} // of anonymous namespace

namespace ZEMI3_USER {

xtor_amba_slave_axi3_svs::xtor_amba_slave_axi3_svs () : ZEBU::ZEMI3Xtor ("xtor_amba_slave_axi3_svs")
{
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__getconfig_in_port", 33, "ZEBU_VS_AMBA_SLAVE_dpi__getconfig_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_dpi__getconfig_out_port", 33, "ZEBU_VS_AMBA_SLAVE_dpi__getconfig_out_port", 480, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__driveARready_in_port", 34, "ZEBU_VS_AMBA_SLAVE_dpi__driveARready_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__driveAWready_in_port", 35, "ZEBU_VS_AMBA_SLAVE_dpi__driveAWready_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__driveWready_in_port", 36, "ZEBU_VS_AMBA_SLAVE_dpi__driveWready_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__setparam_in_port", 37, "ZEBU_VS_AMBA_SLAVE_dpi__setparam_in_port", 64, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus_in_port", 38, "ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus_out_port", 38, "ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus_out_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_in_port", 52, "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_out_port", 52, "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_out_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_in_port", 53, "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_out_port", 53, "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_out_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port", 54, "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port", 54, "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port_0", 55, "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port_0", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port_0", 55, "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port_0", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port_1", 56, "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port_1", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port_1", 56, "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port_1", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__read_addr_in_port", 57, "ZEBU_VS_AMBA_SLAVE_dpi__read_addr_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_VS_AMBA_SLAVE_dpi__read_addr_out_port", 57, "ZEBU_VS_AMBA_SLAVE_dpi__read_addr_out_port", 122, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__write_data_in_port", 58, "ZEBU_VS_AMBA_SLAVE_dpi__write_data_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_VS_AMBA_SLAVE_dpi__write_addr_in_port", 59, "ZEBU_VS_AMBA_SLAVE_dpi__write_addr_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxProtocol", "zemi3_anon_ps3_arbiter", 60, "zemi3_anon_ps3_out_port", 192, (char *)0, (char *)0);
	this->addPort ("TxPort", "zemi_control_in_port", 0, "zemi_control_in_port", 6, (char *)0, (char *)0);
	this->addPort ("RxPort", "zemi_status_out_port", 0, "zemi_status_out_port", 3, (char *)0, (char *)0);
	this->setControlStatusInfo (0, "zemi_control_in_port", "zemi_status_out_port");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__waitResetComplete_in_port", 39, "ZEBU_VS_SNPS_UDPI__waitResetComplete_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__waitResetComplete_out_port", 39, "ZEBU_VS_SNPS_UDPI__waitResetComplete_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__runClk_sw_in_port", 40, "ZEBU_VS_SNPS_UDPI__runClk_sw_in_port", 32, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__runClk_sw_out_port", 40, "ZEBU_VS_SNPS_UDPI__runClk_sw_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__resetDetectEnable_in_port", 41, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__resetDetectEnable_out_port", 41, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__getClkCount_in_port", 42, "ZEBU_VS_SNPS_UDPI__getClkCount_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__getClkCount_out_port", 42, "ZEBU_VS_SNPS_UDPI__getClkCount_out_port", 65, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_in_port", 43, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_in_port", 32, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_out_port", 43, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__setTickPeriod_in_port", 44, "ZEBU_VS_SNPS_UDPI__setTickPeriod_in_port", 32, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__setTickPeriod_out_port", 44, "ZEBU_VS_SNPS_UDPI__setTickPeriod_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__clkTick_in_port", 47, "ZEBU_VS_SNPS_UDPI__clkTick_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__clkTick_out_port", 47, "ZEBU_VS_SNPS_UDPI__clkTick_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__unlockSw_in_port", 48, "ZEBU_VS_SNPS_UDPI__unlockSw_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__unlockSw_out_port", 48, "ZEBU_VS_SNPS_UDPI__unlockSw_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__rst_deassert_in_port", 49, "ZEBU_VS_SNPS_UDPI__rst_deassert_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__rst_deassert_out_port", 49, "ZEBU_VS_SNPS_UDPI__rst_deassert_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__rst_assert_in_port", 50, "ZEBU_VS_SNPS_UDPI__rst_assert_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__rst_assert_out_port", 50, "ZEBU_VS_SNPS_UDPI__rst_assert_out_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_in_port", 51, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_in_port", 1, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("RxPort", "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_out_port", 51, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_out_port", 32, (char *)0, "slave_reset_and_clock_i");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 45, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 180, (char *)0, "swtohw_BRESP");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_0__swtohw_R");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_1__swtohw_R");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_2__swtohw_R");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_3__swtohw_R");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_4__swtohw_R");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_5__swtohw_R");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_6__swtohw_R");
	this->addPort ("TxPort", "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 46, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, (char *)0, "read_data_schd.gen_rdata_fifo_7__swtohw_R");
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler14 (47);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__clkTick_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__clkTick_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__clkTick_out_port", 1, "ZEBU_VS_SNPS_UDPI__clkTick_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler15 (48);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__unlockSw_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__unlockSw_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__unlockSw_out_port", 1, "ZEBU_VS_SNPS_UDPI__unlockSw_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler16 (49);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_deassert_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_deassert_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__rst_deassert_out_port", 1, "ZEBU_VS_SNPS_UDPI__rst_deassert_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler17 (50);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_assert_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__rst_assert_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__rst_assert_out_port", 1, "ZEBU_VS_SNPS_UDPI__rst_assert_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler18 (51);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__BuildSerialNumber_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_SNPS_UDPI__BuildSerialNumber_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_out_port", 32, "ZEBU_VS_SNPS_UDPI__BuildSerialNumber_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler19 (52);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_out_port", 32, "ZEBU_VS_AMBA_SLAVE_dpi__write_fifo_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler20 (53);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_out_port", 32, "ZEBU_VS_AMBA_SLAVE_dpi__read_fifo_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler21 (54);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_error__notifier_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_error__notifier_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port", 32, "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler21 (55);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_error__notifier_tx_wait_counter_0");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_error__notifier_rx_wait_counter_0");
		this->addImport (hdlr, "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port_0", 32, "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port_0", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler21 (56);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_error__notifier_tx_wait_counter_1");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_error__notifier_rx_wait_counter_1");
		this->addImport (hdlr, "ZEBU_VS_AMBA_SLAVE_error__notifier_out_port_1", 32, "ZEBU_VS_AMBA_SLAVE_error__notifier_in_port_1", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler22 (57);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__read_addr_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__read_addr_rx_wait_counter");
		this->addImport (hdlr, "ZEBU_VS_AMBA_SLAVE_dpi__read_addr_out_port", 122, "ZEBU_VS_AMBA_SLAVE_dpi__read_addr_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler23 (58);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__write_data_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__write_data_rx_wait_counter");
		this->addImport (hdlr, "zemi3_anon_ps3_arbiter", 153, "ZEBU_VS_AMBA_SLAVE_dpi__write_data_in_port", 1, (char*)0);
	}
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler24 (59);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__write_addr_tx_wait_counter");
		hdlr->setRxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__write_addr_rx_wait_counter");
		this->addImport (hdlr, "zemi3_anon_ps3_arbiter", 122, "ZEBU_VS_AMBA_SLAVE_dpi__write_addr_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler14;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__getconfig_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_AMBA_SLAVE_dpi__getconfig_out_port", 480, "ZEBU_VS_AMBA_SLAVE_dpi__getconfig_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler15;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__driveARready_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler16;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__driveAWready_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler17;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__driveWready_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler18;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_AMBA_SLAVE_dpi__setparam_in_port", 64, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler19;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_slave_axi3_svs.sv", 119);
		hdlr->setTxWaitCounter ("ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus_out_port", 32, "ZEBU_VS_AMBA_SLAVE_dpi__getResetStatus_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler20;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__waitResetComplete_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__waitResetComplete_out_port", 1, "ZEBU_VS_SNPS_UDPI__waitResetComplete_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler21;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__runClk_sw_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__runClk_sw_out_port", 1, "ZEBU_VS_SNPS_UDPI__runClk_sw_in_port", 32, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler22;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__resetDetectEnable_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_out_port", 1, "ZEBU_VS_SNPS_UDPI__resetDetectEnable_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler23;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__getClkCount_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__getClkCount_out_port", 65, "ZEBU_VS_SNPS_UDPI__getClkCount_in_port", 1, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler24;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_out_port", 1, "ZEBU_VS_SNPS_UDPI__setUnlockSwPeriod_in_port", 32, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler25;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		hdlr->setTxWaitCounter ("ZEBU_VS_SNPS_UDPI__setTickPeriod_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_VS_SNPS_UDPI__setTickPeriod_out_port", 1, "ZEBU_VS_SNPS_UDPI__setTickPeriod_in_port", 32, "slave_reset_and_clock_i");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler26;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 180, "swtohw_BRESP");
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_0__swtohw_R");
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_1__swtohw_R");
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_2__swtohw_R");
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_3__swtohw_R");
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_4__swtohw_R");
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_5__swtohw_R");
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_6__swtohw_R");
		hdlr = new ZEMI3ExportHandler27;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_amba_master_axi3_svs.sv", 676);
		this->addExport (hdlr, (char*)0, 0, "ZEBU_VS_SNPS_UDPI__fromSwtoHwData_in_port", 2960, "read_data_schd.gen_rdata_fifo_7__swtohw_R");
	}
}

} // of namespace

extern "C" void *xtor_amba_slave_axi3_svs_init ()
{
	return (void *)(new ZEMI3_USER::xtor_amba_slave_axi3_svs);
}

