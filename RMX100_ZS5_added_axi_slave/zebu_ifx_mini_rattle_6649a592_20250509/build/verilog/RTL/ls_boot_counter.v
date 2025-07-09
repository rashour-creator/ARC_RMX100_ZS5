// Library safety-1.1.999999999

// Temporary module to enable lockstep after so-many cycles.
// This will go away after aux registers are in place in the core.
`include "const.def"

module ls_boot_counter #(parameter BOOT_WAIT=25) (

  ////////// General input signals ///////////////////////////////////////////
  //
    input      clk,
    input      rst,
    input      [1:0] clear_counter,						    
  ////// Outputs /////////////////////////////////////////////
    output reg count_done
  );

   reg [6:0]    count, count_next;
   reg 		 count_done_next;
// spyglass disable_block Ar_glitch01
// SMD: Signal driving clear pin of the flop has glitch
// SJ: the clear pin is driven by TMR enabled reset synchronizer. As the very source of rst_a will not be dynamically toggled,
// so if TMR is enabled will not have glitch issue , this warning can be ignored.  
     always @(posedge clk or posedge rst)
       begin
	  if (rst == 1'b1) begin
	      count <= 7'h0;
	      count_done <= 1'b0;
	  end
	  else if (clear_counter == 2'b01) begin
	      count <= 7'h0;
	      count_done <= 1'b0;
	  end
	  else begin
	    count <= count_next;
	    count_done <= count_done_next;
	  end // else: !if(rst == 1'b1)
      end
// spyglass enable_block Ar_glitch01

   always @*
     begin
	count_next = count;
	count_done_next = count_done;
	if (!count_done && (count != BOOT_WAIT))
	  count_next = count + 1'b1;
	else
	  count_next = count;

	if (count == BOOT_WAIT)
	  count_done_next = 1'b1;
	else
	  count_done_next = 1'b0;
     end
	  

endmodule 
