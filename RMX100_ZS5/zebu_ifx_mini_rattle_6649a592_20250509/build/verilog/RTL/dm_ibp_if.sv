
`include "arcv_dm_defines.v"   ///////


module dm_ibp_if
  #(parameter SBA_ADDR_W     = 32,
    parameter SBA_DATA_W     = 64
    )
(
// mst cmd i/f
input                                 mst_cmd_valid,
output                                slv_cmd_accept,
input                                 mst_cmd_read,
input                [SBA_ADDR_W-1:0] mst_cmd_addr,
input                           [3:0] mst_cmd_space,
input                           [3:0] mst_cmd_burst,
// mst rd i/f
output                                slv_rd_valid,
input                                 mst_rd_accept,
output                                slv_rd_err,
output                [SBA_DATA_W-1:0]slv_rd_data,
output                                slv_rd_last,
// mst wr i/f     
input                                 mst_wr_valid,
output                                slv_wr_accept,
input                [SBA_DATA_W-1:0] mst_wr_data,
input            [(SBA_DATA_W/8)-1:0] mst_wr_mask,
input                                 mst_wr_last,

output                                slv_wr_done,
output                                slv_wr_err,
input                                 mst_wr_resp_accept,

// slv cmd i/f
output                                slv_cmd_valid,
input                                 mst_cmd_accept,
output                                slv_cmd_read,
output                [SBA_ADDR_W-1:0]slv_cmd_addr,
output                           [3:0]slv_cmd_space,
output                           [3:0]slv_cmd_burst,
// slv rd i/f
input                                 mst_rd_valid,
output                                slv_rd_accept,
input                                 mst_rd_err,
input                [SBA_DATA_W-1:0] mst_rd_data,
input                                 mst_rd_last,
// slv wr i/f     
output                                slv_wr_valid,
input                                 mst_wr_accept,
output                [SBA_DATA_W-1:0]slv_wr_data,
output            [(SBA_DATA_W/8)-1:0]slv_wr_mask,
output                                slv_wr_last,

input                                 mst_wr_done,
input                                 mst_wr_err,
output                                slv_wr_resp_accept, 
///aux register out///

input                                 dm_active, //module cg
input                                 rst_a,
input                                 clk
);
// wire/reg declarations
wire                                    ibp_cmd_wen;
wire                                    ibp_rd_wen;
wire                                    ibp_w_wen;
wire                                    ibp_wr_wen;
//txen
wire                                    ibp_cmd_ten;
wire                                    ibp_rd_ten;
wire                                    ibp_w_ten;
wire                                    ibp_wr_ten;  
//rxen
wire                                    ibp_cmd_ren;
wire                                    ibp_rd_ren;
wire                                    ibp_w_ren;
wire                                    ibp_wr_ren;

//_r
reg                                     slv_cmd_valid_r;      
reg                                     slv_cmd_accept_r;     
reg                                     slv_cmd_read_r;       
reg               [SBA_ADDR_W-1:0]      slv_cmd_addr_r;       
reg                          [3:0]      slv_cmd_space_r;      
reg                          [3:0]      slv_cmd_burst_r;      
                                                      
reg                                     slv_rd_valid_r;       
reg                                     slv_rd_accept_r;      
reg                                     slv_rd_err_r;         
reg                [SBA_DATA_W-1:0]     slv_rd_data_r;        
reg                                     slv_rd_last_r;      
                                                      
reg                                     slv_wr_valid_r;       
reg                                     slv_wr_accept_r;      
reg               [SBA_DATA_W-1:0]      slv_wr_data_r;        
reg           [(SBA_DATA_W/8)-1:0]      slv_wr_mask_r;        
reg                                     slv_wr_last_r;       
                                                      
reg                                     slv_wr_done_r;        
reg                                     slv_wr_err_r;         
reg                                     slv_wr_resp_accept_r; 
                                   
// IBP write I/F
// cnt++  cnt=0
assign ibp_cmd_wen      =  !slv_cmd_valid_r && mst_cmd_valid ;
assign ibp_rd_wen       =  !slv_rd_valid_r  && mst_rd_valid ;
assign ibp_w_wen        =  !slv_wr_valid_r  && mst_wr_valid ;
assign ibp_wr_wen       =  !slv_wr_done_r   && mst_wr_done ;
//cnt-- tx handshake   block two cycle after SM got the signal
assign ibp_cmd_ten      =  (slv_cmd_valid_r && mst_cmd_accept    ) || slv_cmd_accept_r;  
assign ibp_rd_ten       =  (slv_rd_valid_r  && mst_rd_accept     ) || slv_rd_accept_r; 
assign ibp_w_ten        =  (slv_wr_valid_r  && mst_wr_accept     ) || slv_wr_accept_r;
assign ibp_wr_ten       =  (slv_wr_done_r   && mst_wr_resp_accept) ;
//cnt-- rx handshake
assign ibp_cmd_ren      =  (slv_cmd_valid_r  && slv_cmd_accept_r    )|| (!mst_cmd_valid && slv_cmd_accept_r );
assign ibp_rd_ren       =  (slv_rd_valid_r   && slv_rd_accept_r     ) ;
assign ibp_w_ren        =  (slv_wr_valid_r   && slv_wr_accept_r     )|| (!mst_wr_valid  && slv_wr_accept_r  );
assign ibp_wr_ren       =  (slv_wr_done_r    && slv_wr_resp_accept_r) ;
// ----------------------------------------------------------
//  Clocked process
// ----------------------------------------------------------


always_ff @(posedge clk or posedge rst_a)
begin: IBP_SLV_FFOUT_PROC
  if (rst_a)
  begin
    slv_cmd_valid_r  <= 1'b0;
    slv_cmd_accept_r <= 1'b0;
    slv_cmd_read_r   <= 1'b0;
    slv_cmd_addr_r   <= {SBA_ADDR_W{1'b0}};
    slv_cmd_space_r  <= 4'b0;
    slv_cmd_burst_r  <= 4'b0;

    slv_rd_valid_r   <= 1'b0; 
    slv_rd_accept_r  <= 1'b0; 
    slv_rd_err_r     <= 1'b0; 
    slv_rd_data_r    <= {SBA_DATA_W{1'b0}};
    slv_rd_last_r    <= 1'b0; 

    slv_wr_valid_r   <= 1'b0; 
    slv_wr_accept_r  <= 1'b0; 
    slv_wr_data_r    <= {SBA_DATA_W{1'b0}};
    slv_wr_mask_r    <= {(SBA_DATA_W/8){1'b0}};
    slv_wr_last_r    <= 1'b0; 

    slv_wr_err_r     <= 1'b0; 
    slv_wr_done_r    <= 1'b0; 
    slv_wr_resp_accept_r  <= 1'b0; 

  end
  else
  begin 
    if(dm_active) begin
      if(ibp_cmd_ren) begin  //
      slv_cmd_accept_r <= 1'b0;
      end
      else if(slv_cmd_valid_r)begin //   
      slv_cmd_accept_r <= mst_cmd_accept;
      end	     
      if(ibp_cmd_ten)begin //cnt--
      slv_cmd_valid_r  <= 1'b0;
//      slv_cmd_read_r   <= 1'b0;     //update each cmd.
      slv_cmd_addr_r   <= {SBA_ADDR_W{1'b0}};
      slv_cmd_space_r  <= 4'b0;
      slv_cmd_burst_r  <= 4'b0;
      end
      else if(ibp_cmd_wen) begin  //cnt0
      slv_cmd_valid_r  <= mst_cmd_valid; 
      slv_cmd_read_r   <= mst_cmd_read;  
      slv_cmd_addr_r   <= mst_cmd_addr;  
      slv_cmd_space_r  <= mst_cmd_space; 
      slv_cmd_burst_r  <= mst_cmd_burst; 
      end

      if(ibp_rd_ren) begin  //
      slv_rd_accept_r  <= 1'b0;
      end
      else if(mst_rd_valid)begin //valid 2dm
      slv_rd_accept_r  <= mst_rd_accept; 
      end
      if(ibp_rd_ten)begin //cnt--
      slv_rd_valid_r   <= 1'b0; 
      slv_rd_err_r     <= 1'b0; 
      slv_rd_data_r    <= {SBA_DATA_W{1'b0}};
      slv_rd_last_r    <= 1'b0;   
      end
      else if(ibp_rd_wen) begin
      slv_rd_valid_r   <= mst_rd_valid;  
      slv_rd_err_r     <= mst_rd_err;    
      slv_rd_data_r    <= mst_rd_data;   
      slv_rd_last_r    <= mst_rd_last;   
      end

      if(ibp_w_ren) begin  //
      slv_wr_accept_r  <= 1'b0;
      end
      else if(slv_wr_valid_r)begin //valid 2core
      slv_wr_accept_r  <= mst_wr_accept; 
      end
      if(ibp_w_ten)begin //cnt--
      slv_wr_valid_r   <= 1'b0; 
      slv_wr_data_r    <= {SBA_DATA_W{1'b0}};
      slv_wr_mask_r    <= {(SBA_DATA_W/8){1'b0}};
      slv_wr_last_r    <= 1'b0; 
      end
      else if(ibp_w_wen) begin
      slv_wr_valid_r   <= mst_wr_valid; 
      slv_wr_data_r    <= mst_wr_data;  
      slv_wr_mask_r    <= mst_wr_mask;  
      slv_wr_last_r    <= mst_wr_last; 
      end

      if(ibp_wr_ren) begin  //
      slv_wr_resp_accept_r  <= 1'b0;  
      end
      else if(1)begin // by spec
      slv_wr_resp_accept_r  <= mst_wr_resp_accept; 
      end
      if(ibp_wr_ten)begin //cnt--
      slv_wr_err_r     <= 1'b0; 
      slv_wr_done_r    <= 1'b0; 
      end
      else if(ibp_wr_wen) begin
      slv_wr_err_r     <= mst_wr_err;         
      slv_wr_done_r    <= mst_wr_done;          
      end
    end
  end
end

// IBP out I/F
assign  slv_cmd_valid  =   slv_cmd_valid_r  ;               
assign  slv_cmd_accept =   slv_cmd_accept_r ;               
assign  slv_cmd_read   =   slv_cmd_read_r   ;               
assign  slv_cmd_addr   =   slv_cmd_addr_r   ;               
assign  slv_cmd_space  =   slv_cmd_space_r  ;               
assign  slv_cmd_burst  =   slv_cmd_burst_r  ;               
                                       
assign  slv_rd_valid   =   slv_rd_valid_r   ;               
assign  slv_rd_accept  =   slv_rd_accept_r  ;               
assign  slv_rd_err     =   slv_rd_err_r     ;               
assign  slv_rd_data    =   slv_rd_data_r    ;               
assign  slv_rd_last    =   slv_rd_last_r    ;               
                                       
assign  slv_wr_valid   =   slv_wr_valid_r   ;               
assign  slv_wr_accept  =   slv_wr_accept_r  ;               
assign  slv_wr_data    =   slv_wr_data_r    ;               
assign  slv_wr_mask    =   slv_wr_mask_r    ;               
assign  slv_wr_last    =   slv_wr_last_r   ;               
                                       
assign  slv_wr_err     =   slv_wr_err_r     ;               
assign  slv_wr_done    =   slv_wr_done_r    ;               
assign  slv_wr_resp_accept  =   slv_wr_resp_accept_r  ;               
 
endmodule // slv_aux

