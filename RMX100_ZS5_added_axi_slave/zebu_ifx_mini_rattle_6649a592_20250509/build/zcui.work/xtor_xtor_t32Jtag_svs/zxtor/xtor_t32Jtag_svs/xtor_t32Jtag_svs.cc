// Following needed to suppress b0, b1 defines
#define ZEBU_NDEF_BINARY_VALUE

#include <string.h>
#include "xtor_t32Jtag_svs.h"
#include "libZebuZEMI3.hh"

using namespace ZEBU;

// Anonymous namespace
namespace {

class ZEMI3ImportHandler25 : public ZEMI3ImportHandler {
	typedef unsigned char (*DPI_FUNC_TYPE) (const svBitVecVal* _arg_reset_data);
public:
	ZEMI3ImportHandler25 (unsigned int zemi3_func_id) :
		ZEMI3ImportHandler ("zebu_jtag_xtor__output_reset_message", zemi3_func_id)
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
				svBitVecVal *_arg_reset_data = (svBitVecVal*)actual;
				getSlice (_arg_reset_data, 1, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/void putReturnValue (const void *actual, ZEMI3ArgType argType)
	{
		if (!checkTypeMatch (-1, argType, LOGIC_TYPE))
			return;
		const unsigned char *_zebu_jtag_xtor__output_reset_message_retval = (const unsigned char*)actual;
		putSmallSlice (*_zebu_jtag_xtor__output_reset_message_retval, 0, 0);
	}

	/*redef*/int run ()
	{
		static DPI_FUNC_TYPE dpi_func = (DPI_FUNC_TYPE)this->getDpiFunction ();
		if (dpi_func != 0)
		{
			ZEMI3ImportHandler *handler = (ZEMI3ImportHandler*)this;
			svBitVecVal _arg_reset_data[SV_PACKED_DATA_NELEMS(2)];
			memset ((void*)_arg_reset_data, 0, sizeof(svBitVecVal) * SV_PACKED_DATA_NELEMS(2));
			handler->getArgValue (0, (void*)_arg_reset_data, BITVEC_TYPE);
			handler->setIsCalledFromZemi3ContextImportFunc (true);
			handler->enter ();
			unsigned char _zebu_jtag_xtor__output_reset_message_retval =  dpi_func (_arg_reset_data);
			handler->leave ();
			handler->setIsCalledFromZemi3ContextImportFunc (false);
			handler->putReturnValue ((const void*)&_zebu_jtag_xtor__output_reset_message_retval, LOGIC_TYPE);
		}
		return 0;
	}
};

class ZEMI3ExportHandler28 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler28 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__get_config", 61)
	{
		this->setIsTask();
		this->setArgCount(1);
	}
	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, LOGICVEC_TYPE))
					return;
				svLogicVecVal *_arg_config_data = (svLogicVecVal*)actual;
				getSlice (_arg_config_data, 63, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler29 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler29 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__set_signals", 62)
	{
		this->setIsTask();
		this->setArgCount(2);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_signals = (const int*)actual;
				putSmallSlice (*_arg_signals, 31, 0);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_mask = (const int*)actual;
				putSmallSlice (*_arg_mask, 63, 32);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler30 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler30 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__force_trst", 63)
	{
		this->setIsTask();
		this->setArgCount(0);
	}
};

class ZEMI3ExportHandler31 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler31 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__hard_reset", 64)
	{
		this->setIsTask();
		this->setArgCount(0);
	}
};

class ZEMI3ExportHandler32 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler32 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__send_and_receive", 65)
	{
		this->setIsTask();
		this->setArgCount(4);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, LONGINT_TYPE))
					return;
				const long long *_arg_tdi = (const long long*)actual;
				putLongSlice (*_arg_tdi, 63, 0);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, LONGINT_TYPE))
					return;
				const long long *_arg_tms = (const long long*)actual;
				putLongSlice (*_arg_tms, 127, 64);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_cycle_count = (const int*)actual;
				putSmallSlice (*_arg_cycle_count, 159, 128);
			}
			break;
		case (3):
			reportInvalidDirection (pos, "put");
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

	/*redef*/void getArgValue (unsigned int pos, void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			reportInvalidDirection (pos, "get");
			break;
		case (1):
			reportInvalidDirection (pos, "get");
			break;
		case (2):
			reportInvalidDirection (pos, "get");
			break;
		case (3):
			{
				if (!checkTypeMatch (pos, argType, BITVEC_TYPE))
					return;
				svBitVecVal *_arg_tdo = (svBitVecVal*)actual;
				getSlice (_arg_tdo, 63, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler33 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler33 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__run", 66)
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
				const int *_arg_cycle = (const int*)actual;
				putSmallSlice (*_arg_cycle, 31, 0);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler34 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler34 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__runUntilReset", 67)
	{
		this->setIsTask();
		this->setArgCount(0);
	}
};

class ZEMI3ExportHandler35 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler35 () :
		ZEMI3ExportHandler ("ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw", 68)
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

class ZEMI3ExportHandler36 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler36 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__config", 69)
	{
		this->setArgCount(4);
	}
	/*redef*/void putArgValue (unsigned int pos, const void *actual, ZEMI3ArgType argType)
	{
		switch (pos) {

		case (0):
			{
				if (!checkTypeMatch (pos, argType, BIT_TYPE))
					return;
				const svBit *_arg_trst = (const svBit*)actual;
				putSmallSlice (*_arg_trst, 32, 32);
			}
			break;
		case (1):
			{
				if (!checkTypeMatch (pos, argType, BIT_TYPE))
					return;
				const svBit *_arg_rtck = (const svBit*)actual;
				putSmallSlice (*_arg_rtck, 33, 33);
			}
			break;
		case (2):
			{
				if (!checkTypeMatch (pos, argType, INT_TYPE))
					return;
				const int *_arg_ratio_val = (const int*)actual;
				putSmallSlice (*_arg_ratio_val, 31, 0);
			}
			break;
		case (3):
			{
				if (!checkTypeMatch (pos, argType, BIT_TYPE))
					return;
				const svBit *_arg_shiftTDO = (const svBit*)actual;
				putSmallSlice (*_arg_shiftTDO, 34, 34);
			}
			break;
		default:
			reportInvalidArg (pos);
			break;
		} /* of switch */
	}

};

class ZEMI3ExportHandler37 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler37 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__get_cycles", 70)
	{
		this->setArgCount(0);
	}
	/*redef*/void getReturnValue (void *actual, ZEMI3ArgType argType)
	{
		if (!checkTypeMatch (-1, argType, LONGINT_TYPE))
			return;
		long long *_zebu_jtag_xtor__get_cycles_retval = (long long*)actual;
		*_zebu_jtag_xtor__get_cycles_retval = getLongSlice (63, 0);
	}

};

class ZEMI3ExportHandler38 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler38 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__get_signals", 71)
	{
		this->setArgCount(0);
	}
	/*redef*/void getReturnValue (void *actual, ZEMI3ArgType argType)
	{
		if (!checkTypeMatch (-1, argType, BYTE_TYPE))
			return;
		char *_zebu_jtag_xtor__get_signals_retval = (char*)actual;
		*_zebu_jtag_xtor__get_signals_retval = getSmallSlice (7, 0);
	}

};

class ZEMI3ExportHandler39 : public ZEMI3ExportHandler
{
public:
	ZEMI3ExportHandler39 () :
		ZEMI3ExportHandler ("zebu_jtag_xtor__is_reset_active", 72)
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
				int *_arg_reset_check = (int*)actual;
				*_arg_reset_check = getSmallSlice (31, 0);
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
		unsigned char *_zebu_jtag_xtor__is_reset_active_retval = (unsigned char*)actual;
		*_zebu_jtag_xtor__is_reset_active_retval = getSmallSlice (32, 32);
	}

};

extern "C" int zebu_jtag_xtor__get_config (svLogicVecVal* _arg_config_data)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__get_config");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getArgValue (0, (void*)_arg_config_data, LOGICVEC_TYPE);
		handler->leave ();
	}
	return 0;
}

extern "C" int zebu_jtag_xtor__set_signals (int _arg_signals, int _arg_mask)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__set_signals");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->errorOutExportHangScenario ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_signals, INT_TYPE);
		handler->putArgValue (1, (void*)&_arg_mask, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
	return 0;
}

extern "C" int zebu_jtag_xtor__force_trst ()
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__force_trst");
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

extern "C" int zebu_jtag_xtor__hard_reset ()
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__hard_reset");
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

extern "C" int zebu_jtag_xtor__send_and_receive (long long _arg_tdi, long long _arg_tms, int _arg_cycle_count, svBitVecVal* _arg_tdo)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__send_and_receive");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->errorOutExportHangScenario ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_tdi, LONGINT_TYPE);
		handler->putArgValue (1, (void*)&_arg_tms, LONGINT_TYPE);
		handler->putArgValue (2, (void*)&_arg_cycle_count, INT_TYPE);
		handler->doCall ();
		handler->getArgValue (3, (void*)_arg_tdo, BITVEC_TYPE);
		handler->leave ();
	}
	return 0;
}

extern "C" int zebu_jtag_xtor__run (int _arg_cycle)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__run");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->errorOutExportHangScenario ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_cycle, INT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
	return 0;
}

extern "C" int zebu_jtag_xtor__runUntilReset ()
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__runUntilReset");
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

extern "C" int ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw (unsigned int _arg_numclock)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw");
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

extern "C" void zebu_jtag_xtor__config (svBit _arg_trst, svBit _arg_rtck, int _arg_ratio_val, svBit _arg_shiftTDO)
{
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__config");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putArgValue (0, (void*)&_arg_trst, BIT_TYPE);
		handler->putArgValue (1, (void*)&_arg_rtck, BIT_TYPE);
		handler->putArgValue (2, (void*)&_arg_ratio_val, INT_TYPE);
		handler->putArgValue (3, (void*)&_arg_shiftTDO, BIT_TYPE);
		handler->doCall ();
		handler->leave ();
	}
}

extern "C" long long zebu_jtag_xtor__get_cycles ()
{
	long long _zebu_jtag_xtor__get_cycles_retval = 0;
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__get_cycles");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getReturnValue ((void*)&_zebu_jtag_xtor__get_cycles_retval, LONGINT_TYPE);
		handler->leave ();
	}
	return _zebu_jtag_xtor__get_cycles_retval;
}

extern "C" char zebu_jtag_xtor__get_signals ()
{
	char _zebu_jtag_xtor__get_signals_retval = 0;
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__get_signals");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getReturnValue ((void*)&_zebu_jtag_xtor__get_signals_retval, BYTE_TYPE);
		handler->leave ();
	}
	return _zebu_jtag_xtor__get_signals_retval;
}

extern "C" unsigned char zebu_jtag_xtor__is_reset_active (int* _arg_reset_check)
{
	unsigned char _zebu_jtag_xtor__is_reset_active_retval = 0;
	ZEMI3ExportHandler *handler = ZEMI3ExportHandler::getHandler ("zebu_jtag_xtor__is_reset_active");
	if (handler) {
		handler->errorOutExportCalledFromZDpi ();
		handler->enter ();
		handler->putSmallSlice (0, 0, 0);
		handler->doCall ();
		handler->getArgValue (0, (void*)_arg_reset_check, INT_TYPE);
		handler->getReturnValue ((void*)&_zebu_jtag_xtor__is_reset_active_retval, LOGIC_TYPE);
		handler->leave ();
	}
	return _zebu_jtag_xtor__is_reset_active_retval;
}

} // of anonymous namespace

namespace ZEMI3_USER {

xtor_t32Jtag_svs::xtor_t32Jtag_svs () : ZEBU::ZEMI3Xtor ("xtor_t32Jtag_svs")
{
	this->addPort ("TxPort", "zebu_jtag_xtor__get_config_in_port", 61, "zebu_jtag_xtor__get_config_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "zebu_jtag_xtor__get_config_out_port", 61, "zebu_jtag_xtor__get_config_out_port", 64, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__set_signals_in_port", 62, "zebu_jtag_xtor__set_signals_in_port", 64, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__force_trst_in_port", 63, "zebu_jtag_xtor__force_trst_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__hard_reset_in_port", 64, "zebu_jtag_xtor__hard_reset_in_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__send_and_receive_in_port", 65, "zebu_jtag_xtor__send_and_receive_in_port", 160, (char *)0, (char *)0);
	this->addPort ("RxPort", "zebu_jtag_xtor__send_and_receive_out_port", 65, "zebu_jtag_xtor__send_and_receive_out_port", 64, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__run_in_port", 66, "zebu_jtag_xtor__run_in_port", 32, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__runUntilReset_in_port", 67, "zebu_jtag_xtor__runUntilReset_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "zebu_jtag_xtor__runUntilReset_out_port", 67, "zebu_jtag_xtor__runUntilReset_out_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw_in_port", 68, "ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw_in_port", 32, (char *)0, (char *)0);
	this->addPort ("RxPort", "ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw_out_port", 68, "ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw_out_port", 1, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__config_in_port", 69, "zebu_jtag_xtor__config_in_port", 35, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__get_cycles_in_port", 70, "zebu_jtag_xtor__get_cycles_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "zebu_jtag_xtor__get_cycles_out_port", 70, "zebu_jtag_xtor__get_cycles_out_port", 64, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__get_signals_in_port", 71, "zebu_jtag_xtor__get_signals_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "zebu_jtag_xtor__get_signals_out_port", 71, "zebu_jtag_xtor__get_signals_out_port", 8, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__is_reset_active_in_port", 72, "zebu_jtag_xtor__is_reset_active_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "zebu_jtag_xtor__is_reset_active_out_port", 72, "zebu_jtag_xtor__is_reset_active_out_port", 33, (char *)0, (char *)0);
	this->addPort ("TxPort", "zebu_jtag_xtor__output_reset_message_in_port", 73, "zebu_jtag_xtor__output_reset_message_in_port", 1, (char *)0, (char *)0);
	this->addPort ("RxPort", "zebu_jtag_xtor__output_reset_message_out_port", 73, "zebu_jtag_xtor__output_reset_message_out_port", 2, (char *)0, (char *)0);
	this->addPort ("TxPort", "zemi_control_in_port", 0, "zemi_control_in_port", 6, (char *)0, (char *)0);
	this->addPort ("RxPort", "zemi_status_out_port", 0, "zemi_status_out_port", 3, (char *)0, (char *)0);
	this->setControlStatusInfo (0, "zemi_control_in_port", "zemi_status_out_port");
	{
		ZEMI3ImportHandler *hdlr;
		hdlr = new ZEMI3ImportHandler25 (73);
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("zebu_jtag_xtor__output_reset_message_tx_wait_counter");
		hdlr->setRxWaitCounter ("zebu_jtag_xtor__output_reset_message_rx_wait_counter");
		this->addImport (hdlr, "zebu_jtag_xtor__output_reset_message_out_port", 2, "zebu_jtag_xtor__output_reset_message_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler28;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("zebu_jtag_xtor__get_config_tx_wait_counter");
		this->addExport (hdlr, "zebu_jtag_xtor__get_config_out_port", 64, "zebu_jtag_xtor__get_config_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler29;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		this->addExport (hdlr, (char*)0, 0, "zebu_jtag_xtor__set_signals_in_port", 64, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler30;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		this->addExport (hdlr, (char*)0, 0, "zebu_jtag_xtor__force_trst_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler31;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		this->addExport (hdlr, (char*)0, 0, "zebu_jtag_xtor__hard_reset_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler32;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("zebu_jtag_xtor__send_and_receive_tx_wait_counter");
		this->addExport (hdlr, "zebu_jtag_xtor__send_and_receive_out_port", 64, "zebu_jtag_xtor__send_and_receive_in_port", 160, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler33;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		this->addExport (hdlr, (char*)0, 0, "zebu_jtag_xtor__run_in_port", 32, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler34;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("zebu_jtag_xtor__runUntilReset_tx_wait_counter");
		this->addExport (hdlr, "zebu_jtag_xtor__runUntilReset_out_port", 1, "zebu_jtag_xtor__runUntilReset_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler35;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw_tx_wait_counter");
		this->addExport (hdlr, "ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw_out_port", 1, "ZEBU_SNPS_JTAG_PROTOCOL_DPI__runClk_sw_in_port", 32, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler36;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		this->addExport (hdlr, (char*)0, 0, "zebu_jtag_xtor__config_in_port", 35, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler37;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("zebu_jtag_xtor__get_cycles_tx_wait_counter");
		this->addExport (hdlr, "zebu_jtag_xtor__get_cycles_out_port", 64, "zebu_jtag_xtor__get_cycles_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler38;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("zebu_jtag_xtor__get_signals_tx_wait_counter");
		this->addExport (hdlr, "zebu_jtag_xtor__get_signals_out_port", 8, "zebu_jtag_xtor__get_signals_in_port", 1, (char*)0);
	}
	{
		ZEMI3ExportHandler *hdlr;
		hdlr = new ZEMI3ExportHandler39;
		hdlr->setContextInfo ("/global/apps/zebu_vs_2023.03-SP1//vlog/vcs/xtor_t32Jtag_svs.v", 50);
		hdlr->setTxWaitCounter ("zebu_jtag_xtor__is_reset_active_tx_wait_counter");
		this->addExport (hdlr, "zebu_jtag_xtor__is_reset_active_out_port", 33, "zebu_jtag_xtor__is_reset_active_in_port", 1, (char*)0);
	}
}

} // of namespace

extern "C" void *xtor_t32Jtag_svs_init ()
{
	return (void *)(new ZEMI3_USER::xtor_t32Jtag_svs);
}

