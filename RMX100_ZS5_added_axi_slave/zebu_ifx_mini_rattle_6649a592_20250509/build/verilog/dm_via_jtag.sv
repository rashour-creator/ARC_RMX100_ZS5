


module dm_via_jtag(
    );
// Convert DM read/writes to jtag instructions to do the same.
// Our target is the dtm_jtag transport module.
import RV_debug::*;

// We discover this from DTMCS.
UINT ADDR_LEN = 0;
UINT IDLE_NUM = 0;

// We are using SNPS extension BTX IR access.
// data | address | op
let ADDR_SHIFT(x) =(x << OPLEN);
let DATA_SHIFT(x) =(x << (OPLEN+ADDR_LEN));
string using = "BTX";


localparam bit trace =
//  1-
    0;
localparam bit trace_shifts =
//  1-
    0;

// "typed" 0 and 1.
localparam TDI_0 = 0, TDI_1 = 1;
localparam TMS_0 = 0, TMS_1 = 1;

JTAG_FSM::FSM debug_fsm = new("debug_fsm");	// keep track of things.
// You can't see debug_fsm in a vpd wave form.
// If I want to see the state I have to copy it.
JTAG_FSM::FSM_state debug_fsm_state;

Debug_module_jtag_if dmji;
task automatic receive_dmjtag_if(Debug_module_jtag_if I);
    dmji = I;
    endtask

task automatic Take_transition(bit tms, bit tdi, string where);
    if (0) $display("%4d %1s dm_via_jtag:\t", $time, using,"TT {");
    dmji.take_transition(tms,tdi,where);
    if (trace) debug_fsm.trace = 1;
    debug_fsm.take_transition(tms,tdi);
    debug_fsm_state =  debug_fsm.current_state;
    if (0) $display("%4d %1s dm_via_jtag:\t", $time, using,"TT }");
    endtask

bit tdo_trace = 0;
function automatic bit read_TDO(); 
    logic TDO = dmji.read_TDO(); 
    if (tdo_trace && TDO != 0) $display("%4d %1s dm_via_jtag:\t", $time, using,"TDO read is %1d",TDO);
    return TDO;
    endfunction

function automatic bit in_idle(); return debug_fsm.in_idle(); endfunction

task automatic take_transitions(string tms, bit tdi, string comment);
    if (trace) 
        $display("%4d %1s dm_via_jtag:\t", $time, using,"BEGIN tms %1s with tdi %1d to effect %1s {",tms,tdi,comment);
    
    foreach (tms[i])
	Take_transition(tms[i],tdi,"F");
    if (trace) 
        $display("%4d %1s dm_via_jtag:\t", $time, using,"END tms %1s with tdi %1d to effect %1s }",tms,tdi,comment);
    endtask

task automatic goto_shift_dr_from_idle();
    ensure_idle();
    take_transitions("100",TDI_0,"get ready to shift_dr");
    endtask
task automatic goto_shift_ir_from_idle();
    ensure_idle();
    take_transitions("1100",TDI_0,"get ready to shift_ir");
    endtask
function automatic int bits_in(UINT64 data);
    UINT bits_in_data = 0;
    while (data != 0) begin
        data >>= 1;
	bits_in_data++;
        end
    return bits_in_data;
    endfunction

UINT64 data_read;

localparam bit true = 1, false = 0;

task automatic wait_til_operation_done(int want_result_when_success);
    // Precondition: we are in run-test-idle.
    // Shift in NOP until the output is RV_SUCCESS meaning previous DMI access is complete
    // (This is not an abstract command; it's just a write to the DMI bus.)
    localparam MAX = 100;
    // Wait the mininum number of idle cycles in RTI between DMI operations
    for (int ii = 0; ii < IDLE_NUM; ii++) begin
      Take_transition(TMS_0,TDI_0,"Wait idle num cycles");
    end
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"Wait til DMI transaction done: shift in NOP. {");
    for (int i = 0; i < MAX; i++) begin
	UINT item = RV_NOP;
	UINT result;
	goto_shift_dr_from_idle();
	// Shift in NOP and ask if the result is SUCCESS.
	// Then either do nothing (DMI write) or read the 32-bit result (DMI read).
	shift_in_data(OPLEN,item,"C",want_result_when_success);
	if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"test for operation completed: result=%1x",data_read);
	result = data_read[OPLEN-1:0];
	if (result == RV_SUCCESS) begin
	    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"operation complete!");
	    break;
	    end
	else if (result == RV_BUSY) begin
	    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"operation still busy %1d",i);
	    end
	else if (result == RV_FAIL) begin
	    // This shouldn't happen; we currently don't have error handling.
	    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"operation failed");
	    end;
	if (i == MAX-1) $display("%4d %1s dm_via_jtag:\t", $time, using,"TIMEOUT!");
	end
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"END Wait til DMI transaction done }");
    endtask

task automatic shift_in_data(int len, UINT64 data, string where,
	int want_result_when_success=0);
    // Precondition: we are in shift-xR state.
    if (debug_fsm_state == JTAG_FSM::q_shift_IR ||
        debug_fsm_state == JTAG_FSM::q_shift_DR) ;
    else begin
        $display("%4d %1s dm_via_jtag:\t", $time, using,"ERROR: wrong fsm state for shift_in_data");
	$finish();
	end
    begin
    // Postcondition: we are in RTI.
    // N-1 bits are taken in shift-xR.  We have just arrived at shift-xR.
    // We also capture TDO in case the client actually wants to read the register.
    UINT64 shifted_out = 0, orig_data = data;
    int shift_count = 0;
    // shifted_out can be 34 bits: 32 bits of data plus 2 bits of opcode.
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"shift in data %1x for %1d bits %1s {",data,len,where);
    for (int i = 0; i < len-1; i++) begin
        shifted_out |= read_TDO() << i;
        Take_transition(TMS_0,data[0],"A");
	shift_count++;
	data >>= 1;
        end
    shifted_out |= read_TDO() << (len-1);
    // We have read in the required number of bits.  If want_result_when_success is on,
    // we just read the status; if the status is 0, continue to read 32 more bits.
    if (want_result_when_success && shifted_out == RV_SUCCESS) begin
        if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"read operation was RV_SUCCESS=0, so read 32 bits more data");
	for (int i = 0; i < want_result_when_success; i++) begin
	    Take_transition(TMS_0,0,"B");
	    shift_count++;
	    shifted_out |= read_TDO() << (i+OPLEN);
	    end
	if (0) $display("WE READ data %1x",shifted_out >> OPLEN);
        end
    Take_transition(TMS_1,data[0],"C");	// go to exit
    shift_count++;
    // Last bit is taken when going to exit
    take_transitions("10",TDI_0,"update and go to idle");
    data_read = shifted_out;
    // $display("TDO read was %1x",shifted_out);
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"END shift in data %1x bits shifted=%1d %1s }",
    	orig_data,shift_count,where);
    end
    endtask

reg initialization_done = 0;

task automatic ensure_idle();
    if (in_idle() == 0) begin
	goto_idle_via_reset();
	end
    endtask

task automatic update_and_go_to_idle();
    // If not already in idle...
    // If I do this anyway it goes through DR without a valid opcode
    // and breaks the RTL on the other side.
    if (debug_fsm.current_state != JTAG_FSM::q_run_test_idle)
	take_transitions("10110",TDI_0,"update and go to idle");
    endtask

int unsigned read_shift = 0, write_shift = 0;

task automatic read(UINT addr, output UINT val, input int want_bits);
    // To issue a command to read a location, with DMI you have to shift in
    // 32-bits of useless data.
    wait(initialization_done == 1);
    tdo_trace = trace;
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"NEW read %1s {",dm_regformat(addr));
    begin
    UINT 
	item = ADDR_SHIFT(addr) | RV_READ;
    int total_bits = bits_in(item);
    read_shift += total_bits;
    if (trace||trace_shifts) 
	$display("%4d %1s dm_via_jtag:\t", $time, using,"read  %02x: shift DR %1x for %1d bits rshifts=%1d",
    	addr,item,total_bits,read_shift);
    // Now shift in NOP to see if we have success.  If we get success,
    // the next bits are the data we want.
    goto_shift_dr_from_idle();
    shift_in_data(total_bits,item,"D");
    update_and_go_to_idle();
    if (want_bits == 0) $display("oops, want bits is 0");
    wait_til_operation_done(want_bits);
    val = data_read >> OPLEN;
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"END read DR %1x for %1d bits result %1x }",
    	item,ADDR_LEN+OPLEN,val);
    end
    endtask


task automatic write(UINT addr, UINT data);
    tdo_trace = 0;
    wait(initialization_done == 1);
    // Want to write a location in the DMI
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"NEW write %1x => %1s {",data,dm_regformat(addr));
    begin
    // Fashion data stream:
    // BTX: | data | addr | op |
    // DMI: | addr | data | op |	(waste!)
    UINT64 item = ADDR_SHIFT(addr) | RV_WRITE;
    item |= DATA_SHIFT(data);
    begin
    int total_bits = bits_in(item);
    write_shift += total_bits;
    if (trace||trace_shifts) $display("%4d %1s dm_via_jtag:\t", $time, using,
	"write %02x: shift in DR %1x for %1d bits data=%1x wshifts=%1d",
    	addr,item,total_bits,data,write_shift);
    goto_shift_dr_from_idle();
    // Now shift DR for N and then exit.
    shift_in_data(total_bits,item,"D");
    update_and_go_to_idle();
    wait_til_operation_done(0);
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"END write to %1s }",dm_regformat(addr));
    end
    end
    endtask

task automatic set_IR_to(int IRcode);
    // Precondition: RTI.
    localparam len = 5;	// All IRs are length 5.
    if (trace) $display("%4d %1s dm_via_jtag:\t", $time, using,"set IR to %1x",IRcode);
    goto_shift_ir_from_idle();
    shift_in_data(len,IRcode,"A");
    // current_IR = IRcode;
    endtask

task automatic set_IR_to_DMI_access();
    // USE_DMI is 0
    set_IR_to(BTX);
    endtask

task automatic step_TMS_ZERO(); Take_transition(TMS_0,TDI_0,"D"); endtask
task automatic step_TMS_ONE() ; Take_transition(TMS_1,TDI_0,"E"); endtask

task automatic goto_idle_via_reset();
    reset_fsm();
    step_TMS_ZERO();
    endtask

task automatic goto_DR_scan_via_reset();
    goto_idle_via_reset();
    step_TMS_ONE();
    endtask

task automatic read_control_and_status();
    // I can shift in any old thing, as our JTAG zero-fills upper bits.
    localparam shift_in = 15'b11111_11111_11111;
    set_IR_to(BTXCS);
    // I care only about the bottom 10 bits of cs and idle.
    goto_shift_dr_from_idle();
    shift_in_data($bits(shift_in),shift_in,"B");
    ADDR_LEN = data_read[9:4];
    IDLE_NUM = data_read[14:12];
    begin
    $display("%4d %1s dm_via_jtag:\t", $time, using,"data read from dtmcs was %1x addr len is %1d suggested idle=%1d",
    	data_read,ADDR_LEN,IDLE_NUM);
    end
    endtask

task automatic reset_fsm();
    // 5 1s get us to TLR no matter where we are,  0 gets us to RTI.
    take_transitions("0111110",TDI_0,"go to run-test-idle");
    // Read dtmcs to find out abits.
    endtask

task automatic select_the_ARC_hard_coded();
    // This has to be fixed.
    // For my internal dtm_jtag, the instruction is ignored.
    set_IR_to(SELECT);
    // Need to fix my own jtag to ignore this.
    goto_shift_dr_from_idle();
    shift_in_data(32,'b1010,"E");
    endtask

task automatic initialize();
    reset_fsm();
    read_control_and_status();
    select_the_ARC_hard_coded();
    // Set IR so that we can now write to the DMI.
    // In the future we may want to read control & status, but not now.
    set_IR_to_DMI_access();
    initialization_done = 1;
    $display("%4d %1s dm_via_jtag:\t", $time, using,"initialization done");
    // debug_fsm.trace = 1;
    endtask

endmodule
