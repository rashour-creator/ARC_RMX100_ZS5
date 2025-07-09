// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2024 Synopsys, Inc
// All Rights Reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary
// work of Synopsys, Inc., and is fully protected under copyright and
// trade secret laws. You may not view, use, disclose, copy, or distribute
// this file or any information contained herein except pursuant to a
// valid written license from Synopsys, Inc.
//
// RASCAL to IBP port interface
//
//========================== Inputs to this block ==========================--
//
//   ra_select       :2  Selects between core, aux, oldaux, or memory access
//
//   ra_read         :1  Set when a read request is required.
//                       (burst and addr must also be valid).
//
//   ra_write        :1  Set when a write request is required.
//                       (burst, addr and data must be valid).
//
//   ra_addr         :32 Base address of transfer request. Must be
//                       valid when read/write request is valid.
//
//   ra_wr_data      :32 Write data bus, stays valid until ra_ack
//                       is received.
//
//========================= Output from this block =========================--
//
//   ra_ack          :1  Acknowledges that either the data is valid
//                       for a read, or that data has been consumed
//                       for a write.
//
//   ra_rd_data      :32 Read data bus.
//
//   ra_fail         :2  Set if transaction request
//                       is invalid, or the transaction will
//                       not be able to complete. If the value is 2,
//                       the chip is powered down, and that's the failure
//                       reason.
//
//==========================================================================--
//

/* OLDAUX registers
    0: BCR.  If non-zero, oldaux exists.
    5: debug.  Write 2 to halt the core.  
       Step functionality is not provided.  (Debugger expected to write dcsr & run.)
    6: pc32.  Reads DPC.
   10: status32.  Write 0 to start the ARC and read to check if running.

 */


interface rascal2space_if(

    input [2:0] ra_select,
    input  ra_read,
    input  ra_write,
    input [31:0] ra_addr,
    input [31:0] ra_wr_data,
    input [9:0] ra_burst /*unused by C++*/,
    output reg  ra_ack,
    output reg [31:0] ra_rd_data,
    output reg [1:0] ra_fail,

    input clk
    );
import RV_debug::Data;


// Can add %m in PREFIX to indicate module.


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

// Connect the ARC IBP target with the IBP initiator.
// Fake_ARC arc(.*, .clk(clk));
// IBP_debug_initiator initiator(.*, .clk(clk));

/*  ********************************************************************

    RASCAL Interface

    The scheme is this:

    Either ra_read or ra_write is set to '1' to make a transfer request,
    ra_select, ra_addr, and ra_burst are valid at this time, ra_wr_data must be
    valid for writes.

    ra_burst is used only to set the access size: 1 or 2 words.
    We don't actually burst the result.
    We may either use a data_hi signal or change rd_data to 64 bits.

    RASCAL then waits for ra_ack to be '1' for each data transfer.
    burst is not supported.

    ra_select =
	000 for memory access
	001 for core register access
	010 for auxiliary register access
	011 for MADI access
	100 for oldaux (simulated ARC legacy registers debug and status32)
	101 for debug module direct access


    As soon as ra_ack is 1 the client must take down read/write, otherwise
    a new request will occur.

//  ********************************************************************/

// TYPE access_type:
localparam
    access_type_memory = 0,
    access_type_core   = 1,
    access_type_aux    = 2,
    access_type_madi   = 3,
    access_type_oldaux = 4,		// Legacy ARC: status32 and debug.
    access_type_debug_module = 5;	// Talk to DM directly.

localparam bit trace =
// 	1-
	0;

localparam ADDR_CORE_60 = 60;	// ADDR_HI for 64-bit targets.
int core_index = 0;

class Core_local_info;
    localparam UNINIT_CORE_60 = 'hffff_ffff;
    int unsigned value_of_CORE_60 = UNINIT_CORE_60;
    endclass

Core_local_info core_local[int];
Core_local_info current_core_local;

task automatic new_core(int core);
    core_index = core;
    if (!core_local.exists(core_index)) begin
        core_local[core_index] = new();
        end
    current_core_local = core_local[core_index];
    endtask

// Possible current bug in debug module so we can't return errors yet.
bit return_errors = 1;

task automatic initialize();
    ra_rd_data <= {32{ 1'b0 }};
    UNACK("0");
    ra_fail <= 2'b00;
    new_core(0);
    begin
    string S = RV_debug::getenv("RASCAL_RETURN_ERRORS");
    if (S != "") return_errors = S.atoi();
    end
    endtask

function automatic int space_from_select(int select, int size=1);
    if (select == access_type_core) 
	return ACC_GPR | (size == 2 ? ACC64 : 0);
    if (select == access_type_aux) return ACC_AUX;
    if (select == access_type_memory) return ACC_MEM;
    if (select == access_type_oldaux) return ACC_OLDAUX;
    if (select == access_type_debug_module) return ACC_DEBUG_MODULE;
    $display("Invalid select %1d",select);
    return ACC_GPR;
    endfunction
function automatic string selectname(int select);
    return RV_debug::ibp_spacename(space_from_select(select));
    endfunction

time ack_time = 0;
task automatic ACK(string where);
    localparam ONE = 1'b1;
    ra_ack <= ONE;
    if (0 && trace) $display("%4d R2SPACE:\t ! ", $time,"setting ra_ack to 1 @%1s",where);
    ack_time = $time;
    endtask

task automatic UNACK(string where);
    localparam ZERO = 1'b0;
    ra_ack <= ZERO;
    if (0 && trace) $display("%4d R2SPACE:\t ! ", $time,"setting ra_ack to 0 @%1s",where);
    endtask

task automatic process_commands(RV_debug::Space_writer initiator);
    // Convert rascal signals to space IO on the initiator
    typedef enum {  q_idle, q_perform_request, q_acknowledge_request, q_acknowledge_clear} State;
    State rascal_state = q_idle;

    /* Rascal client interface is not great.  ra_read/write is set if you
       want to do a read or write; ra_ack <= 1 when the command is finished.
       The client must take the result as soon as ra_ack is 1, as ra_ack goes
       to zero right after that.

       However the C++ client doesn't take read/write down until it sees
       ra_ack.  In the meantime we see the read/write (because the client
       didn't take it down a cycle later) and start another transaction!

       So we need to accept new commands only when ra_ack is 0, meaning
       the client has had time to see ra_ack and take down its read/write.

       Possibly the reason this worked with JTAG is that rascal ticked
       faster than jtag .. not sure.

       We take down ra_ack the cycle after it's raised, thus requiring
       the client to recognize the result immediately.  The interface
       doesn't have a nice ra_accept signal for the client to tell
       us that it accepted the result.

       This interface is ancient and was crafted by ARC engineers in the 1990s.
     */

    bit READ;
    int SEL, BURST;
    int unsigned ADDR;
    Data WDATA, RDATA;
    // Don't repeatedly write register 60.  The rascal client seems to do that a lot.
    `define WRITE_TO_CORE_60 (SEL == access_type_core && ADDR_CORE_60 == ADDR)

    forever begin
        @(posedge clk);
	// $display("%4d R2SPACE:\t ! ", $time,"after posedge clk");
	// rascal2jtag original set it to 0 here.  

 	// If I always UNACK I get inconsistent behavior between simuators
	// when I USE_JTAG_SIGNALS.  Due to the time it takes for jtag to 
	// happen we miss some of the clk ticks and there seems to be one
	// pending in modelsim: the time after the clk tick is the same
	// for two ticks in a row!
	// vcs: 19320 sets ack to 1 and C++ checks at 19400
	// modelsim: 19320 sets ack to 1 and 19320 sets ack to 0!
	if ($time > ack_time) begin
	    // Must allow one time advance to occur before we clear this
	    // otherwise with modelsim we'll set it to 1 and then 0 in the same time.
	    UNACK("A");	
	    end


	case (rascal_state)
	    `define ack(x) begin ACK(x); rascal_state = q_acknowledge_request; end
	    q_idle: if (ra_read | ra_write) begin
	        ra_fail <= 0;
	        READ = ra_read;
		SEL = ra_select;
		ADDR = ra_addr;
		WDATA = ra_wr_data;
		BURST = ra_burst;
		if (0 && READ && SEL == access_type_core) 
		    $display("burst=%1d for core %1d",BURST,ADDR);
                if (0 && ra_read && SEL == access_type_aux && ADDR == 6) begin
		    // Doesn't work with DS.  7b1 not working.
                    $display("shift PC to 7b1");
                    ADDR = 'h7b1;
                    end
		rascal_state = q_perform_request;
	        end

	    q_perform_request:  begin
	        bit error = 0;
		if (0) $display("pcmd.  ra_ack %1d read %1d write %1d",ra_ack,ra_read,ra_write);
		if (READ && SEL == access_type_madi) begin
		    if (trace) $display("rascal R MADI; ignoring.");
		    `ack("B")
		    end
		else if (READ) begin
		    if (trace) $display("%4d R2SPACE:\t ! ", $time,"read  select=%1d=%1s addr='h%1x",
			SEL,selectname(SEL),ADDR);
		    initiator.read_space(space_from_select(SEL,BURST), ADDR,RDATA,error);
		    ra_rd_data <= RDATA;
		    if (trace) $display("%4d R2SPACE:\t ! ", $time,"returned data = 'h%1x",RDATA);
		    `ack("C")
		    end
		else begin	// write
		    if (SEL == access_type_madi) begin
			int core = WDATA;
			new_core(core);
			initiator.switch_core(core);
			if (trace) $display("%4d R2SPACE:\t ! ", $time,"rascal switches core to %1d",core);
			end
		    else if (`WRITE_TO_CORE_60 && 
		    	current_core_local.value_of_CORE_60 == WDATA) begin
			`ack("E")
			end
		    else begin
			if (trace) $display("%4d R2SPACE:\t ! ", $time,"rascal write select=%1d=%1s addr='h%1x data='h%1x",
				SEL,selectname(SEL),ADDR, WDATA);
			initiator.write_space(space_from_select(SEL,BURST),ADDR,WDATA,error);
		        if (`WRITE_TO_CORE_60) 
			    current_core_local.value_of_CORE_60 = WDATA;
			end
		    `ack("D")
		    end
		if (error && return_errors) begin
		    ra_fail <= 1;
		    $display("%4d R2SPACE:\t ! ", $time,"Transaction %1s space %1s addr 0x%1x failed.",
		    	READ ? "read" : "write", selectname(SEL),ADDR);
		    end
		end

	    q_acknowledge_request: begin
 		// This leaves ra_ack up for a cycle so the client can see it.
		// The client is obliged to check ra_ack every clock.
		// A better design would have been to have an ra_accept signal,
		// and we drop ra_ack when ra_ack & ra_accept.
		rascal_state = q_acknowledge_clear;
		end
	    q_acknowledge_clear: begin
		UNACK("E");
		rascal_state = q_idle;
		end
	    endcase
	end
    endtask

function automatic int int_argument(string lookfor, int default_);
    // void' gets rid of modelsim warning.
    int result = default_;
    void'($value$plusargs(lookfor,result));
    return result;
    endfunction

initial initialize();

//------------------------------------------------------------------------------------

`undef PREFIX
endinterface
