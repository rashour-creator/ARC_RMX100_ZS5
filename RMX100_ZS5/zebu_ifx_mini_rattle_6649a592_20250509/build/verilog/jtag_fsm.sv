package JTAG_FSM;

virtual class FSM_semantics;
    pure virtual task upon_transition(int current_state, next_state, bit TDI);
    endclass

// This class allows us to keep track of the state of the jtag FSM
// for debugging purposes.

/* Jtag state machine
   state[n] means you loop to that state on TMS value n (0 or 1)
   Some states are labelled so you can indicate a xition to a label
   w/out drawing it.

test-logic-reset[1] <------------------------------------------------+
0 V								     |
RTI: run-test-idle[0] -1> SDS:select-dr-scan -1-> select-ir-scan -1->+
			   0 V			   0 V
		           capture-DR -1-+         capture-IR -1-+
			   0 V           |         0 V           |
			   shift-DR[0] <-|-+       shift-IR[0] <-|-+
			   1 V           | |       1 V           | |
		      +-1- exit-DR    <--+ |  +-1- exit-IR    <--+ |
		      |    0 V             |  |    0 V             |
		      |    pause-DR[0]     |  |    pause-IR[0]     |
		      |    1 V             |  |    1 V             |
		      |    exit2-DR   -0-->+  |    exit2-IR   -0-->+
		      |    1 V                |    1 V
		      +--> update-DR -0->RTI  +--> update-IR -0->RTI
			   1 V                     1 V
			   SDS                     SDS


*/


`define STATES(Z)		                		\
    `Z(q_run_test_idle,q_run_test_idle,q_select_DR_scan)	\
    `Z(q_select_DR_scan,q_capture_DR,q_select_IR_scan)		\
    `Z(q_test_logic_reset,q_run_test_idle,q_test_logic_reset)	\
    `Z(q_capture_DR,q_shift_DR,q_exit_DR)			\
    `Z(q_shift_DR,q_shift_DR,q_exit_DR)				\
    `Z(q_exit_DR,q_pause_DR,q_update_DR)			\
    `Z(q_pause_DR,q_pause_DR,q_exit2_DR)			\
    `Z(q_exit2_DR,q_shift_DR,q_update_DR)			\
    `Z(q_update_DR,q_run_test_idle,q_select_DR_scan)		\
								\
    `Z(q_select_IR_scan,q_capture_IR,q_test_logic_reset)	\
    `Z(q_capture_IR,q_shift_IR,q_exit_IR)			\
    `Z(q_shift_IR,q_shift_IR,q_exit_IR)				\
    `Z(q_exit_IR,q_pause_IR,q_update_IR)			\
    `Z(q_pause_IR,q_pause_IR,q_exit2_IR)			\
    `Z(q_exit2_IR,q_shift_IR,q_update_IR)			\
    `Z(q_update_IR,q_run_test_idle,q_select_DR_scan)

`define Z(a,b,c) a,
typedef enum { `STATES(Z) q_end_of_list } FSM_state;
`undef Z

class FSM;
// This implements the FSM.
// Upon taking a transition, a semantics subclass method will be called.
// That way you can implement your own JTAG with semantics.

struct {
    FSM_state dest[2];
    string name;
    } TAP[q_end_of_list];

FSM_state current_state;

function automatic void init_transitions();
    // `" to allow stringizing a.
    `define Z(a,b,c) \
	TAP[a].dest[0] = b; \
	TAP[a].dest[1] = c; \
	TAP[a].name = `"a`";
    `STATES(Z)
    `undef Z
    endfunction

bit trace = 
//	1-
	0;

int tracecnt = 0;
int unsigned transitions = 0;

task automatic take_transition(bit tms, bit tdi);
    FSM_state next = TAP[current_state].dest[tms];
    if (this.semantics != null)
	this.semantics.upon_transition(current_state,next,tdi);
    if (trace) 
        $display("%4d %1s:\t", $time, this.name,"%3d %16s tms %1d tdi %1d -> %16s",++tracecnt,
		current_state_string(),tms, tdi, TAP[next].name);
    current_state = next;
    transitions++;
    endtask

task automatic set_state(FSM_state q);
    current_state = q;
    endtask

function string current_state_string();
    return TAP[current_state].name;
    endfunction

FSM_semantics semantics;
string name;

function new(string name, FSM_semantics semantics = null);
    this.semantics = semantics;
    this.name = name;
    init_transitions();
    current_state = q_run_test_idle;
    endfunction

function automatic bit in_idle(); return current_state == q_run_test_idle; endfunction

`undef STATES
endclass
endpackage
