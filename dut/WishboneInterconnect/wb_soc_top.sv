module wb_soc_top (

    // wb interface 
    input  logic        wb_clk,
    input  logic        wb_rst,

    input  logic [31:0] wb_m2s_adr,
    input  logic [31:0] wb_m2s_dat,
    input  logic  [3:0] wb_m2s_sel,
    input  logic        wb_m2s_we,
    input  logic        wb_m2s_cyc,
    input  logic        wb_m2s_stb,
    output logic [31:0] wb_s2m_dat,
    output logic        wb_s2m_ack,

    // spi 1
    output logic       o_spi_1_sclk,     // serial clock output
    output logic       o_spi_1_cs_n,     // slave select (active low)
    output logic       o_spi_1_mosi,     // MasterOut SlaveIN
    input  logic       i_spi_1_miso,     // MasterIn SlaveOut  

    // spi 2
    output logic       o_spi_2_sclk,     // serial clock output
    output logic       o_spi_2_cs_n,     // slave select (active low)
    output logic       o_spi_2_mosi,     // MasterOut SlaveIN
    input  logic       i_spi_2_miso,     // MasterIn SlaveOut  
   
   
    // i2c 
    inout wire sda,
    inout wire scl,
 

    // uart
    output logic        o_uart_tx,
    input logic         i_uart_rx
);

    logic        wb_s2m_err;
    logic        wb_s2m_rty;

    // ============================================
    //       Wishbone Interconnect
    // ============================================   

    // SPI I
    wire [31:0] wb_m2s_spi_1_adr;
    wire [31:0] wb_m2s_spi_1_dat;
    wire  [3:0] wb_m2s_spi_1_sel;
    wire        wb_m2s_spi_1_we;
    wire        wb_m2s_spi_1_cyc;
    wire        wb_m2s_spi_1_stb;
    wire  [2:0] wb_m2s_spi_1_cti;
    wire  [1:0] wb_m2s_spi_1_bte;
    wire [31:0] wb_s2m_spi_1_dat;
    wire        wb_s2m_spi_1_ack;
    wire        wb_s2m_spi_1_err;
    wire        wb_s2m_spi_1_rty;

    // SPI 2
    wire [31:0] wb_m2s_spi_2_adr;
    wire [31:0] wb_m2s_spi_2_dat;
    wire  [3:0] wb_m2s_spi_2_sel;
    wire        wb_m2s_spi_2_we;
    wire        wb_m2s_spi_2_cyc;
    wire        wb_m2s_spi_2_stb;
    wire  [2:0] wb_m2s_spi_2_cti;
    wire  [1:0] wb_m2s_spi_2_bte;
    wire [31:0] wb_s2m_spi_2_dat;
    wire        wb_s2m_spi_2_ack;
    wire        wb_s2m_spi_2_err;
    wire        wb_s2m_spi_2_rty;


    // UART
    wire [31:0] wb_m2s_uart_adr;
    wire [31:0] wb_m2s_uart_dat;
    wire  [3:0] wb_m2s_uart_sel;
    wire        wb_m2s_uart_we;
    wire        wb_m2s_uart_cyc;
    wire        wb_m2s_uart_stb;
    wire  [2:0] wb_m2s_uart_cti;
    wire  [1:0] wb_m2s_uart_bte;
    wire [31:0] wb_s2m_uart_dat;
    wire        wb_s2m_uart_ack;
    wire        wb_s2m_uart_err;
    wire        wb_s2m_uart_rty;
 
    // i2c
    wire [31:0] wb_m2s_i2c_adr;
    wire [31:0] wb_m2s_i2c_dat;
    wire  [3:0] wb_m2s_i2c_sel;
    wire        wb_m2s_i2c_we;
    wire        wb_m2s_i2c_cyc;
    wire        wb_m2s_i2c_stb;
    wire  [2:0] wb_m2s_i2c_cti;
    wire  [1:0] wb_m2s_i2c_bte;
    wire [31:0] wb_s2m_i2c_dat;
    wire        wb_s2m_i2c_ack;
    wire        wb_s2m_i2c_err;
    wire        wb_s2m_i2c_rty;





    // wishbone interconnect, // later we should use interfaces to reduces number of lines
    wb_intercon wb_intercon_inst
   (.wb_clk_i           (wb_clk),
    .wb_rst_i           (wb_rst),
    .wb_io_adr_i        (wb_m2s_adr),
    .wb_io_dat_i        (wb_m2s_dat),
    .wb_io_sel_i        (wb_m2s_sel),
    .wb_io_we_i         (wb_m2s_we),
    .wb_io_cyc_i        (wb_m2s_cyc),
    .wb_io_stb_i        (wb_m2s_stb),
    .wb_io_cti_i        (3'b0),     // these bits are not used in current soc
    .wb_io_bte_i        (2'b0),     // these bits are not used in current soc
    .wb_io_dat_o        (wb_s2m_dat),
    .wb_io_ack_o        (wb_s2m_ack),
    .wb_io_err_o        (wb_s2m_err),
    .wb_io_rty_o        (wb_s2m_rty),

    .wb_spi_1_adr_o (wb_m2s_spi_1_adr),
    .wb_spi_1_dat_o (wb_m2s_spi_1_dat),
    .wb_spi_1_sel_o (wb_m2s_spi_1_sel),
    .wb_spi_1_we_o  (wb_m2s_spi_1_we),
    .wb_spi_1_cyc_o (wb_m2s_spi_1_cyc),
    .wb_spi_1_stb_o (wb_m2s_spi_1_stb),
    .wb_spi_1_cti_o (wb_m2s_spi_1_cti),
    .wb_spi_1_bte_o (wb_m2s_spi_1_bte),
    .wb_spi_1_dat_i (wb_s2m_spi_1_dat),
    .wb_spi_1_ack_i (wb_s2m_spi_1_ack),
    .wb_spi_1_err_i (wb_s2m_spi_1_err),
    .wb_spi_1_rty_i (wb_s2m_spi_1_rty),

    .wb_spi_2_adr_o (wb_m2s_spi_2_adr),
    .wb_spi_2_dat_o (wb_m2s_spi_2_dat),
    .wb_spi_2_sel_o (wb_m2s_spi_2_sel),
    .wb_spi_2_we_o  (wb_m2s_spi_2_we),
    .wb_spi_2_cyc_o (wb_m2s_spi_2_cyc),
    .wb_spi_2_stb_o (wb_m2s_spi_2_stb),
    .wb_spi_2_cti_o (wb_m2s_spi_2_cti),
    .wb_spi_2_bte_o (wb_m2s_spi_2_bte),
    .wb_spi_2_dat_i (wb_s2m_spi_2_dat),
    .wb_spi_2_ack_i (wb_s2m_spi_2_ack),
    .wb_spi_2_err_i (wb_s2m_spi_2_err),
    .wb_spi_2_rty_i (wb_s2m_spi_2_rty),

    .wb_i2c_adr_o (wb_m2s_i2c_adr),
    .wb_i2c_dat_o (wb_m2s_i2c_dat),
    .wb_i2c_sel_o (wb_m2s_i2c_sel),
    .wb_i2c_we_o  (wb_m2s_i2c_we),
    .wb_i2c_cyc_o (wb_m2s_i2c_cyc),
    .wb_i2c_stb_o (wb_m2s_i2c_stb),
    .wb_i2c_cti_o (wb_m2s_i2c_cti),
    .wb_i2c_bte_o (wb_m2s_i2c_bte),
    .wb_i2c_dat_i (wb_s2m_i2c_dat),
    .wb_i2c_ack_i (wb_s2m_i2c_ack),
    .wb_i2c_err_i (wb_s2m_i2c_err),
    .wb_i2c_rty_i (wb_s2m_i2c_rty),

    .wb_uart_adr_o      (wb_m2s_uart_adr),
    .wb_uart_dat_o      (wb_m2s_uart_dat),
    .wb_uart_sel_o      (wb_m2s_uart_sel),
    .wb_uart_we_o       (wb_m2s_uart_we),
    .wb_uart_cyc_o      (wb_m2s_uart_cyc),
    .wb_uart_stb_o      (wb_m2s_uart_stb),
    .wb_uart_cti_o      (wb_m2s_uart_cti),
    .wb_uart_bte_o      (wb_m2s_uart_bte),
    .wb_uart_dat_i      (wb_s2m_uart_dat),
    .wb_uart_ack_i      (wb_s2m_uart_ack),
    .wb_uart_err_i      (wb_s2m_uart_err),
    .wb_uart_rty_i      (wb_s2m_uart_rty)
   );

    // ============================================
    //                      SPI 1
    // ============================================ 

     wire [7:0] 		       spi_1_rdt;
     assign wb_s2m_spi_1_dat = {24'd0,spi_1_rdt};
     simple_spi spi_1
       (// Wishbone slave interface
        .clk_i  (wb_clk),
        .rst_i  (wb_rst),
        .adr_i  (wb_m2s_spi_1_adr[2:0]),
        .dat_i  (wb_m2s_spi_1_dat[7:0]),
        .we_i   (wb_m2s_spi_1_we),
        .cyc_i  (wb_m2s_spi_1_cyc),
        .stb_i  (wb_m2s_spi_1_stb),
        .dat_o  (spi_1_rdt),
        .ack_o  (wb_s2m_spi_1_ack),
        .inta_o (),
        // SPI interface
        .sck_o  (o_spi_1_sclk),
        .ss_o   (o_spi_1_cs_n),
        .mosi_o (o_spi_1_mosi),
        .miso_i (i_spi_1_miso));
    
     assign wb_s2m_spi_1_err = 1'b0;
     assign wb_s2m_spi_1_rty = 1'b0;

    // ============================================
    //                      SPI 2
    // ============================================ 

     wire [7:0] 		       spi_2_rdt;
     assign wb_s2m_spi_2_dat = {24'd0,spi_2_rdt};
     simple_spi spi_2
       (// Wishbone slave interface
        .clk_i  (wb_clk),
        .rst_i  (wb_rst),
        .adr_i  (wb_m2s_spi_2_adr[2:0]),
        .dat_i  (wb_m2s_spi_2_dat[7:0]),
        .we_i   (wb_m2s_spi_2_we),
        .cyc_i  (wb_m2s_spi_2_cyc),
        .stb_i  (wb_m2s_spi_2_stb),
        .dat_o  (spi_2_rdt),
        .ack_o  (wb_s2m_spi_2_ack),
        .inta_o (),
        // SPI interface
        .sck_o  (o_spi_2_sclk),
        .ss_o   (o_spi_2_cs_n),
        .mosi_o (o_spi_2_mosi),
        .miso_i (i_spi_2_miso));
    
     assign wb_s2m_spi_2_err = 1'b0;
     assign wb_s2m_spi_2_rty = 1'b0;


    // ============================================
    //                      i2c
    // ============================================ 

wire [7:0] 		       i2c_rdt;
assign wb_s2m_i2c_dat = {24'd0, i2c_rdt};

logic scl_padoen_oe;
logic sda_padoen_oe;
logic scl_pad_o;
logic sda_pad_o;
logic scl_pad_i;
logic sda_pad_i; 

 assign scl = scl_padoen_oe ? 1'bz : scl_pad_o; 
 assign sda = sda_padoen_oe ? 1'bz: sda_pad_o; 
 assign scl_pad_i = scl; 
 assign sda_pad_i = sda;

pullup p1(scl); // pullup scl line
pullup p2(sda); // pullup sda line

 i2c_master_top i2c (
  // Wishbone interface
	.wb_clk_i(wb_clk),
  .wb_rst_i(1'b0),
  .arst_i(~wb_rst),
  .wb_adr_i(wb_m2s_i2c_adr[2:0]),
  .wb_dat_i(wb_m2s_i2c_dat[7:0]),
  .wb_dat_o(i2c_rdt),
	.wb_we_i(wb_m2s_i2c_we),
  .wb_stb_i(wb_m2s_i2c_stb),
  .wb_cyc_i(wb_m2s_i2c_cyc),
  .wb_ack_o(wb_s2m_i2c_ack),
  .wb_inta_o(),

  // I2c interface
	.scl_pad_i(scl),
  .scl_pad_o(scl_pad_o),
  .scl_padoen_o(scl_padoen_oe),
  .sda_pad_i(sda), 
  .sda_pad_o(sda_pad_o), 
  .sda_padoen_o(sda_padoen_oe)
  
   );

    // ============================================
    //                      UART
    // ============================================ 
    
      wire [7:0] 		       uart_rdt;
      assign wb_s2m_uart_dat = {24'd0, uart_rdt};
      assign wb_s2m_uart_err = 1'b0;
      assign wb_s2m_uart_rty = 1'b0;

      uart_top uart16550_0
        (// Wishbone slave interface

         .wb_clk_i	(wb_clk),
         .wb_rst_i	(wb_rst),
         .wb_adr_i	(wb_m2s_uart_adr[2:0]),
         .wb_dat_i	(wb_m2s_uart_dat[7:0]),
         .wb_we_i	(wb_m2s_uart_we),
         .wb_cyc_i	(wb_m2s_uart_cyc),
         .wb_stb_i	(wb_m2s_uart_stb),
         .wb_sel_i	(4'b0), // Not used in 8-bit mode
         .wb_dat_o	(uart_rdt),
         .wb_ack_o	(wb_s2m_uart_ack),

         // Outputs
         .int_o     (),
         .stx_pad_o (o_uart_tx),
         .rts_pad_o (),
         .dtr_pad_o (),

         // Inputs
         .srx_pad_i (i_uart_rx),
         .cts_pad_i (1'b0),
         .dsr_pad_i (1'b0),
         .ri_pad_i  (1'b0),
         .dcd_pad_i (1'b0));

endmodule 
