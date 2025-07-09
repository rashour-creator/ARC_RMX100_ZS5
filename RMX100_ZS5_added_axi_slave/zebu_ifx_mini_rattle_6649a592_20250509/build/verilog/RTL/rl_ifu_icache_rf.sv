//----------------------------------------------------------------------------
//
// Copyright (C) 2010-2023 Synopsys, Inc. All rights reserved.
//
/// SYNOPSYS CONFIDENTIAL - This is an unpublished, proprietary 
// work of Synopsys, Inc., and is fully protected under copyright and 
// trade secret laws. You may not view, use, disclose, copy, or distribute 
// this file or any information contained herein except pursuant to a 
// valid written license from Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
// Description:
// @p
//  
//  
// @e
//
//  
//
//  The module hierarchy, at and below this module, is:
//
//
//
// ===========================================================================
//
// Configuration-dependent macro definitions
//
`include "defines.v"
`include "ifu_defines.v"

// Set simulation timescale
//
`include "const.def"

module rl_ifu_icache_rf (

  ////////// General input signals ///////////////////////////////////////////
  //
  input                           clk,
  input                           rst_a,

  input                           rst_init_disable_r,
  input                           sr_dbg_cache_rst_disable,

  ////////// FENCEI I$ Invalidate interface ///////////////////////////
  //
  input                           spc_fence_i_inv_req,   // Invalidate request to IFU
  output reg                      spc_fence_i_inv_ack_r, // Acknowledgement that Invalidation is complete
  input                           kill_ic_op,            // Terminate Ongoing ICMO Op due to fetch restart

  ////////// I-Cache interface ///////////////////////////////////////////////
  //
  // -- I-Cache Aux Op Interface
  input                           ic_rf_ivic,
  input                           ic_ctl_cache_inst,
  input                           ic_rf_ivil,
  input                           ic_rf_lil,
  input                           ic_rf_ulil,   
  input                           ic_rf_idx_ivil,
  input                           ic_rf_idx_rd_tag,  
  input                           ic_rf_idx_rd_data, 
  input                           ic_rf_idx_wr_tag,  
  input                           ic_rf_idx_wr_data, 
  input                           ic_rf_prefetch,
  input       [`DATA_RANGE]       ic_rf_wr_data,
  input       [`DATA_RANGE]       ic_icmo_adr,
  input                           icmo_done,


  input      [31:0]               aux_ic_ram_addr_r,
  output reg                      rf_ic_cache_instr_done,
  output reg                      rf_reset_done,

  input                           cwf_valid_r,

  
  input      [`IC_WAY_RANGE]      ic_hit_way_hot,  

  input                           ic_tag_ecc_sb_err,
  input                           ic_tag_ecc_db_err,
  input      [`IC_WAY_RANGE]      ic_ctl_hit_way_hot,  
  input      [`IC_WAY_RANGE]      ic_ctl_valid_way_hot,
  input      [`IC_WAY_RANGE]      ic_ctl_lock_way_hot,
  
  input                           ic_rf_req,
  input                           ic_rf_in_progress_r,
  input                           ic_rf_in_progress_nxt,
  output reg                      ic_rf_ack,
  input                           ic_rf_unc,     // uncached
  input                           continue_unc_transfer,
  input      [`IFU_ADDR_RANGE]    ic_rf_addr,  
  input      [`IFU_ADDR_RANGE]    ic_rf_addr_next,  
// leda NTL_CON13C on
  input      [`IC_WAY_RANGE]      ic_rf_way_hot, // this is the replacement way
  input      [1:0]                ic_f1_data_fwd,

  output reg                      rf_req_it, 
  output reg                      rf_it_read,
  output reg                      rf_it_cs,
  output reg [`IC_IDX_RANGE]      rf_it_addr,
  output reg                      rf_it_valid,
  output reg                      rf_it_lock,
  output reg [`IC_TAG_TAG_RANGE]  rf_it_tag,
                       
  output reg                      rf_req_id,
  output reg                      rf_id_cs,
  output reg                      rf_id_read,
  output reg [`IC_DATA_ADR_RANGE] rf_id_addr,
  output reg [`IC_DATA_RANGE]     rf_id_data,


  output reg [`IC_WAY_RANGE]      rf_way_hot,

  output                          rf_done,
  output reg                      rf_done_r,
  output reg                      rf_err,

  output reg                      ic_init, 

  output reg  [10:0]        rf_data_counter,
  output reg  [`IC_IDX_RANGE]     rf_ic_counter,
  ////////////// Pipeline restart //////////////////////////////////////////
  //
  input                           fch_restart,
  
  ////////// Ibus interface //////////////////////////////////////////////////
  //
  output reg [`ADDR_RANGE]        rf_cmd_address,
  output reg [`ADDR_RANGE]        rf_cmd_addr_r,
  input      [`DATA_RANGE]        rf_rd_data,
  output reg                      rf_cmd_valid,
  input                           rf_cmd_accept,
  output reg                      rf_cmd_accept_r,
  output reg [`IC_WRD_RANGE]      rf_cmd_burst_size,
  output reg [3:0]                rf_cmd_cache,
                                                
  input                           rf_rd_valid,
  input                           rf_rd_err,
  input                           rf_rd_last,
  output reg                      rf_rd_accept

);


reg                        prefetch_rf_in_prg;
reg                        prefetch_rf_in_prg_r;
// Local variables
reg  [`DATA_RANGE]         rf_rd_data_r;
reg  [10:0]          rf_data_counter_next;

reg                        kill_ic_op_r;
reg  [`IC_IDX_RANGE]       rf_ic_counter_next;

reg  [`IC_WAY_RANGE]       rf_replacement_way_hot;

//reg                        rf_done_r;
reg                        rf_done_next;
reg                        rf_err_next; 

reg                        rf_unc;
reg                        rf_unc_next;

reg  [2:0]                 rf_state;  
reg  [2:0]                 rf_state_next;  

reg                        rf_get_lock_way;
reg                        rf_get_lock_way_next;

reg                        rf_lock_hit_all_valid;
reg                        rf_all_ways_inval;
reg                        rf_way_available;
reg                        rf_prefetch_valid;

reg  [`IC_WAY_RANGE]       rf_lock_way_hot;
reg  [`IC_WAY_RANGE]       rf_prefetch_way_hot;
reg                        rf_prefetch_victim_way;
wire                       rf_prefetch_victim_way_nxt;

reg  [1:0]                 rf_cache_state;
reg  [1:0]                 rf_cache_state_next;


wire [`IC_IDX_RANGE]       rf_cache_index;
wire [`IC_WRD_RANGE]       rf_cache_offset;
wire [`IC_WAY_CACHE_RANGE] rf_cache_way;
reg                        rf_cmd_pending;
reg                        rf_cmd_pending_next;

reg                        rf_reset_done_next; 

reg                        rf_rd_valid_r;
reg                        rf_rd_last_r;
reg                        rf_rd_err_r;
reg                        rf_cmd_valid_r;

// Internal wires 
//
wire                       rf_rd_valid_i;
wire                       rf_rd_last_i;
wire                       rf_rd_err_i;
wire [`DATA_RANGE]         rf_rd_data_i;
reg                        ic_rf_bank_sel_r;
reg                        spc_fence_i_inv_ack_nxt;

assign rf_cache_index    = aux_ic_ram_addr_r[`IC_IDX_RANGE];
assign rf_cache_offset   = aux_ic_ram_addr_r[`IC_WRD_RANGE];
assign rf_cache_way      = aux_ic_ram_addr_r[`IC_WAY_CACHE_RANGE];
//////////////////////////////////////////////////////////////////////////////
// Selection of either the register or unregistered inputs
//
//////////////////////////////////////////////////////////////////////////////

assign rf_rd_valid_i     = rf_rd_valid_r;
assign rf_rd_last_i      = rf_rd_last_r;
assign rf_rd_err_i       = rf_rd_err_r;
assign rf_rd_data_i      = rf_rd_data_r;

 // Module definition

parameter RF_STATE_IDLE           = 3'b000;
parameter RF_STATE_WAIT_DATA      = 3'b001;
parameter RF_STATE_RESET          = 3'b010;
parameter RF_STATE_CACHE_INST     = 3'b011;
parameter RF_STATE_INIT           = 3'b100;
parameter RF_STATE_WAIT_UNC_DATA  = 3'b101;

parameter RF_CACHE_DEFAULT        = 2'b00;   
parameter RF_CACHE_ACTION         = 2'b01;   
parameter RF_CACHE_LOCK_WAIT_DATA = 2'b10;   


// This is the FSM. It gets data from the ibus and puts into the itag and
// idata memories

always @*
  begin : fsm_comb_PROC
    ic_rf_ack                       = 1'b0;
                                     
    rf_cmd_valid                    = 1'b0;   
    //rf_cmd_address                  = {ic_rf_addr[`ADDR_MSB:`IC_IDX_ID], `IC_WRD_WIDTH'b0, 2'b00}; 
    rf_cmd_address                  = {ic_rf_addr, 2'b00}; 
    rf_cmd_burst_size               = {`IC_WRD_WIDTH{1'b1}};                
    rf_rd_accept                    = 1'b1;   // always accept             
    rf_cmd_cache                    = 4'b0110; // [2]: Read Allocate [1] Cacheable
                                                                           
    rf_req_it                       = 1'b0;                                
    rf_it_cs                        = 1'b0;
    rf_it_read                      = 1'b0;                                
    rf_it_addr                      = ic_rf_addr[`IC_IDX_RANGE];           
    rf_it_valid                     = 1'b0;                                
    rf_it_lock                      = 1'b0;
    rf_it_tag                       = ic_rf_addr[`IC_TAG_RANGE];           
  
    rf_req_id                       = 1'b0;                                
    rf_id_cs                        = 1'b0;  
    rf_id_read                      = 1'b0;                              
    rf_id_addr                      = {ic_rf_addr[`IC_SET_IDX_RANGE],
                                       rf_data_counter[2:0]};
    rf_id_data                      = rf_rd_data_i;                          
                                                                           
    rf_way_hot                      = rf_replacement_way_hot;              
                                                                           
    rf_data_counter_next            = rf_data_counter;                     
    rf_ic_counter_next              = rf_ic_counter;                       
                                                                           
    rf_done_next                    = rf_done_r;                             
    rf_err_next                     = rf_err & (~fch_restart);                        
    rf_state_next                   = rf_state;                            
  
    rf_unc_next                     = rf_unc;
    
    rf_get_lock_way_next            = 1'b0;
    
    rf_lock_hit_all_valid           = 1'b0;
    rf_all_ways_inval               = 1'b0;
    rf_way_available                = 1'b0;
    rf_prefetch_valid               = 1'b0;
    
    rf_ic_cache_instr_done          = 1'b0;
    
    rf_cmd_pending_next             = rf_cmd_pending;
    rf_reset_done_next              = rf_reset_done;
  
    rf_cache_state_next             = rf_cache_state;
    spc_fence_i_inv_ack_nxt         = 1'b0;
    ic_init                         = 1'b0;
    prefetch_rf_in_prg              = 1'b0;
                                                                             
    case (rf_state)                                                        
    RF_STATE_IDLE:                                                         
    begin                                                                  
      if (((ic_rf_ivic & ic_ctl_cache_inst) | (spc_fence_i_inv_req & ~spc_fence_i_inv_ack_r))
          & !rf_cmd_pending
         )
        begin                                                                
          // Flush has higher priority                                       
                                                                             
          rf_done_next  = 1'b0;                                              
          rf_err_next   = 1'b0;                                         
          rf_state_next = RF_STATE_INIT;                                    
        end
      else if (  (  ic_rf_ivil
                  | ic_rf_lil
                  | ic_rf_ulil
                  | ic_rf_idx_ivil
                  | ic_rf_idx_rd_tag
                  | ic_rf_idx_rd_data
                  | ic_rf_idx_wr_tag
                  | ic_rf_idx_wr_data
                  | ic_rf_prefetch
                  )
               & !rf_cmd_pending
               & ic_ctl_cache_inst
               )   
        begin
          rf_err_next         = 1'b0;
          rf_done_next        = 1'b0;                                              
          rf_state_next       = RF_STATE_CACHE_INST;
        end
      else if (ic_rf_req)                                                  
        begin                                                                
          rf_cmd_valid           = 1'b1; 
          //rf_data_counter_next   = `IC_WRD_WIDTH'h0;   
          rf_data_counter_next[2:0] = ic_rf_addr[`IC_WRD_RANGE]; 
          rf_done_next           = 1'b0;  
          rf_err_next            = 1'b0;                                         
          
          if (ic_rf_unc)
            begin
              // Uncached single transaction. Ajust transaction attributes 
              // accordingly
              //
              rf_cmd_address       = {ic_rf_addr, 2'b00}; 
              
              rf_cmd_burst_size    = `IC_WRD_WIDTH'b0;  
             
              rf_unc_next          = 1'b1;
              rf_cmd_cache         = 4'b0; 
            end
          
          ic_rf_ack            = 1'b1;
          rf_state_next        = ic_rf_unc ? RF_STATE_WAIT_UNC_DATA : RF_STATE_WAIT_DATA;
        end                                                                  
    end                                                                    
                                                                           
                                                                           
    RF_STATE_WAIT_UNC_DATA:
    begin
      rf_req_it    = 1'b0; 
      rf_it_cs     = 1'b0; 
      rf_it_valid  = 1'b0; 
      rf_req_id    = 1'b0; 
      
      rf_id_cs     =  1'b0;
      // Set rf_err_next if there is an incoming read error, or
      // if a read error has already been detected during this refill.
      //
      rf_err_next           = rf_err; 
      rf_done_next          = 1'b0;
      rf_cmd_burst_size     = `IC_WRD_WIDTH'b0;  
      rf_cmd_cache          = 4'b0; 
      if (rf_cmd_valid_r)
      begin
        if (rf_cmd_accept_r)
        begin
          ic_rf_ack              = 1'b1;
          rf_cmd_address         = rf_cmd_addr_r;
          if (rf_rd_last & ((cwf_valid_r & ic_f1_data_fwd[0]) | ~cwf_valid_r))
          begin
            rf_cmd_valid         = ic_rf_req; 
            rf_cmd_burst_size    = `IC_WRD_WIDTH'b0;  
            rf_unc_next          = 1'b1;
            rf_cmd_cache         = 4'b0; 
            rf_cmd_address       = {ic_rf_addr, 2'b00}; 
            if (~continue_unc_transfer)
            begin
              rf_cmd_valid         = 1'b0; 
              rf_state_next        = RF_STATE_IDLE;
            end
            else
            begin
              rf_state_next        = (ic_rf_req | ic_rf_in_progress_r) ? RF_STATE_WAIT_UNC_DATA : RF_STATE_IDLE;
            end
            //rf_state_next        = (ic_rf_req & (~rf_rd_last))? RF_STATE_WAIT_UNC_DATA : RF_STATE_IDLE;
            rf_done_next         = 1'b1;
          end
          else if (rf_rd_last & (~continue_unc_transfer))
          begin
            rf_state_next        = RF_STATE_IDLE;
            rf_cmd_valid         = 1'b0; 
          end
        end
        else
        begin
          // Command Issued No accept retain prev data
          rf_cmd_valid         = 1'b1; 
          rf_cmd_burst_size    = `IC_WRD_WIDTH'b0;  
          rf_unc_next          = 1'b1;
          rf_cmd_cache         = 4'b0; 
          //rf_cmd_address       = {ic_rf_addr_next, 2'b00}; 
          rf_cmd_address       = rf_cmd_addr_r; 
          rf_state_next        = RF_STATE_WAIT_UNC_DATA; 
          rf_done_next         = 1'b0;
        end
      end
      else if (rf_rd_last | ic_rf_req)
      begin
        // Issue New Command if requested
        // @@ situation might not come
        rf_cmd_valid         = ic_rf_req; 
        rf_cmd_burst_size    = `IC_WRD_WIDTH'b0;  
        rf_unc_next          = 1'b1;
        rf_cmd_cache         = 4'b0; 
        rf_cmd_address       = {ic_rf_addr_next, 2'b00}; 
        //rf_state_next        = (ic_rf_req & (~rf_rd_last))? RF_STATE_WAIT_UNC_DATA : RF_STATE_IDLE;
        //rf_state_next        = (ic_rf_req)? RF_STATE_WAIT_UNC_DATA : RF_STATE_IDLE;
        if (~continue_unc_transfer)
        begin
          rf_state_next        = RF_STATE_IDLE;
          rf_cmd_valid         = 1'b0;
        end
        else
        begin
          rf_state_next        = (ic_rf_req | ic_rf_in_progress_r) ? RF_STATE_WAIT_UNC_DATA : RF_STATE_IDLE;
        end
        rf_done_next         = 1'b1;
      end
      else if (~ic_rf_in_progress_nxt)
      begin
        rf_state_next        = RF_STATE_IDLE;
        rf_cmd_valid         = 1'b0;
      end
      else if (~ic_rf_in_progress_r)
      begin
        rf_state_next        = RF_STATE_IDLE;
        rf_cmd_valid         = 1'b0;
      end
    end
 
  
    RF_STATE_WAIT_DATA:                                                    
    begin                                                                  
      rf_req_it    = !rf_unc;                                                 
      rf_it_cs     = ((rf_rd_valid_i & rf_rd_last_i)
                     )
                      & !rf_unc;
      rf_it_valid  = !rf_unc & !rf_err;                                                  
      rf_req_id    = !rf_unc;                                          
      
      rf_id_cs     = rf_rd_valid_i & !rf_unc & !rf_err;                                    
      // Set rf_err_next if there is an incoming read error, or
      // if a read error has already been detected during this refill.
      //
      rf_err_next           = rf_err | (rf_rd_valid & rf_rd_err);

      if (rf_cmd_valid_r & (~rf_cmd_accept_r))
        begin
          rf_cmd_valid              = 1'b1; 
          rf_data_counter_next      = rf_cmd_addr_r[`IC_WRD_RANGE]; 
          rf_done_next              = 1'b0;  
          rf_cmd_burst_size         = {`IC_WRD_WIDTH{1'b1}};                
          rf_cmd_cache              = 4'b0110; // [2]: Read Allocate [1] Cacheable
        end
      else if (rf_rd_valid_i)                                                     
        begin                                                                
          // New data coming in. I am always ready to accept it.             
  
          rf_data_counter_next = rf_data_counter + `IC_WRD_WIDTH'b1;
          
          if (rf_rd_last_i)                                                    
            begin                                                             
              // We are done refilling the line                               
              rf_unc_next           = 1'b0;
              rf_done_next          = 1'b1;                                   
              rf_state_next         = RF_STATE_IDLE;                          
            end                                                               
        end                                                                  
    end                                                                    

// spyglass disable_block CDC_COHERENCY_RECONV_SEQ
// SMD: Multiple source signals from different domains converge after synchronization
// SJ: There is no dependency between these source signals  
    RF_STATE_RESET :
    begin
      rf_ic_counter_next = rf_ic_counter + `IC_IDX_WIDTH'b1; 
      rf_reset_done_next = 1'b0;
      if (rf_ic_counter == `IC_IDX_WIDTH'b0)
      begin
        rf_ic_counter_next = `IC_IDX_WIDTH'b0; 
        if ((rst_init_disable_r == 1'b0) && (sr_dbg_cache_rst_disable == 1'b0))
        begin
          rf_state_next = RF_STATE_INIT;
          rf_reset_done_next = 1'b0;
        end
        else
        begin
          rf_state_next = RF_STATE_IDLE;
          rf_reset_done_next = 1'b1;
        end
      end
    end
// spyglass enable_block CDC_COHERENCY_RECONV_SEQ
     
    RF_STATE_INIT:                                                        
    begin                                                                  
      // we come here after reset.Need to initialize (invalidate) 
      // the tag memories    
                                                                           
      rf_req_it          = 1'b1;                                           
      rf_it_cs           = 1'b1;                                           
      rf_it_addr         = rf_ic_counter;                                  
      rf_it_valid        = 1'b0;                                           
      rf_it_tag          = {`IC_TAG_BITS{1'b0}}; // write zeros to the tags
      ic_init            = 1'b1;
      if (rf_reset_done == 1'b0)
      begin
        rf_req_id          = 1'b1;                                           
        rf_id_cs           = 1'b1;                                           
        rf_id_addr         = rf_data_counter;                                  
        rf_id_data         = {`DATA_SIZE{1'b0}}; // write zeros to the tags
      end
                                                                           
      rf_way_hot         = {`IC_WAYS{1'b1}};
       
      rf_ic_counter_next = rf_ic_counter + `IC_IDX_WIDTH'b1;

      rf_data_counter_next = rf_data_counter + `IC_DATA_ADR_WIDTH'b1;
      if (rf_reset_done == 1'b1)
      begin
        if ((&rf_ic_counter) | (kill_ic_op))
          begin
            // We are done invalidating
            rf_ic_counter_next     = `IC_IDX_WIDTH'b0;
            rf_done_next           = 1'b1;
            rf_ic_cache_instr_done = 1'b1;
            rf_reset_done_next     = 1'b1;
            rf_state_next          = RF_STATE_IDLE;
            if (spc_fence_i_inv_req == 1'b1)
            begin
              spc_fence_i_inv_ack_nxt = 1'b1;
            end
          end
      end
      else
      begin
        if (&rf_ic_counter)
          begin
            // We are done invalidating
            rf_ic_counter_next     = rf_ic_counter; 
            rf_it_cs               = 1'b0;
          end
        if (&rf_data_counter)
          begin
            // We are done invalidating
            rf_ic_counter_next     = `IC_IDX_WIDTH'b0;
            rf_data_counter_next   = `IC_DATA_ADR_WIDTH'b0;
            rf_done_next           = 1'b1;
            rf_ic_cache_instr_done = 1'b1;
            rf_reset_done_next     = 1'b1;
            rf_state_next          = RF_STATE_IDLE;
          end
      end
    end
  
    RF_STATE_CACHE_INST:
    begin
      // This is the state machine that deals with CACHE instructions
      //
      case (rf_cache_state)
      RF_CACHE_DEFAULT:
      begin
        // Perform a cache lookup
        //
        
        rf_req_it           = 1'b1;   
        rf_it_cs            = 1'b1;
        rf_it_read          = 1'b1;
        rf_way_hot[0]       = ~ic_icmo_adr[`IC_TAG_LSB];
        rf_way_hot[1]       = ic_icmo_adr[`IC_TAG_LSB];
        rf_it_addr          = ic_icmo_adr[`IC_IDX_RANGE];
        
        //if (ic_rf_read_cache)
        if (ic_rf_idx_rd_data)
          begin
            rf_req_id         = 1'b1;
            rf_id_cs          = 1'b1;
            rf_id_read        = 1'b1;
            //rf_id_addr        = ic_rf_addr[`IC_DATA_ADR_RANGE];
            rf_id_addr        = ic_icmo_adr[`IC_DATA_ADR_RANGE];
          end
        rf_get_lock_way_next = ic_rf_lil | ic_rf_ulil | ic_rf_prefetch;
        rf_cache_state_next  = RF_CACHE_ACTION;
      end
      
      RF_CACHE_ACTION:
      begin
        case (1'b1)
        ic_rf_ivil:
        begin
          // This is a invalidate line CACHE instruction
          if ((| ic_ctl_hit_way_hot) & (~(kill_ic_op | kill_ic_op_r)))
            begin
              // The line is in the cache. Let's invalidate and unlock it 
              //
              rf_req_it           = 1'b1;   
              rf_it_cs            = 1'b1;
              rf_it_read          = 1'b0;
              rf_it_valid         = 1'b0;                                           
              rf_it_lock          = 1'b0;                                           
              rf_it_tag           = {`IC_TAG_BITS{1'b0}}; // write zeros to the tags    
              rf_way_hot          = ic_ctl_hit_way_hot; 
            end
          
          rf_done_next           = 1'b1;
          rf_ic_cache_instr_done = 1'b1; 
          rf_cache_state_next    = RF_CACHE_DEFAULT; 
          rf_state_next          = RF_STATE_IDLE;    
        end
        
        ic_rf_lil:
        begin
          // This is a lock line CACHE instruction
          //
          rf_way_hot             = ic_ctl_hit_way_hot;
          if (((& ic_ctl_lock_way_hot) 
               & !(| ic_ctl_hit_way_hot)) // No Valid way bit both ways are locked 
               | kill_ic_op | kill_ic_op_r
             )
            begin
              // All the ways for this set is already locked and we are not
              // attempting to relock a previously locked line. This CACHE
              // instruction fails
              // 
              rf_done_next           = 1'b1;
              rf_ic_cache_instr_done = 1'b1; 
              rf_cache_state_next    = RF_CACHE_DEFAULT; 
              rf_state_next          = RF_STATE_IDLE;    
            end
          else
            begin
              // Be careful selecting the way to be locked when the requested
              // line is already in the cache or all the ways in that set are
              // valid. If it is hit, just lock the hit way. If all the ways are
              // valid, pick up the first unlocked way
              //
              rf_lock_hit_all_valid           =   (& ic_ctl_valid_way_hot)
                                                | (| ic_ctl_hit_way_hot); 
              rf_all_ways_inval               = (~(|ic_ctl_valid_way_hot));
              rf_way_available                = (|ic_ctl_valid_way_hot);

              // Let's go ahead and Lock this cache line
              //
              rf_cmd_valid                    = 1'b1;   
              rf_data_counter_next            = ic_icmo_adr[`IC_WRD_RANGE];
              rf_done_next                    = 1'b0;                          
            
              if (rf_cmd_accept)
                begin
                  ic_rf_ack                     = 1'b1;
                  rf_cache_state_next           = RF_CACHE_LOCK_WAIT_DATA;            
                end
            end
        end

        ic_rf_ulil:
        begin
          // This is a unlock line CACHE instruction
          //
         rf_cache_state_next    = RF_CACHE_DEFAULT; 
         rf_state_next          = RF_STATE_IDLE;    
         rf_ic_cache_instr_done = 1'b1; 
         rf_way_hot             = ic_ctl_hit_way_hot;
          if (|(ic_ctl_lock_way_hot & ic_ctl_hit_way_hot))
            begin
              // if ic_hit way is locked.
              // Unlock the line
              rf_req_it              = 1'b1;                                               
              rf_it_cs               = 1'b1; 
              rf_it_valid            = 1'b1; 
              rf_it_lock             = 1'b0; 
            end
        end

        ic_rf_idx_ivil:
        begin
          rf_req_it              = 1'b1;
          rf_it_cs               = 1'b1; 
          rf_it_valid            = 1'b0; 
          rf_it_lock             = 1'b0; 
          rf_ic_cache_instr_done = 1'b1; 
          rf_way_hot[0]          = ~ic_icmo_adr[`IC_TAG_LSB]; 
          rf_way_hot[1]          = ic_icmo_adr[`IC_TAG_LSB];
          rf_cache_state_next    = RF_CACHE_DEFAULT; 
          rf_state_next          = RF_STATE_IDLE;    
        end

        ic_rf_idx_rd_tag:
        begin
          rf_ic_cache_instr_done      = 1'b1; 
          rf_cache_state_next         = RF_CACHE_DEFAULT; 
          rf_state_next               = RF_STATE_IDLE;    
          rf_way_hot[0]               = ~ic_icmo_adr[`IC_TAG_LSB]; 
          rf_way_hot[1]               = ic_icmo_adr[`IC_TAG_LSB];
        end

        ic_rf_idx_wr_tag:
        begin
          rf_req_it                       = 1'b1;  
          rf_it_cs                        = 1'b1;
          rf_it_read                      = 1'b0;
          rf_it_valid                     = ic_rf_wr_data[`IC_TAG_VALID_BIT]; 
          rf_it_lock                      = ic_rf_wr_data[`IC_TAG_LOCK_BIT];
          rf_it_tag                       = ic_rf_wr_data[`IC_TAG_RANGE];
          rf_it_addr                      = ic_icmo_adr[`IC_IDX_RANGE];           
          
          rf_way_hot[0]                   = ~ic_icmo_adr[`IC_TAG_LSB]; 
          rf_way_hot[1]                   = ic_icmo_adr[`IC_TAG_LSB];
          
          rf_ic_cache_instr_done          = 1'b1; 
          rf_cache_state_next             = RF_CACHE_DEFAULT; 
          rf_state_next                   = RF_STATE_IDLE;    
        end

        ic_rf_idx_rd_data:
        begin
          rf_way_hot                  = ic_hit_way_hot;
          
          rf_ic_cache_instr_done      = 1'b1; 
          rf_cache_state_next         = RF_CACHE_DEFAULT; 
          rf_state_next               = RF_STATE_IDLE;    
          rf_way_hot[0]               = ~ic_icmo_adr[`IC_TAG_LSB]; 
          rf_way_hot[1]               = ic_icmo_adr[`IC_TAG_LSB];
        end
 
        ic_rf_idx_wr_data:
        begin
          rf_req_id                   = 1'b1;  
          rf_id_cs                    = 1'b1;
          rf_id_read                  = 1'b0;
          rf_id_data                  = ic_rf_wr_data; 
          //rf_id_addr                  = {rf_cache_index, rf_cache_offset};
          rf_id_addr                  = ic_icmo_adr[`IC_DATA_ADR_RANGE]; 
          
          rf_way_hot[0]               = ~ic_icmo_adr[`IC_TAG_LSB]; 
          rf_way_hot[1]               = ic_icmo_adr[`IC_TAG_LSB];
          
          rf_ic_cache_instr_done      = 1'b1; 
          rf_cache_state_next         = RF_CACHE_DEFAULT; 
          rf_state_next               = RF_STATE_IDLE;    
        end 

        ic_rf_prefetch:
        begin
          rf_data_counter_next   = ic_icmo_adr[`IC_WRD_RANGE]; 
          prefetch_rf_in_prg     = prefetch_rf_in_prg_r;
          if ((&ic_ctl_lock_way_hot) | (|ic_ctl_hit_way_hot)
               | ic_tag_ecc_sb_err | ic_tag_ecc_db_err
               | ((kill_ic_op | kill_ic_op_r) & (~prefetch_rf_in_prg_r)))
            begin
              rf_done_next                = 1'b1;
              rf_ic_cache_instr_done      = 1'b1; 
              rf_cache_state_next         = RF_CACHE_DEFAULT; 
              rf_state_next               = RF_STATE_IDLE;    
            end
          else
            begin
              rf_cmd_valid                    = 1'b1;   
              rf_prefetch_valid               = 1'b1;
              prefetch_rf_in_prg              = 1'b1;
              if (rf_cmd_accept)
                begin
                  ic_rf_ack                     = 1'b1;
                  rf_cache_state_next           = RF_CACHE_LOCK_WAIT_DATA;            
                end
            end
        end
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue.
        default:
          ;
// spyglass enable_block W193
        endcase
      end
      
      RF_CACHE_LOCK_WAIT_DATA:
      begin
        rf_req_it    = 1'b1;                                               
        rf_it_cs     = (rf_rd_valid_i & (rf_rd_err_i | (rf_rd_last_i)))
                      ;
        rf_it_valid  = !rf_err & (~(kill_ic_op | kill_ic_op_r));
        rf_it_lock   = !rf_err & !ic_rf_prefetch;
  
        rf_req_id    = 1'b1;                                               
        rf_id_cs     = rf_rd_valid_i & !rf_err;                                      
        // Set rf_err_next if there is an incoming read error, or
        // if a read error has already been detected during this refill.
        //
        rf_err_next           = rf_err | (rf_rd_valid & rf_rd_err);        
        
        if (rf_rd_valid_i)
          begin                                                              
            // New data coming in. I am always ready to accept it.           
            // leda W484 off - ignore carry-out of the incrementer below
            //
            rf_data_counter_next = rf_data_counter + `IC_WRD_WIDTH'b1;
                                                                             
            if (rf_rd_last_i)
              begin                                                           
                // We are done refilling and locking the line
                //                             
                rf_done_next           = 1'b1; 
                rf_ic_cache_instr_done = 1'b1;                               
                rf_cache_state_next    = RF_CACHE_DEFAULT; 
                rf_state_next          = RF_STATE_IDLE;    
              end
          end
      end
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue.
      default:
        ;
// spyglass enable_block W193
      endcase
    end
// spyglass disable_block W193
// SMD: Empty statement
// SJ: As designed. Empty default does not cause any functional issue.
    default:                                                                 
       ;                                                                     
// spyglass enable_block W193
    endcase
  end


// Little process to find out which way to lock when all ways in a given set
// are valid. It essentialy finds the first unlocked way.
//
always @*
  begin : rf_lock_way_PROC
    rf_lock_way_hot = {`IC_WAYS{1'b0}};  
    if (| ic_ctl_hit_way_hot)
      begin
        rf_lock_way_hot = ic_ctl_hit_way_hot;
      end
    else if (!ic_ctl_lock_way_hot[0])
      begin
        rf_lock_way_hot[0] = 1'b1;
      end
    else if (!ic_ctl_lock_way_hot[1])
      begin
        rf_lock_way_hot[1] = 1'b1;
      end
  end

always@*
  begin
    rf_prefetch_way_hot = {`IC_WAYS{1'b0}}; 
    if (|ic_ctl_lock_way_hot)
      begin
        rf_prefetch_way_hot[0] = (~ic_ctl_lock_way_hot[0])
                                      ;
        rf_prefetch_way_hot[1] = (~ic_ctl_lock_way_hot[1])
                                   & ic_ctl_lock_way_hot[0]
                                      ;
      end
    else if (&ic_ctl_valid_way_hot)
      begin
        rf_prefetch_way_hot[0]  = ~rf_prefetch_victim_way; 
        rf_prefetch_way_hot[1]  = rf_prefetch_victim_way; 
      end
    else if (|ic_ctl_valid_way_hot)
      begin
        rf_prefetch_way_hot[0] = (~ic_ctl_valid_way_hot[0])
                                      ;
        rf_prefetch_way_hot[1] = (~ic_ctl_valid_way_hot[1])
                                   & ic_ctl_valid_way_hot[0]
                                      ;
      end
    else
      begin
        rf_prefetch_way_hot[0] = 1'b1; 
      end
  end

always @(posedge clk or posedge rst_a)
  begin : refill_control_PROC
    if (rst_a == 1'b1)                     
      begin                          
        rf_state        <= RF_STATE_RESET; 
        rf_cache_state  <= RF_CACHE_DEFAULT;
        rf_unc          <= 1'b0;
        rf_done_r       <= 1'b0; 
        rf_cmd_pending  <= 1'b0;
        rf_reset_done   <= 1'b0;
        rf_err          <= 1'b0;
        rf_get_lock_way <= 1'b0;
      end
    else
      begin
        rf_state        <= rf_state_next;  
        rf_cache_state  <= rf_cache_state_next;
        rf_unc          <= rf_unc_next;
        rf_done_r       <= rf_done_next;   
        rf_cmd_pending  <= rf_cmd_pending_next;        
        rf_reset_done   <= rf_reset_done_next;        
        rf_err          <= rf_err_next;
        rf_get_lock_way <= rf_get_lock_way_next;
      end                            
  end

always @(posedge clk or posedge rst_a)
  begin
    if (rst_a == 1'b1)                     
      begin                          
        kill_ic_op_r <= 1'b0;
      end
    else
      begin
         if ((icmo_done == 1'b1) | (rf_state == RF_STATE_IDLE))
          begin
            kill_ic_op_r <= 1'b0; 
          end
         else if (kill_ic_op == 1'b1)
          begin
            kill_ic_op_r <= 1'b1;
          end
      end
  end

always @(posedge clk or posedge rst_a)
  begin : refill_counter_PROC
    if (rst_a == 1'b1)                                   
      begin                                        
        rf_data_counter  <= `IC_DATA_ADR_WIDTH'h0;                    
        //rf_ic_counter    <= `IC_IDX_WIDTH'h0;
        rf_ic_counter    <= {{6{1'b1}}, 2'b01}; 
      end                                          
    else                                         
      begin                                        
        rf_data_counter  <= rf_data_counter_next; 
        rf_ic_counter    <= rf_ic_counter_next;   
      end                                          
  end

// Grab inputs

always @(posedge clk or posedge rst_a)
  begin : rf_replace_way_PROC
    if (rst_a == 1'b1)
      rf_replacement_way_hot <= {`IC_WAYS{1'b0}};
    else
    begin
      if (  ic_rf_req
          | rf_get_lock_way
          )                              
        begin                                       
          if (rf_lock_hit_all_valid)
            begin
              rf_replacement_way_hot <= rf_lock_way_hot; 
            end
          else if (rf_all_ways_inval | rf_way_available)
            begin
              rf_replacement_way_hot <= rf_lock_way_hot; 
            end
          else if (rf_prefetch_valid)
            begin
              rf_replacement_way_hot <= rf_prefetch_way_hot; 
            end
          else
            begin
              rf_replacement_way_hot <= ic_rf_way_hot;
            end
        end
    end
  end




always @(posedge clk or posedge rst_a)
  begin
    if (rst_a == 1'b1)
      begin
        prefetch_rf_in_prg_r <= 1'b0; 
      end
    else
      begin
        prefetch_rf_in_prg_r <= prefetch_rf_in_prg; 
      end
  end

// Internal protocol

always @(posedge clk or posedge rst_a)
  begin : rf_rd_reg_PROC
    if (rst_a == 1'b1)
      begin
        rf_rd_valid_r   <= 1'b0;
        rf_rd_last_r    <= 1'b0;
        rf_rd_err_r     <= 1'b0;
        rf_cmd_valid_r  <= 1'b0;
        rf_cmd_accept_r <= 1'b0;
        rf_cmd_addr_r   <= 32'b0;
      end
    else
      begin
        rf_rd_valid_r   <= rf_rd_valid;
        rf_rd_last_r    <= rf_rd_last;
        rf_rd_err_r     <= rf_rd_err;
        rf_cmd_valid_r  <= rf_cmd_valid;
        rf_cmd_accept_r <= rf_cmd_accept;
        rf_cmd_addr_r   <= rf_cmd_address;
      end
  end

// spyglass disable_block STARC-2.3.4.3
// SMD: Has neither asynchronous set nor asynchronous reset
// SJ:  Datapath items not reset
always @(posedge clk or posedge rst_a)
  begin : rf_rd_data_PROC
    if (rst_a == 1'b1)
      begin
        rf_rd_data_r <= `IC_DATA_SIZE'b0;  
      end
    else
      begin
        rf_rd_data_r <= rf_rd_data;
      end
  end
// spyglass enable_block STARC-2.3.4.3


always @(posedge clk or posedge rst_a)
  begin : spc_fence_i_inv_ack_reg_PROC
    if (rst_a == 1'b1)
      begin
        spc_fence_i_inv_ack_r <= 1'b0;
      end
    else
      begin
        spc_fence_i_inv_ack_r <= spc_fence_i_inv_ack_nxt; 
      end
  end

always@(posedge clk or posedge rst_a)
  begin
    if (rst_a == 1'b1)
      begin
        rf_prefetch_victim_way <= 1'b0; 
      end
    else
      begin
        if (ic_rf_prefetch)
          begin
            rf_prefetch_victim_way <= rf_prefetch_victim_way_nxt; 
          end
      end
  end
assign rf_prefetch_victim_way_nxt = ~rf_prefetch_victim_way;

// Output drivers
//
assign rf_done     = rf_done_next;
//assign rf_done     = rf_done_r;


endmodule // rl_ifu_icache_rf
