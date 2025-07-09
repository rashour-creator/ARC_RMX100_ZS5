/*
 * Copyright (C) 2024 Synopsys, Inc. All rights reserved.
 *
 * SYNOPSYS CONFIDENTIAL - This is an unpublished, confidential, and
 * proprietary work of Synopsys, Inc., and may be subject to patent,
 * copyright, trade secret, and other legal or contractual protection.
 * This work may be used only pursuant to the terms and conditions of a
 * written license agreement with Synopsys, Inc. All other use, reproduction,
 * distribution, or disclosure of this work is strictly prohibited.
 *
 * The entire notice above must be reproduced on all authorized copies.
 */



// ===========================================================================
//
// Description:
//  Parity ptotection encoder
//
// ===========================================================================

`include "const.def"


module even_pty_enc
  #(
    parameter DATA_SIZE = 32
   )
   (
     input   [DATA_SIZE-1:0]      data_in,
     output                       parity_out
   );


generate
  if (DATA_SIZE == 1) begin
    assign parity_out = data_in;
  end
  else
  begin
    assign parity_out = ^data_in;
  end
endgenerate

endmodule


