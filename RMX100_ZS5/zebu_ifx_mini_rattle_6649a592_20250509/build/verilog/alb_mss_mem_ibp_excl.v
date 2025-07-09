// Library ARCv2MSS-2.1.999999999
module alb_mss_mem_ibp_excl
      #(
        parameter port_id_w = 0,
        parameter port_id_msb = 19,
        parameter port_id_lsb = 18,
        parameter u_w = 1,
        parameter rg_w = 1,
        parameter id_w = 5,
        parameter a_w = 32,
        parameter d_w = 32
       )
       (
     input  wire                clk,
     input  wire                rst_b,

     input  wire                i_ibp_cmd_valid,
     output wire                i_ibp_cmd_accept,
     input  wire                i_ibp_cmd_read,
     input  wire  [a_w-1:0]     i_ibp_cmd_addr,
     input  wire                i_ibp_cmd_wrap,
     input  wire  [2:0]         i_ibp_cmd_data_size,
     input  wire  [3:0]         i_ibp_cmd_burst_size,
     input  wire  [1:0]         i_ibp_cmd_prot,
     input  wire  [3:0]         i_ibp_cmd_cache,
     input  wire                i_ibp_cmd_lock,
     input  wire                i_ibp_cmd_excl,
     input  wire  [id_w-1:0]    i_ibp_cmd_id,
     input  wire  [u_w-1:0]     i_ibp_cmd_user,
     input  wire  [rg_w-1:0]    i_ibp_cmd_region,

     output wire                i_ibp_rd_valid,
     input  wire                i_ibp_rd_accept,
     output wire  [d_w-1:0]     i_ibp_rd_data,
     output wire                i_ibp_err_rd,
     output wire                i_ibp_rd_last,
     output wire                i_ibp_rd_excl_ok,

     input  wire                i_ibp_wr_valid,
     output wire                i_ibp_wr_accept,
     input  wire  [d_w-1:0]     i_ibp_wr_data,
     input  wire  [(d_w/8)-1:0] i_ibp_wr_mask,
     input  wire                i_ibp_wr_last,

     output wire                i_ibp_wr_done,
     input  wire                i_ibp_wr_resp_accept,
     output wire                i_ibp_wr_excl_done,
     output wire                i_ibp_err_wr,

     output  wire                o_ibp_cmd_valid,
     input   wire                o_ibp_cmd_accept,
     output  wire                o_ibp_cmd_read,
     output  wire  [a_w-1:0]     o_ibp_cmd_addr,
     output  wire                o_ibp_cmd_wrap,
     output  wire  [2:0]         o_ibp_cmd_data_size,
     output  wire  [3:0]         o_ibp_cmd_burst_size,
     output  wire  [1:0]         o_ibp_cmd_prot,
     output  wire  [3:0]         o_ibp_cmd_cache,
     output  wire                o_ibp_cmd_lock,
     output  wire                o_ibp_cmd_excl,
     output  wire  [u_w-1:0]     o_ibp_cmd_user,
     output  wire  [rg_w-1:0]    o_ibp_cmd_region,

     input   wire                o_ibp_rd_valid,
     output  wire                o_ibp_rd_accept,
     input   wire  [d_w-1:0]     o_ibp_rd_data,
     input   wire                o_ibp_err_rd,
     input   wire                o_ibp_rd_last,
     input   wire                o_ibp_rd_excl_ok,

     output  wire                o_ibp_wr_valid,
     input   wire                o_ibp_wr_accept,
     output  wire  [d_w-1:0]     o_ibp_wr_data,
     output  wire  [(d_w/8)-1:0] o_ibp_wr_mask,
     output  wire                o_ibp_wr_last,

     input   wire                o_ibp_wr_done,
     output  wire                o_ibp_wr_resp_accept,
     input   wire                o_ibp_wr_excl_done,
     input   wire                o_ibp_err_wr
     );

   localparam excl_alsb = 3;    // size of tagged mem blk: 8B boundary
   // states of exclusive monitor
   localparam open_access = 1'b0; // OPEN ACCESS
   localparam excl_access = 1'b1; // EXCLUSIVE ACCESS
   localparam core_id_w = 5;// Always assume there is only 8 cores at most in each port (e.g., HS Cluster)
   localparam p_num = (1 << (port_id_w + core_id_w));

       //wires
       wire mask_shadow; // flag signal for write mask generation to memory

       wire llock_fifo_wen;
       wire llock_fifo_ren;
       wire llock_fifo_i_valid;
       wire llock_fifo_i_ready;
       wire llock_fifo_o_ready;
       wire llock_fifo_o_valid;
       wire llock_fifo_full;
       wire llock_fifo_empty;

       wire wstrb_fifo_wen_raw;
       wire wstrb_fifo_ren_raw;
       wire byp_wstrb_fifo;
       wire wstrb_fifo_wen;
       wire wstrb_fifo_ren;
       wire wstrb_fifo_i_valid;
       wire wstrb_fifo_i_ready;
       wire wstrb_fifo_o_ready;
       wire wstrb_fifo_o_valid;
       wire wstrb_fifo_full;
       wire wstrb_fifo_empty;

       wire scond_fifo_wen;
       wire scond_fifo_ren;
       wire scond_fifo_i_valid;
       wire scond_fifo_i_ready;
       wire scond_fifo_o_ready;
       wire scond_fifo_o_valid;
       wire scond_fifo_full;
       wire scond_fifo_empty;

       wire llock_exok_in; //data push into llock_fifo
       wire llock_exok_out;//data pop from llock_fifo
       wire scond_exok_in; //data push into scond_fifo
       wire scond_exok_out;//data pop from scond_fifo
       wire force_wstrb_in;//data push into wstrb_fifo
       wire force_wstrb_out;//data pop from wstrb_fifo


       wire llock_trans_x; //llock transaction of observed port (P), one-hot each time
       wire scond_trans_x; //scond transaction of observed port (P), one-hot each time
       wire store_trans_x; // normal store transaction of observed port (P)
       wire store_addr_hit;


       //assignments
        // The i_ibp_cmd_accept is generated when several conditions met:
        // (*) o_ibp_cmd_accept is asserted
        // (*) All the FIFOs are not full
       assign i_ibp_cmd_accept = o_ibp_cmd_accept & (~llock_fifo_full) & (~wstrb_fifo_full) & (~scond_fifo_full);

       assign i_ibp_rd_valid   = o_ibp_rd_valid & (~llock_fifo_empty);
       assign i_ibp_rd_data    = o_ibp_rd_data;
       assign i_ibp_err_rd     = o_ibp_err_rd;
       assign i_ibp_rd_last    = o_ibp_rd_last;
       assign i_ibp_rd_excl_ok = (llock_exok_out & o_ibp_rd_valid) ? 1'b1 : 1'b0;
       // write accept can't ahead of command accept for the first time
       assign i_ibp_wr_accept  = ((wstrb_fifo_empty & i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read))|((~wstrb_fifo_empty) & o_ibp_wr_accept))
                                 & (~scond_fifo_full);

       assign i_ibp_wr_done    = o_ibp_wr_done & (~scond_exok_out) & (~scond_fifo_empty);
       assign i_ibp_wr_excl_done = (scond_exok_out & o_ibp_wr_done & (~scond_fifo_empty))? 1'b1: 1'b0;
       assign i_ibp_err_wr     = o_ibp_err_wr & (~scond_fifo_empty);


        // The o_ibp_cmd_valid is generated when several conditions met:
        // (*) i_ibp_cmd_valid is asserted
        // (*) All the FIFOs are not full
       assign o_ibp_cmd_valid = i_ibp_cmd_valid & (~llock_fifo_full) & (~wstrb_fifo_full) & (~scond_fifo_full);
       assign o_ibp_cmd_read  = i_ibp_cmd_read;
       assign o_ibp_cmd_addr  = i_ibp_cmd_addr;
       assign o_ibp_cmd_wrap  = i_ibp_cmd_wrap;
       assign o_ibp_cmd_data_size = i_ibp_cmd_data_size;
       assign o_ibp_cmd_burst_size = i_ibp_cmd_burst_size;
       assign o_ibp_cmd_prot    = i_ibp_cmd_prot;
       assign o_ibp_cmd_cache   = i_ibp_cmd_cache;
       assign o_ibp_cmd_lock    = i_ibp_cmd_lock;
       assign o_ibp_cmd_excl    = i_ibp_cmd_excl;
       assign o_ibp_cmd_user    = i_ibp_cmd_user;
       assign o_ibp_cmd_region  = i_ibp_cmd_region;

       assign o_ibp_rd_accept   = i_ibp_rd_accept /*& (~llock_fifo_empty)*/;

       assign o_ibp_wr_valid    = i_ibp_wr_valid
                                  //& ((wstrb_fifo_empty & o_ibp_cmd_valid & o_ibp_cmd_accept & (~o_ibp_cmd_read))
                                  //   |(~wstrb_fifo_empty))
                                  & (~scond_fifo_full);
       assign o_ibp_wr_data     = i_ibp_wr_data;
       assign o_ibp_wr_mask     = mask_shadow ? {d_w/8{1'b0}} : i_ibp_wr_mask;
       assign o_ibp_wr_last     = i_ibp_wr_last;

       assign o_ibp_wr_resp_accept = i_ibp_wr_resp_accept /*& (~scond_fifo_empty)*/;


       assign mask_shadow       = wstrb_fifo_empty? (byp_wstrb_fifo & force_wstrb_in)
                                                  : force_wstrb_out;
       // FIFOs
       // fifo for read exclusive response
       assign llock_fifo_wen = i_ibp_cmd_valid & i_ibp_cmd_accept & i_ibp_cmd_read;
       assign llock_fifo_ren = (i_ibp_rd_valid|i_ibp_err_rd) & i_ibp_rd_accept & i_ibp_rd_last;
       assign llock_fifo_i_valid = llock_fifo_wen;
       assign llock_fifo_o_ready = llock_fifo_ren;

       assign llock_fifo_full = (~llock_fifo_i_ready);
       assign llock_fifo_empty = (~llock_fifo_o_valid);

       alb_mss_mem_fifo #(
           .FIFO_DEPTH(64),
           .FIFO_WIDTH(1),
           .IN_OUT_MWHILE(0),
           .O_SUPPORT_RTIO(0),
           .I_SUPPORT_RTIO(0)
       ) llock_fifo (
           .i_valid(llock_fifo_i_valid), //wen
           .i_ready(llock_fifo_i_ready), //not full
           .i_data(llock_exok_in),
           .o_valid(llock_fifo_o_valid), //not empty
           .o_ready(llock_fifo_o_ready), //ren
           .o_data(llock_exok_out),
           .i_occp(),
           .o_occp(),
           .i_clk_en(1'b1),
           .o_clk_en(1'b1),
           .clk(clk),
           .rst_a(~rst_b)
       );

       // fifo for write mask generation
       assign wstrb_fifo_wen_raw = i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read);
       assign wstrb_fifo_ren_raw = i_ibp_wr_valid & i_ibp_wr_accept & i_ibp_wr_last;
        // There is a special case, when the wstrb_fifo is empty, and next the cmd
        // and wr channel come (a paired transaction) and accepted
        // at the same time. Then for this case, the wstrb_fifo is not needed
        // to be enqueued (for cmd channel hsk) and dequeued (for wd chnl hsk).
       assign byp_wstrb_fifo = wstrb_fifo_empty & wstrb_fifo_ren_raw & wstrb_fifo_wen_raw;
       assign wstrb_fifo_wen = wstrb_fifo_wen_raw & (~byp_wstrb_fifo);
       assign wstrb_fifo_ren = wstrb_fifo_ren_raw & (~byp_wstrb_fifo);

       assign wstrb_fifo_i_valid = wstrb_fifo_wen;
       assign wstrb_fifo_o_ready = wstrb_fifo_ren;

       assign wstrb_fifo_full = (~wstrb_fifo_i_ready);
       assign wstrb_fifo_empty = (~wstrb_fifo_o_valid);

       alb_mss_mem_fifo #(
           .FIFO_DEPTH(64),
           .FIFO_WIDTH(1),
           .IN_OUT_MWHILE(0),
           .O_SUPPORT_RTIO(0),
           .I_SUPPORT_RTIO(0)
       ) wstrb_fifo (
           .i_valid(wstrb_fifo_i_valid), //wen
           .i_ready(wstrb_fifo_i_ready), //not full
           .i_data(force_wstrb_in),
           .o_valid(wstrb_fifo_o_valid), //not empty
           .o_ready(wstrb_fifo_o_ready), //ren
           .o_data(force_wstrb_out),
           .i_occp(),
           .o_occp(),
           .i_clk_en(1'b1),
           .o_clk_en(1'b1),
           .clk(clk),
           .rst_a(~rst_b)
       );

       // fifo for write exclusive response
       assign scond_fifo_wen = i_ibp_cmd_valid & i_ibp_cmd_accept & (~i_ibp_cmd_read);
       assign scond_fifo_ren = (i_ibp_wr_done|i_ibp_err_wr|i_ibp_wr_excl_done) & i_ibp_wr_resp_accept;
       assign scond_fifo_i_valid = scond_fifo_wen;
       assign scond_fifo_o_ready = scond_fifo_ren;

       assign scond_fifo_full = (~scond_fifo_i_ready);
       assign scond_fifo_empty = (~scond_fifo_o_valid);

       alb_mss_mem_fifo #(
           .FIFO_DEPTH(64),
           .FIFO_WIDTH(1),
           .IN_OUT_MWHILE(0),
           .O_SUPPORT_RTIO(0),
           .I_SUPPORT_RTIO(0)
       ) scond_fifo (
           .i_valid(scond_fifo_i_valid), //wen
           .i_ready(scond_fifo_i_ready), //not full
           .i_data(scond_exok_in),
           .o_valid(scond_fifo_o_valid), //not empty
           .o_ready(scond_fifo_o_ready), //ren
           .o_data(scond_exok_out),
           .i_occp(),
           .o_occp(),
           .i_clk_en(1'b1),
           .o_clk_en(1'b1),
           .clk(clk),
           .rst_a(~rst_b)
       );

    // Exclusive monitore
generate
   if((id_w < 3) && (port_id_w == 0)) begin: direct_pass_PROC
       reg  port_excl_nxt_state;
       reg  port_excl_cur_state;
       reg  tagging_addr_en_x;
       reg  port_excl_done_x;
       reg  port_excl_fail_x;
       reg  [a_w-1:excl_alsb] tagged_blk_excl_addr;
        // push llock exokay when llock success
        assign llock_exok_in = tagging_addr_en_x;

        // push scond exokay when scond success
        assign scond_exok_in = port_excl_done_x;

        // push force_wstrb when scond fail
        assign force_wstrb_in = port_excl_fail_x;


               // misc combinational logic
               // LLOCK
               assign llock_trans_x  = i_ibp_cmd_valid & i_ibp_cmd_accept & i_ibp_cmd_read & i_ibp_cmd_excl;
               // SCOND
               assign scond_trans_x  = i_ibp_cmd_valid & i_ibp_cmd_accept & !i_ibp_cmd_read & i_ibp_cmd_excl;
               // normal STORE
               assign store_trans_x  = i_ibp_cmd_valid & i_ibp_cmd_accept & !i_ibp_cmd_read & !i_ibp_cmd_excl;

               assign store_addr_hit   = (i_ibp_cmd_addr[a_w-1:excl_alsb] == tagged_blk_excl_addr);

               // exclusive monitor state machine
               always @(*)
                 begin : excl_nxt_state_PROC
                    // default values for next state signals
                    port_excl_nxt_state = open_access;
                    tagging_addr_en_x    = 1'b0;
                    port_excl_done_x     = 1'b0;
                    port_excl_fail_x     = 1'b0;

                    case (port_excl_cur_state)
                      open_access:
                            if(llock_trans_x) begin
                                 port_excl_nxt_state = excl_access;
                                 tagging_addr_en_x   = 1'b1; //tag address
                            end
                            else if(scond_trans_x) begin
                                 port_excl_nxt_state = open_access;
                                 port_excl_fail_x    = 1'b1; //doesn't update memory
                            end
                            else begin
                                 port_excl_nxt_state = open_access;
                            end
                      excl_access:
                            if(llock_trans_x) begin // LLOCK(x,p)
                                 port_excl_nxt_state = excl_access;
                                 tagging_addr_en_x   = 1'b1; //tag address
                            end
                            else if(scond_trans_x & store_addr_hit) begin // SCOND(t,p)
                                 port_excl_nxt_state = open_access;
                                 port_excl_done_x    = 1'b1; // successful
                            end
                            else if(scond_trans_x & (~store_addr_hit)) begin // SCOND(!t,p)
                                 port_excl_nxt_state = open_access;
                                 port_excl_fail_x    = 1'b1; // doesn't update memory
                            end
                            else if (store_trans_x & store_addr_hit) begin // store(t,p)
                                 port_excl_nxt_state = open_access; // update memory
                            end
                            else begin
                                 port_excl_nxt_state = excl_access;
                            end
                      default:
                         port_excl_nxt_state = open_access;
                    endcase
                end

               // exclusive monitor state transition
               always @(posedge clk or negedge rst_b)
                 begin : excl_cur_state_PROC
                    if(!rst_b) begin
                         port_excl_cur_state <= open_access;
                    end
                    else begin
                         port_excl_cur_state <= port_excl_nxt_state; // state update
                    end
                 end // excl_state_PROC

               // tagged id and address for llock
               always @(posedge clk or negedge rst_b)
                 begin : tagged_llock_PROC
                    if(!rst_b) begin
                         tagged_blk_excl_addr <= {(a_w-excl_alsb){1'b0}};
                    end
                    else if(tagging_addr_en_x) begin
                         tagged_blk_excl_addr <= i_ibp_cmd_addr[a_w-1:excl_alsb];
                    end
                 end // tagged_llock_PROC

   end //block: direct_pass_PROC
   else begin: no_pass_PROC //{

       wire [port_id_w + core_id_w-1:0] p_idx; //core index
       wire [p_num-1:0] llock_trans_x; //llock transaction of observed port (P), one-hot each time
       wire [p_num-1:0] scond_trans_x; //scond transaction of observed port (P), one-hot each time
       wire [p_num-1:0] scond_trans_nx; // scond transaction of other ports (!P)
       wire [p_num-1:0] store_trans_x; // normal store transaction of observed port (P)
       wire [p_num-1:0] store_trans_nx; // normal store transaction of other ports (!P)
       wire [p_num-1:0] store_addr_hit;
       wire             mem_update_fail;


       reg [p_num-1:0] port_excl_nxt_state;
       reg [p_num-1:0] port_excl_cur_state;
       reg [p_num-1:0] tagging_addr_en_x;
       reg [p_num-1:0] port_excl_done_x;
       reg [p_num-1:0] port_excl_fail_x;
       reg [a_w-1:excl_alsb] tagged_blk_excl_addr[p_num-1:0];


        wire [core_id_w-1:0] core_idx;

        if((id_w-port_id_w) < 3) begin: idw_lt_3_PROC
          assign core_idx = {core_id_w{1'b0}};
        end
        else if((id_w-port_id_w) < core_id_w) begin: idw_lt_5_PROC
          assign core_idx = {{(core_id_w-id_w+port_id_w){1'b0}}, i_ibp_cmd_id[id_w-port_id_w-1:0]};
        end
        else begin: idw_ge_5_PROC
          assign core_idx = i_ibp_cmd_id[core_id_w-1:0];
        end

        if(port_id_w > 0) begin: pidw_gt_0_PROC
          assign p_idx = {i_ibp_cmd_id[port_id_msb:port_id_lsb], core_idx};
        end
        else begin: pidw_eq_0_PROC
          assign p_idx = core_idx;
        end
       // push llock exokay when llock success
        assign llock_exok_in = tagging_addr_en_x[p_idx];

        // push scond exokay when scond success
        assign scond_exok_in = port_excl_done_x[p_idx];

        // push force_wstrb when scond fail
        assign force_wstrb_in = port_excl_fail_x[p_idx];

        assign mem_update_fail = |port_excl_fail_x;
        
        integer m;
        genvar  p;
          for (p=0; p<p_num; p=p+1)
            begin : excl_mon_gen_PROC

               // misc combinational logic
               // LLOCK
               assign llock_trans_x[p]  = i_ibp_cmd_valid & i_ibp_cmd_accept & i_ibp_cmd_read & i_ibp_cmd_excl & (p_idx == p);
               // SCOND
               assign scond_trans_x[p]  = i_ibp_cmd_valid & i_ibp_cmd_accept & !i_ibp_cmd_read & i_ibp_cmd_excl & (p_idx == p);
               assign scond_trans_nx[p] = i_ibp_cmd_valid & i_ibp_cmd_accept & !i_ibp_cmd_read & i_ibp_cmd_excl & (p_idx != p);
               // normal STORE
               assign store_trans_x[p]  = i_ibp_cmd_valid & i_ibp_cmd_accept & !i_ibp_cmd_read & !i_ibp_cmd_excl & (p_idx == p);
               assign store_trans_nx[p] = i_ibp_cmd_valid & i_ibp_cmd_accept & !i_ibp_cmd_read & !i_ibp_cmd_excl & (p_idx != p);

               assign store_addr_hit[p] = (i_ibp_cmd_addr[a_w-1:excl_alsb] == tagged_blk_excl_addr[p]);

               // exclusive monitor state machine
               always @(*)
                 begin : excl_nxt_state_PROC
                    // default values for next state signals
                    port_excl_nxt_state[p] = open_access;
                    tagging_addr_en_x[p]    = 1'b0;
                    port_excl_done_x[p]     = 1'b0;
                    port_excl_fail_x[p]     = 1'b0;

                    case (port_excl_cur_state[p])
                      open_access:
                            if(llock_trans_x[p]) begin
                                 port_excl_nxt_state[p] = excl_access;
                                 tagging_addr_en_x[p]   = 1'b1; //tag address
                            end
                            else if(scond_trans_x[p]) begin
                                 port_excl_nxt_state[p] = open_access;
                                 port_excl_fail_x[p]    = 1'b1; //doesn't update memory
                            end
                            else begin
                                 port_excl_nxt_state[p] = open_access;
                            end
                      excl_access:
                            if(llock_trans_x[p]) begin // LLOCK(x,p)
                                 port_excl_nxt_state[p] = excl_access;
                                 tagging_addr_en_x[p]   = 1'b1; //tag address
                            end
                            else if(scond_trans_x[p] & store_addr_hit[p]) begin // SCOND(t,p)
                                 port_excl_nxt_state[p] = open_access;
                                 port_excl_done_x[p]    = 1'b1; // successful
                            end
                            else if(scond_trans_x[p] & (~store_addr_hit[p])) begin // SCOND(!t,p)
                                 port_excl_nxt_state[p] = open_access;
                                 port_excl_fail_x[p]    = 1'b1; // doesn't update memory
                            end
                            else if(scond_trans_nx[p] & store_addr_hit[p]) begin  // SCOND(t,!p), update memory
                                if(mem_update_fail)
                                 port_excl_nxt_state[p] = excl_access;
                                else
                                 port_excl_nxt_state[p] = open_access;
                            end
                            else if ((store_trans_x[p] | store_trans_nx[p]) & store_addr_hit[p]) begin // store(t,p), store(t,!p)
                                 port_excl_nxt_state[p] = open_access; // update memory
                            end
                            else begin
                                 port_excl_nxt_state[p] = excl_access;
                            end
                        default:
                           port_excl_nxt_state[p] = excl_access;
                    endcase
                 end // excl_nxt_state_PROC

               // exclusive monitor state transition
               always @(posedge clk or negedge rst_b)
                 begin : excl_cur_state_PROC
                    if(!rst_b) begin
                         port_excl_cur_state[p] <= open_access;
                    end
                    else begin
                         port_excl_cur_state[p] <= port_excl_nxt_state[p]; // state update
                    end
                 end // excl_state_PROC

               // tagged id and address for llock
               always @(posedge clk or negedge rst_b)
                 begin : tagged_llock_PROC
                    if(!rst_b) begin
                         tagged_blk_excl_addr[p] <= {(a_w-excl_alsb){1'b0}};
                    end
                    else if(tagging_addr_en_x[p]) begin
                         tagged_blk_excl_addr[p] <= i_ibp_cmd_addr[a_w-1:excl_alsb];
                    end
                 end // tagged_llock_PROC

            end // for (p=0;...)
    end //}block:no_pass_PROC
endgenerate

endmodule //alb_mss_mem_ibp_excl.vpp

