
package RV_debug;
typedef int unsigned UINT;
import "DPI-C" function string getenv(input string env_name);

// Data parameter type read or written in all the space interfaces.
`ifdef USE64
typedef longint unsigned Data;
`else
typedef     int unsigned Data;
`endif

virtual class Space_writer;
    // space = core, aux, mem
    typedef bit[1:0] Error_type;
    pure virtual task write_space(int space, UINT addr, Data value, output Error_type error);
    pure virtual task read_space(int space, UINT addr, output Data value, output Error_type error);
    // Default is to do nothing.
    virtual task switch_core(int core); endtask
    endclass
virtual class Debug_module_if;
    // DM bus interface.
    // Choose parameter names carefully!  Unlike C++, SV requires 
    // overriding functions to match the parameter names!  How dumb.
    pure virtual task write(UINT addr, UINT val);
    pure virtual task read(UINT addr, output UINT val, input int want_bits=32);
    endclass
virtual class Debug_module_jtag_if;
    pure virtual task take_transition(bit TMS, bit TDI, string where);
    pure virtual function read_TDO();
    endclass
typedef longint unsigned UINT64;
localparam 
    DM_CONTROL = 'h10,
    DM_STATUS  = 'h11,	// debug module status
    DM_ASTATUS = 'h16,	// abstract command status
    DM_COMMAND = 'h17,
    DM_AUTO    = 'h18,	// autoexec (exec prior command)
    DM_DATA0   = 'h4,
    DM_DATA1   = 'h5;
function string dm_regname(int r);
    case (r)
        DM_STATUS: 	return "dm_status";
        DM_CONTROL: 	return "dm_control";
	DM_ASTATUS: 	return "dm_astatus";
	DM_COMMAND: 	return "dm_command";
	DM_DATA0: 	return "dm_data0";
	DM_DATA1: 	return "dm_data1";
	DM_AUTO:	return "dm_auto";
	default: 	return $sformatf("?? %1x",r);
    endcase
    endfunction
function string dm_regformat(int r);
    // E.g. [04=dm_data0]
    return $psprintf("[%02x=%1s]",r,dm_regname(r));
    endfunction

// cmdtype field 31:24
localparam
    cmdtype_access_register = 0,
    cmdtype_access_memory = 2;
localparam
    CSR_BASE = 0,
    GPR_BASE = 'h1000,
    FPR_BASE = 'h1020,
    AUX_BASE = CSR_BASE;	// Treat AUX as CSR for now.
/*
    Read core/csr reg:
	command <= read reg N
	result <= data0
    Write core/csr reg:
    	data0 <= new value
	command < = write reg N
    Read word of memory:
        data1 <= addr
	command <= read memory
	result <= data0
    Write word of memory:
    	data1 <= addr
	data0 <= value
	command <= write memory
Register numbering:
    0x0000 - 0x0fff CSR
    0x1000 - 0x101f GPR
    0x1020 - 0x103f FPR
    0xc000 - 0xffff non-standard extensions
 */
    localparam
        ACC_MEM = 0,
	ACC_CSR = 1,
	ACC_GPR = 2,
	ACC_FPR = 3,
	ACC_NSINT = 4,
	ACC_ICSR = 5,
	ACC_AUX = 'hf,
	// Fake space to speak directly to DM.
	ACC_DEBUG_MODULE = 'hd,
	// Fake space to simulate status32 and debug by talking to DM.
	ACC_OLDAUX = 'he,
	// Add this bit to the space to indicate 64-bit access.
	ACC64 = 'h100;
function automatic string ibp_spacename(int space);
    // Name of each space in the core's IBP debug interface.
    string S = space & ACC64 ? "(64bit)" : "";
    space &= ~ACC64;
    begin
    string ans = 
	space == ACC_GPR ? "core" :
	space == ACC_MEM ? "memory" :
	space == ACC_AUX ? "aux" :
	space == ACC_OLDAUX ? "old_aux" :
	space == ACC_DEBUG_MODULE ? "debug_module" :
	$sformatf("space %1d",space);
    return {ans,S};
    end
    endfunction

// Debug Transport Module (DTM) JTAG IR registers
localparam 
    DTMCS	= 5'b1_0000,	// 0x10	control and status
    DMI		= 5'b1_0001,	// 0x11 debug module interface access
    BTXCS	= 5'b0_1101,
    BTX		= 5'b0_1110,	// Same as DMI.
    SELECT	= 5'b0_0010;

// JTAG operations send to DMI/BTX.
typedef enum { RV_NOP, RV_READ, RV_WRITE, RV_RSVD } RV_OP;
localparam OPLEN = 2, DATALEN = 32; // ADDR_LEN is discovered at the outset.
typedef enum { RV_SUCCESS, RV_RSVD2, RV_FAIL, RV_BUSY } RV_ANSWER;
function automatic string dm_opstring(RV_OP op);
    if (op == RV_NOP) return "nop";
    if (op == RV_READ) return "read";
    if (op == RV_WRITE) return "write";
    return "???";
    endfunction

localparam ARC_STATUS32 = 10, ARC_DEBUG = 5; // registers
localparam DEBUG_HALT = 2;	// Bit in ARC_DEBUG
localparam OLDARC_BCR = 0;	// register 0 in old_aux => 1 if we support oldaux.
localparam FAKE_RUNNING = 'haaaa;	// Fake value for status32.

endpackage
