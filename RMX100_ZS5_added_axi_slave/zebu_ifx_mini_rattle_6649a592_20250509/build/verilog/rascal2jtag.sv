// {



module rascal2jtag (
    output  ejtag_tck,
    output  ejtag_tms,
    output  ejtag_tdi,
    output  ejtag_trst_n,
    input  ejtag_tdo,
    input sys_halt_r,
    input rst_a,
    input clk
    );

wire [2:0] ra_select;
wire  ra_read;
wire  ra_write;
wire [31:0] ra_addr;
wire [31:0] ra_wr_data;
wire [9:0] ra_burst /*unused by C++*/;
wire  ra_ack;
wire [31:0] ra_rd_data;
wire [1:0] ra_fail;

import RV_debug::*;
typedef RV_debug::Space_writer Writer;


localparam bit trace = 
//	1-
	0;


space2dm_if space2dm();


dm_via_jtag u_dm_via_jtag(.*);
// dm_fsm communicates either by direct call or via signals.
reg tms, tck, tdi;
assign ejtag_tck = tck;
assign ejtag_tms = tms;
assign ejtag_tdi = tdi;

localparam TCK_CLOCK_PERIOD = 20;
int unsigned JTAG_transition_counter = 0;

class DMJIF extends Debug_module_jtag_if;
    int counter = 0;
    int in_tt = 0;
    virtual task automatic take_transition(bit TMS, bit TDI, string where);
	localparam
	    // The computations in defines.v were inaccurate integers. Close to
	    // the maximum jtag speed, the simulation fails.  So we take just the
	    // clock period here and compute the derivative values, in floating point.
	    // We have succeeded with TCK_CLOCK_PERIOD as low as 12 for normal JTAG
	    // and 18 when DWT is present.
	    TCK_HALF_PERIOD 	= TCK_CLOCK_PERIOD / 2.0,
	    DELAY_ON_TDO	= TCK_CLOCK_PERIOD / 4.0,
	    TCK_HALF_PERIOD_TDO = TCK_HALF_PERIOD  - DELAY_ON_TDO;
	// $display("HPTDO is %1d", TCK_HALF_PERIOD_TDO);
	localparam ONE = 1, ZERO = 0;
        counter++; JTAG_transition_counter = counter;
        if (0) $display("%4d R2JTAG:\t", $time,"%3d: Take transition tms %1d tdi %1d ;%1s SIGNAL",counter,TMS,TDI,
		where);
	if (in_tt) begin
	    $display("%4d R2JTAG:\t", $time,"!!WHAT recursive call %1d",in_tt);
	    $finish();
	    end
	in_tt++;
	if (0) $display("task: Clock_TCK at %1t",$time); 
	// Don't wait.  Do this now.
	tms = TMS;
	tdi = TDI;
	# TCK_HALF_PERIOD_TDO ;
	// Why 1 then 0?
	tck <= ONE;
	# TCK_HALF_PERIOD ;
	tck <= ZERO;
	# DELAY_ON_TDO ;
        if (0) $display("%4d R2JTAG:\t", $time,"%3d: END Take transition tms %1d tdi %1d ;SIGNAL",counter,TMS,TDI);
	in_tt--;
	endtask
    function automatic read_TDO(); return ejtag_tdo; endfunction
    endclass

// For 32-bit processors:
// arg0 = data0.  arg1 = data1.  arg2 = data2
class access_dm_via_jtag extends Debug_module_if;
    string which;
    virtual task automatic write(UINT addr, UINT val);
        if (trace) $display("%4d R2JTAG:\t", $time,"%1s bus: write %1s <- %08x {",which,dm_regformat(addr),val);
	u_dm_via_jtag.write(addr,val);
        if (trace) $display("%4d R2JTAG:\t", $time,"%1s END write %1s <- %08x }",which,dm_regformat(addr),val);
        endtask
    virtual task automatic read(UINT addr, output UINT val, input int want_bits);
        if (trace) $display("%4d R2JTAG:\t", $time,"%1s bus: read %1s {",which,dm_regformat(addr));
	u_dm_via_jtag.read(addr,val,want_bits);
        if (trace) $display("%4d R2JTAG:\t", $time,"%1s END: read  %1s => %08x }",which,dm_regformat(addr),val);
        endtask
    endclass


// Used in rascal2{dm,jtag}.

class space_to_dm extends Writer;
    function new();
	this.avoid_3e_read = 0;
	this.core = 0;
	this.LT = 0;	// Local trace
        endfunction
    // When core removes debug/status32, set this to 0; or when you want to test.
    bit core_implements_old_aux = 1;
    function automatic bit oldaux_space(int space);
        // Once debug and status32 have been removed, make this just OLDAUX
	// as the other registers are valid CSRs for RV.
	return space == ACC_OLDAUX || (space == ACC_AUX && core_implements_old_aux);
	endfunction
    virtual task automatic write_space(int space, UINT addr, Data value, output Error_type error) ; 
	error = 0;
        if (1 && oldaux_space(space) && addr == ARC_STATUS32 && (value&1) == 0) begin
	    if (trace) $display("%4d R2JTAG:\t", $time,"attempt to start core by writing old status32.");
	    if (0) begin
		space2dm.write_space(ACC_AUX,addr,value,error);
		end
	    else begin
	        // Trigger space2dm to use DM to start the ARC.
		space2dm.write_space(ACC_OLDAUX,addr,value,error);
		end
	    end
	else if (1 && oldaux_space(space) && addr == ARC_DEBUG && (value&DEBUG_HALT) == DEBUG_HALT) begin
	    // halt request.  Use DM to halt.
	    space2dm.write_space(ACC_OLDAUX,addr,value,error);
	    end
        else space2dm.write_space(space,addr,value,error);
	if (this.LT) $display("%4d R2JTAG:\t", $time,"write %1s addr %1x with %1x",
		ibp_spacename(space),addr,value);
        endtask
    bit avoid_3e_read;
    bit LT;
    int core;
    function automatic logic is_halted();
	case (this.core)
	0: begin
	    if (this.LT) $display("%4d R2JTAG:\t", $time,"sys halt for %1d is %1d",0,sys_halt_r);
	    return sys_halt_r;
	    end
	default: return 0;
	endcase
        endfunction
    virtual task automatic read_space(int space, UINT addr, output Data value, output Error_type error); 
        error = 0;
        // I can't optimize the read if the core is not running, because:
	// write 0 to status32 (run) doesn't set halt soon enough, and the
	// core appears to be halted right away when the debugger next reads status32.
	// We could pretend the core is running for one read access.
	if (oldaux_space(space) && addr == ARC_STATUS32) begin
	    // If sys_halt_r says running, we report running and do not disturb
	    // the DM or the core, to save power.
	    // If sys_halt_r says halted, we ask DM, because sys_halt_r 
	    // can be wrong if we ask too soon after starting the core.
	    // We never read status32 from the core (it's going away anyway).
	    logic H = is_halted();
	    if (1 && H) begin
	        // Read DM to find out if core is running.  Don't trust sys_halt_r.
		space2dm.read_space(ACC_OLDAUX,ARC_STATUS32,value,error);
		H = value & 1;
	        end
	    // Kill all reads of status32, as this register will be going away.
	    value = H ? 1 : FAKE_RUNNING;
	    if (this.LT) $display("%4d R2JTAG:\t", $time,"optimized status32 read: %1x",value);
	    // Somehow this prevents dhrystone from proceeding -- pipemon
	    // produces no more.  Not sure what's going on.
	    this.avoid_3e_read = 1;
	    // Rascal client will next ask for 0x3e for the upper 32 bits.
	    end
	else if (space == ACC_OLDAUX && addr == 0) begin
	    value = 1;	// oldaux register bank is supported.
	    end
	else begin
	    if (this.avoid_3e_read && space == ACC_GPR && addr == 'h3e) begin
		if (this.LT) $display("%4d R2JTAG:\t", $time,"fake status32 upper 32 bits read");
		value = 0;
		end
	    else if (space == ACC_GPR && addr >= 32) begin
	        // DM doesn't support core regs >= 32.
	        value = 0;
		end
	    else
		space2dm.read_space(space,addr,value,error);
	    this.avoid_3e_read = 0;
	    end
	if (this.LT) $display("%4d R2JTAG:\t", $time,"read  %1s addr %1x result %1x",
			ibp_spacename(space),addr,value);
	endtask
    virtual task automatic switch_core(int core); 
        // Must read/write the dmcontrol register to switch cores.
	this.core = core;
        space2dm.switch_core(core);
	endtask
    endclass

reg ra_ck;
// Connect the rascal wires to the rascal=>space converter.
rascal2space_if i_rascal2space(.*,.clk(ra_ck));

task automatic install_all();
    // We don't use apb in this test.  No particular need to.
    access_dm_via_jtag DJ = new();	// space2m must go through jtag now.
    space2dm.install_dm(DJ);
    begin
    DMJIF dmjif = new();
    u_dm_via_jtag.receive_dmjtag_if(dmjif);
    u_dm_via_jtag.initialize();
    end
    endtask

assign ejtag_trst_n = ~rst_a;	// Done in jtag_model.v, which we aren't using.

task automatic jtag_reset_wait();
    // rasca2jtag checked rst_a also.  Why?  rst_a = ~ejtag_trst_n.
    wait (ejtag_trst_n == 1'b0) ;
    wait (ejtag_trst_n == 1'b1) ;
    endtask

task automatic do_all();
    automatic space_to_dm STODM = new();
    jtag_reset_wait();
    install_all();
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    wait(u_dm_via_jtag.initialization_done == 1);
    $display("%4d R2JTAG:\t", $time,"JTAG initialization done");
    i_rascal2space.process_commands(STODM);
    endtask

initial begin
    $display("%4d R2JTAG:\t", $time,"RUNNING");
    do_all();
    end

// May need to turn this on for ARChitect -- i.e. ra clk needs to be slower
// than system clock.  Not sure, though, as ra_ck is not exported anywhere;
// it's just used internally.
reg generated_ra_ck = 0;
always begin
    //  RASCAL clock generator.
    # TCK_CLOCK_PERIOD
	generated_ra_ck = ~ generated_ra_ck;
    end
assign ra_ck = generated_ra_ck;
// The ra_ck is the same as clk.
// (With JTAG it was the JTAG clk)
rascal irascal (.*, .ra_ck(ra_ck));

endmodule
// }
