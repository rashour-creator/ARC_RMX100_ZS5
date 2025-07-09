//hiergen:renamer
module jtag_chain (
	input	jtag_tdo,
	output	jtag_tdi,

	input	jtag_tdi,
	output	jtag_tdo
	);

assign jtag_tdi = jtag_tdi;
assign jtag_tdo = jtag_tdo;

endmodule

