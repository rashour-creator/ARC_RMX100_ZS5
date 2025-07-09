

interface space2dm_if(
    // Modelsim allows Debug_module_if to be an argument to an interface
    // vcs does not, so we have to provide a task to install it.
    );
import RV_debug::*;

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


Debug_module_if dm;
task install_dm(Debug_module_if B); dm = B; endtask

localparam bit trace =
//	1+
	0;


/*
31:24 cmdtype
22:20 aarsize
19    aarpostincrement
18    postexec
17    transfer
16    write
15:0  regno
 */

    // DM command  0x17
    `define CF_CMDTYPE 31:24
    `define CF_AASIZE 22:20
    `define CF_POSTINC 19
    `define CF_TRANSFER 17
    `define CF_WRITE 16
    `define CF_REGNO 15:0
    // DM control 0x10
    `define DMC_DMACTIVE 0
    `define DMC_HASEL 26	// 1=>multiple harts
    `define DMC_HARTSELLO 25:16
    `define DMC_RESUMEREQ 30
    `define DMC_HALTREQ 31
    localparam SZ_32BITS = 2;	// aa{r,m}size field.
    localparam SZ_64BITS = 3;	// aa{r,m}size field.
    localparam SZ_128BITS = 4;	// aa{r,m}size field.
    // DMstatus 0x11
    `define DMS_ALLRESUMEACK 17
    `define DMS_ANYRESUMEACK 16
    `define DMS_ALLRUNNING 11
    `define DMS_ANYRUNNING 10
    `define DMS_ALLHALTED 9
    `define DMS_ANYHALTED 8
    `define DMS_AUTHENTICATED 7
    // DM abstractcs 0x16
    `define DMAS_BUSY 12
    `define DMAS_CMDERR 10:8

function automatic UINT fill_reg_command(int space, UINT addr, bit is_64);
    UINT cmd = 0;
    cmd[`CF_CMDTYPE] = cmdtype_access_register;
    cmd[`CF_AASIZE] = is_64 ? SZ_64BITS : SZ_32BITS;
    cmd[`CF_TRANSFER] = 1;
    cmd[`CF_REGNO] = addr + (space == ACC_GPR ? GPR_BASE : AUX_BASE);
    return cmd;
    endfunction

task automatic wait_til_abstract_not_busy(output Space_writer::Error_type cmderr_found);
    int cnt = 0;
    UINT status;
    cmderr_found = 0;
    while (1) begin
        // I only want 13 bits of the status register.
	// This can improve jtag speed: don't bother to shift out all 32 bits.
        dm.read(DM_ASTATUS,status,13);
	cnt++;
	if (status[`DMAS_BUSY] == 0) begin
	    if (status[`DMAS_CMDERR] != 0) begin
	        // Must clear cmderr.  Write 1 to each bit to clear it.
		UINT clear = 0;
		localparam all_ones = -1;
		// Must write 1 to each bit to clear each cmderr bit.
		clear[`DMAS_CMDERR] = all_ones[`DMAS_CMDERR];
		if (trace) $display("%4d Space2dm:\t", $time,"Clearing abstractcs::cmderr.");
	        dm.write(DM_ASTATUS,clear);
	        cmderr_found = 1;
		end
	    break;
	    end
	if (cnt % 1024 == 0)
	    $display("%4d Space2dm:\t", $time,"Debug module has been busy after %1d checks; this is unusual",cnt);
	end
    endtask

logic [31:0] prev_addr = 'hx;

// auto command only works if autoinc as well
localparam USE_AUTO = 0;
localparam bit trace_auto = trace;

task automatic set_addr(UINT addr, UINT delta, output bit autoinc_successful);
    	begin
	dm.write(DM_DATA1,addr);
	autoinc_successful = 0;
	end
    prev_addr = addr;
    endtask

function automatic UINT cmd_memory_32_bits();
    UINT cmd;
    cmd[`CF_CMDTYPE] = cmdtype_access_memory;
    cmd[`CF_AASIZE] = SZ_32BITS;
    cmd[`CF_POSTINC] = 1;
    return cmd;
    endfunction

int current_core = 0;
localparam bit START_USING_DM = 1, STOP_USING_DM = 1, STATUS32_USING_DM = 1;

function automatic UINT control_with_core();
    UINT control;
    control[`DMC_DMACTIVE] = 1;	// Don't go inactive.
    // No way to write dm control without setting harts!  Bad design.
    control[`DMC_HARTSELLO] = current_core;
    return control;
    endfunction

task automatic wait_status_until(int which_bit, string desc);
    int cnt = 0;
    if (0) $display("wait for bit %1d",which_bit);
    while (1) begin // [
	// Wait until resumereq receivedf.
	UINT status;
	dm.read(DM_STATUS,status);
	if (0) $display("status is %1x",status);
	cnt++;
	if (status[which_bit]) begin // [
	    if (trace) $display("%4d Space2dm:\t", $time,"DM bit %1d received (%1s)",which_bit,desc);
	    break;
	    end // ]
	if (cnt > 10000) begin // [
	    $display("%4d Space2dm:\t", $time,"TIMEOUT on DM core start or stop.");
	    $finish();
	    end // ]
	end // ]
    endtask

// memory autoexec.
UINT autoexec = 0;

task automatic set_auto(UINT cmd,string where);
    // We support just DATA0 for now.
    // A 64-bit read fills data0 and 1.  We re-execute only on data0 access.
    if (USE_AUTO) begin
	if (trace_auto) $display("%4d Space2dm:\t", $time,"set auto to %1x at %1s",cmd,where);
	dm.write(DM_AUTO, cmd != 0 ? 1 : 0);
	autoexec = cmd;	// Record command that will be re-executed.
	end
    endtask

task automatic ensure_noauto(string where);
    if (autoexec != 0) begin
        set_auto(0,{where, "-none"});	// No auto on reg access.
	end
    endtask

task automatic access_data0_on_mem(UINT command);
    // Spec says auto has to be written before access to dataN.
    if (autoexec == 0) begin
	// Before accessing data0, write autoexec.
	set_auto(command,"access");
	end
    endtask

task automatic write_command(UINT cmd);
    if (USE_AUTO && trace_auto) $display("%4d Space2dm:\t", $time,"Write command %1x",cmd);
    dm.write(DM_COMMAND,cmd);
    endtask

task automatic write_space(int space, UINT addr, Data value, output Space_writer::Error_type error);
    UINT cmd;
    bit space64 = (space & ACC64) != 0;
    bit autoinc_successful;
    string trace64 = space64 ? " (64bit)" : "";
    ensure_DM_on();
    space &= ~ACC64;
    if (trace)
	$display("%4d Space2dm:\t", $time,"Write space %1s 'h%1x with 'h%1x%0s",
	    ibp_spacename(space),addr,value,trace64);
    if (space == ACC_DEBUG_MODULE) begin
        // Talk directly to debug module without us interfering.
	dm.write(addr,value);
	return;
        end
    wait_til_abstract_not_busy(error);
    if (space == ACC_OLDAUX) begin // [
	if (addr == ARC_STATUS32 && (value&1) == 0 && START_USING_DM) begin // [
	    // Start the ARC by writing 0 to status32 => use DM.
	    UINT control = control_with_core();
	    control[`DMC_RESUMEREQ] = 1;
	    if (trace) $display("%4d Space2dm:\t", $time,"Request DM start core %1d",current_core);
	    dm.write(DM_CONTROL,control);
	    wait_status_until(`DMS_ANYRESUMEACK,"anyresumeack");
	    return;
	    end // ]
	if (addr == ARC_DEBUG && (value&DEBUG_HALT) == DEBUG_HALT && STOP_USING_DM) begin // [
	    // Stop the ARC.
	    UINT control = control_with_core();
	    control[`DMC_HALTREQ] = 1;
	    if (trace) $display("%4d Space2dm:\t", $time,"Request DM stop core %1d",current_core);
	    dm.write(DM_CONTROL,control);
	    wait_status_until(`DMS_ANYHALTED,"anyhalted");
	    return;
	    end // ]
	// Didn't execute special code.  Assumes core still has status32/debug CSR.
	space = ACC_AUX;
	end // ]

    begin
    bit command_needed = 1;
    if (space == ACC_GPR || space == ACC_AUX) begin
	ensure_noauto("write reg");	// No auto for regs.
        dm.write(DM_DATA0, value);
	if (space64 && $bits(value) > 32) begin
	    dm.write(DM_DATA1, value >> 32);
	    end
        cmd = fill_reg_command(space,addr,space64);
	cmd[`CF_WRITE] = 1;
        end
    else begin
	cmd = cmd_memory_32_bits();
	cmd[`CF_WRITE] = 1;
	if (autoexec != cmd) ensure_noauto("write_space-diff");
        set_addr(addr,SZ_32BITS<<1,autoinc_successful);
	if (USE_AUTO && autoexec == cmd && autoinc_successful) begin
	    // Re-executing same command.
	    if (trace_auto) $display("%4d Space2dm:\t", $time,"avoid mem cmd writing at %1x",addr);
	    command_needed = 0;
	    end
	else begin
	    // No match. Be sure we aren't in auto.
	    ensure_noauto("write: no match");
	    end
	dm.write(DM_DATA0,value);
        end
    if (command_needed) begin
	write_command(cmd);	// Execute write.
	// Memory writes are autoexec until we see a different command.
	if (space == ACC_MEM) set_auto(cmd,"write_space");
	wait_til_abstract_not_busy(error);
	if (error) 
	    $display("%4d Space2dm:\t", $time,"ERROR in write abstract command space %1s addr 0x%1x",
		ibp_spacename(space),addr);
	end
    end
    endtask

task automatic read_space(int space, UINT addr, output Data value, output Space_writer::Error_type error);
    UINT cmd;
    UINT value32;
    bit autoinc_successful;
    bit space64 = (space & ACC64) != 0;
    string trace64 = space64 ? " (64bit)" : "";
    ensure_DM_on();
    space &= ~ACC64;
    error = 0;
    if (trace)
	$display("%4d Space2dm:\t", $time,"Read  space %1s 'h%1x%0s",ibp_spacename(space),addr,trace64);
    if (space == ACC_DEBUG_MODULE) begin
        // Talk directly to debug module without us interfering.
	dm.read(addr,value);
	return;
        end
    else if (space == ACC_OLDAUX) begin // [
	if (addr == ARC_STATUS32 && STATUS32_USING_DM) begin // [
	    UINT status;
	    dm.read(DM_STATUS,status);
	    if (trace) $display("%4d Space2dm:\t", $time,"Read DM_STATUS to implement read of STATUS32.");
	    value = status[`DMS_ANYRUNNING] ? FAKE_RUNNING : 1;
	    return;
	    end // ]
	end // ]

    wait_til_abstract_not_busy(error);
    if (space == ACC_GPR || space == ACC_AUX) begin
        ensure_noauto("read_reg");
        cmd = fill_reg_command(space,addr,space64);
	// cmd[`CF_WRITE] = 0;	// already
	write_command(cmd);	// execute read
        end
    else begin // [
        set_addr(addr,SZ_32BITS<<1,autoinc_successful);
	if (0) $display("read memory at %4x",addr);
	cmd = cmd_memory_32_bits();
	if (USE_AUTO && autoexec == cmd && autoinc_successful) begin
	    // The previous access to data0 started the access to the
	    // incremented address.  I.e. the address of this access 
	    // is the same as the one previously triggered by read of DATA0.
	    if (trace_auto) $display("%4d Space2dm:\t", $time,"avoid mem cmd reading at %1x",addr);
	    end
	else begin
	    write_command(cmd);
	    set_auto(cmd,"read_space");
	    end
        end // ]
    wait_til_abstract_not_busy(error);
    if (error) $display("%4d Space2dm:\t", $time,"ERROR in read abstract command space %1s addr 0x%1x",
    	ibp_spacename(space),addr);

    if (space64 && $bits(value) > 32) begin
        // We read data1 first, because with auto we trigger re-execute on data0 only.
        UINT upper;
	dm.read(DM_DATA1,upper);
	value = UINT64'(upper) << 32;	// Cast needed?  Would be in C++.
	end

    // With autoexec this triggers the next read automatically.
    // We hope we don't "run off the edge".  We are depending on this being
    // successful so that the next read will get the data0 already delivered.
    // Possibly we need RASCAL to tell us that it's safe to try to read the
    // next element.  We could possibly check whether the address read
    // ends in 8 bits of 0 and if so turn off auto, thinking that we might
    // be near a boundary.  That would allow streaming in 64 32-bit word chunks.
    dm.read(DM_DATA0,value32);
    value |= value32;

    if (trace)
	$display("%4d Space2dm:\t", $time,"  result = 'h%1x",value);
    endtask

task automatic switch_core(int core);
    // Have to read DM control, modify hartsel, and rewrite.
    current_core = core;
    ensure_DM_on();
    if (trace) $display("%4d Space2dm:\t", $time,"Switch to core %1d",core);
    begin
    UINT control = control_with_core();	// Sets requested core.
    dm.write(DM_CONTROL,control);
    end
    endtask

bit DM_ON = 0;

task automatic turn_on_dm();
    dm.write(DM_CONTROL,1);
    while (1) begin
        UINT val;
	if (trace) $display("%4d Space2dm:\t", $time,"Waiting for DM to go active");
        dm.read(DM_CONTROL,val);
	if (val[`DMC_DMACTIVE]) break;	// It's active
	else if (trace) $display("%4d Space2dm:\t", $time,"DM_CONTROL is %1x",val);
	end
    if (trace) $display("%4d Space2dm:\t", $time,"DM is now active");
    DM_ON = 1;
    endtask

task automatic ensure_DM_on();
    if (!DM_ON) turn_on_dm();
    endtask

endinterface
