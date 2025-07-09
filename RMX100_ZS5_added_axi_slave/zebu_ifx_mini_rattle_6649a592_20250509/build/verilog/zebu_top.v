// Library ARCv2_ZEBU_RDF-2.0.999999999

module zebu_top;

    /**** DUT Instanciation ****/
    wire jtag_transcator_clk;
    wire ref_clk;
    wire rst_a;
    // JTAG XTOR
    wire jtag_tck;
    wire jtag_tms;
    wire jtag_tdi;
    wire jtag_tdo;
    wire jtag_trstn;
    
    core_chip core_chip_dut (
        .eclk         (ref_clk)
        , .erst_n       (~rst_a)
        , .ejtag_tck    (jtag_tck)
        , .ejtag_tms    (jtag_tms)
        , .ejtag_tdi    (jtag_tdi)
        , .ejtag_tdo    (jtag_tdo)
        , .ejtag_trst_n (jtag_trstn)
        
    );


`ifdef SIMULATE_ONLY
    /**** Simulation Clock ****/

    parameter sim_cycle = 10;
    logic clk = 1;

    always begin
        clk = #(sim_cycle/2) ~clk;
    end

    assign ref_clk = clk;

`else // SIMULATE_ONLY

    /**** Emulation Clock ****/
    //zceiClockPort REF_CLK (.cclock(ref_clk), .creset(), .cresetn());
     clockDelayPort zebuclk_ref_clk(
                .clock (ref_clk)); 
     clockDelayPort zebuclk_jtag_clk(
                .clock (jtag_transactor_clk));
    clockDelayPort zebuclk_uart_sclk(
                .clock (uart_sclk)); 
    /**** JTAG Instanciation ****/
    wire jtag_srstn;
    wire jtag_srstn_oe;
    wire [63:0] jtag_tdomsg;
    wire [127:0] jtag_xtor_info_port;

    //zceiClockPort JTAG_CLK (.cclock (jtag_tck), .creset(), .cresetn());
    //`if (`ZEBU_VERSION == `ZEBU_BOX_ZEBU_VERSION_ZS4)
    //defparam i_t32Jtag_driver.jtagCtrl="JTAG_CLK";
    //`endif
    xtor_t32Jtag_svs i_t32Jtag_driver(
        .clk   (jtag_transactor_clk),
        .rstn  (~rst_a),
        .TCK       (jtag_tck),
        .RTCK      (ref_clk),
        .TMS       (jtag_tms),
        .TDI       (jtag_tdi),
        .TRSTn     (jtag_trstn),
        .SRSTn     (jtag_srstn),
        .SRSTn_oe  (jtag_srstn_oe),
        .TDO       (jtag_tdo),
        .TDOMsg    (jtag_tdomsg),
        .jtag_xtor_info_port (jtag_xtor_info_port)
    );
     
    
    
    /**** Emulation Triggers ****/
    `include "zebu_triggers.v"

    /**** Wave Dumps ****/
    //`include "zebu_dumpvars.v"
     `include "qiwc_dumpvars.v"

    /**** C-cosim support ****/
    //C_COSIM c_cosim_driver();
    //defparam c_cosim_driver.cclock = "REF_CLK.cclock";

    /**** Clock counters ****/
    reg [63:0] ref_clk_cnt = 0;
    always @(posedge ref_clk) ref_clk_cnt <= ref_clk_cnt + 64'h1;

    //reg [63:0] jtag_tck_cnt = 0;
    //always @(posedge jtag_tck) jtag_tck_cnt <= jtag_tck_cnt + 64'h1;


`endif // SIMULATE_ONLY

endmodule

