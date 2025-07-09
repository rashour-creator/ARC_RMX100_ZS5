// Library Implementation-1.1.14
// CONFIDENTIAL AND PROPRIETARY INFORMATION
// Copyright 2000-2010 ARC International (Unpublished)
// All Rights Reserved.
//
// This document, material and/or software contains confidential
// and proprietary information of ARC International and is
// protected by copyright, trade secret and other state, federal,
// and international laws, and may be embodied in patents issued
// or pending.  Its receipt or possession does not convey any
// rights to use, reproduce, disclose its contents, or to
// manufacture, or sell anything it may describe.  Reverse
// engineering is prohibited, and reproduction, disclosure or use
// without specific written authorization of ARC International is
// strictly forbidden.  ARC and the ARC logotype are trademarks of
// ARC International.
// 
// ARC Product:  @@PRODUCT_NAME@@ v@@VERSION_NUMBER@@
// File version: $Revision$
// ARC Chip ID:  0
//
// Description:
//
// Rascal 'C' interface to Verilog
//
// This block instantiates the RASCAL Controller, which controls the
// simulator and the IOs of this module.
//
//======================= Inputs to this block =======================--
//
//  ra_ck	Clock input to RASCAL controller, the
//		controller synchronises to this clock.
//		This clock can change it's source or
//		frequency whenever desired.
//
//  ra_ack	Acknowledges that either the data is valid
//		for a read, or that data has been consumed
//		for a write.
//		Client must take down read/write immediately if ra_ack=1.
//
//  ra_rd_data	Read data bus.
//
//  ra_fail	Set if transaction request
//		is invalid, or the transaction will
//		not be able to complete.
//
//====================== Output from this block ======================--
//
//  ra_select	Selects between aux, core, madi, or oldaux
//
//  ra_read	Set when a read request is required.
//		(burst and addr must also be valid).
//
//  ra_write	Set when a write request is required.
//		(burst, addr and data must be valid).
//
//  ra_burst	Burst size in lwords (max = 2kb). Must
//		be valid when a read/write request is 
//		valid  
//		This is just an initial guess at a 
//		resonable size, it can be changed later
//		if required. 
//	  
//  ra_addr	Base address (lword) of transfer request. Must be
//		valid when read/write request is valid.
//
//  ra_wr_data	Write data bus, stays valid until ra_ack
//		is received.
//
//====================================================================--
//

module rascal (
    output reg [2:0] ra_select,
    output reg  ra_read,
    output reg  ra_write,
    output reg [31:0] ra_addr,
    output reg [31:0] ra_wr_data,
    output reg [9:0] ra_burst /*unused by C++*/,
    input  ra_ack,
    input [31:0] ra_rd_data,
    input [1:0] ra_fail,
    input ra_ck

    );

initial $rascal (
    ra_ck,
    ra_ack,
    ra_rd_data,
    ra_fail,

    ra_select,
    ra_read,
    ra_write,
    ra_burst,
    ra_addr,
    ra_wr_data
    );

endmodule // module rascal
