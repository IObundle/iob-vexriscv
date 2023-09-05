/*

Copyright (c) 2019 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4 to AXI4-Lite adapter
 */
module axi2iob #(
    // Width of address bus in bits
    parameter ADDR_WIDTH           = 32,
    // Width of input (slave) AXI interface data bus in bits
    parameter AXI_DATA_WIDTH       = 32,
    // Width of input (slave) AXI interface wstrb (width of data bus in words)
    parameter AXI_STRB_WIDTH       = (AXI_DATA_WIDTH / 8),
    // Width of AXI ID signal
    parameter AXI_ID_WIDTH         = 8,
    // Width of output (master) AXI lite interface data bus in bits
    parameter IOB_DATA_WIDTH       = 32,
    // Width of output (master) AXI lite interface wstrb (width of data bus in words)
    parameter IOB_STRB_WIDTH       = (IOB_DATA_WIDTH / 8),
    // When adapting to a wider bus, re-pack full-width burst instead of passing through narrow burst if possible
    parameter CONVERT_BURST        = 1,
    // When adapting to a wider bus, re-pack all bursts instead of passing through narrow burst if possible
    parameter CONVERT_NARROW_BURST = 0
) (
    input wire clk,
    input wire rst,

    /*
     * AXI slave interface
     */
    input  wire [  AXI_ID_WIDTH-1:0] s_axi_awid,
    input  wire [    ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [               7:0] s_axi_awlen,
    input  wire [               2:0] s_axi_awsize,
    input  wire [               1:0] s_axi_awburst,
    input  wire                      s_axi_awlock,
    input  wire [               3:0] s_axi_awcache,
    input  wire [               2:0] s_axi_awprot,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,
    input  wire [AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [AXI_STRB_WIDTH-1:0] s_axi_wstrb,
    input  wire                      s_axi_wlast,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,
    output wire [  AXI_ID_WIDTH-1:0] s_axi_bid,
    output wire [               1:0] s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,
    input  wire [  AXI_ID_WIDTH-1:0] s_axi_arid,
    input  wire [    ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [               7:0] s_axi_arlen,
    input  wire [               2:0] s_axi_arsize,
    input  wire [               1:0] s_axi_arburst,
    input  wire                      s_axi_arlock,
    input  wire [               3:0] s_axi_arcache,
    input  wire [               2:0] s_axi_arprot,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,
    output wire [  AXI_ID_WIDTH-1:0] s_axi_rid,
    output wire [AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output wire [               1:0] s_axi_rresp,
    output wire                      s_axi_rlast,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,

    /*
     * IOb-bus master interface
     */
    output wire                      iob_avalid_o,
    output wire [    ADDR_WIDTH-1:0] iob_addr_o,
    output wire [IOB_DATA_WIDTH-1:0] iob_wdata_o,
    output wire [IOB_STRB_WIDTH-1:0] iob_wstrb_o,
    input  wire                      iob_rvalid_i,
    input  wire [IOB_DATA_WIDTH-1:0] iob_rdata_i,
    input  wire                      iob_ready_i
);

  wire [    ADDR_WIDTH-1:0] m_axil_awaddr;
  wire [               2:0] m_axil_awprot;
  wire                      m_axil_awvalid;
  wire                      m_axil_awready;
  wire [IOB_DATA_WIDTH-1:0] m_axil_wdata;
  wire [IOB_STRB_WIDTH-1:0] m_axil_wstrb;
  wire                      m_axil_wvalid;
  wire                      m_axil_wready;
  wire [               1:0] m_axil_bresp;
  wire                      m_axil_bvalid;
  wire                      m_axil_bready;
  wire [    ADDR_WIDTH-1:0] m_axil_araddr;
  wire [               2:0] m_axil_arprot;
  wire                      m_axil_arvalid;
  wire                      m_axil_arready;
  wire [IOB_DATA_WIDTH-1:0] m_axil_rdata;
  wire [               1:0] m_axil_rresp;
  wire                      m_axil_rvalid;
  wire                      m_axil_rready;


  wire iob_rvalid_q;
  wire iob_rvalid_e;
  wire write_enable;
  wire m_axil_bvalid_n;
  wire m_axil_bvalid_e;
  wire m_axil_bvalid_q;

  assign write_enable = |m_axil_wstrb;
  assign m_axil_bvalid_n = m_axil_wvalid;
  assign m_axil_bvalid_e = m_axil_bvalid_n|m_axil_bready;
  assign m_axil_bvalid = m_axil_bvalid_q & m_axil_bready;
  assign iob_rvalid_e = iob_rvalid_i|m_axil_rready;
  //
  // COMPUTE AXIL OUTPUTS
  //
  // write address
  assign m_axil_awready = iob_ready_i;
  // write
  assign m_axil_wready  = iob_ready_i;
  // write response
  assign m_axil_bresp   = 2'b0;
  // read address
  assign m_axil_arready = iob_ready_i;
  // read
  assign m_axil_rdata   = iob_rdata_i;
  assign m_axil_rresp   = 2'b0;
  assign m_axil_rvalid  = iob_rvalid_i ? 1'b1 : iob_rvalid_q;

  //
  // COMPUTE IOb OUTPUTS
  //
  assign iob_avalid_o   = (m_axil_bvalid_n & write_enable) | m_axil_arvalid;
  assign iob_addr_o     = m_axil_awvalid ? m_axil_awaddr : m_axil_araddr;
  assign iob_wdata_o    = m_axil_wdata;
  assign iob_wstrb_o    = m_axil_wstrb;

  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_rvalid (
      .clk_i (clk),
      .arst_i(rst),
      .cke_i (1'b1),
      .rst_i (1'b0),
      .en_i  (iob_rvalid_e),
      .data_i(iob_rvalid_i),
      .data_o(iob_rvalid_q)
  );

  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_bvalid (
      .clk_i (clk),
      .arst_i(rst),
      .cke_i (1'b1),
      .rst_i (1'b0),
      .en_i  (m_axil_bvalid_e),
      .data_i(m_axil_bvalid_n),
      .data_o(m_axil_bvalid_q)
  );

  axi_axil_adapter_wr #(
      .ADDR_WIDTH          (ADDR_WIDTH),
      .AXI_DATA_WIDTH      (AXI_DATA_WIDTH),
      .AXI_STRB_WIDTH      (AXI_STRB_WIDTH),
      .AXI_ID_WIDTH        (AXI_ID_WIDTH),
      .AXIL_DATA_WIDTH     (IOB_DATA_WIDTH),
      .AXIL_STRB_WIDTH     (IOB_STRB_WIDTH),
      .CONVERT_BURST       (CONVERT_BURST),
      .CONVERT_NARROW_BURST(CONVERT_NARROW_BURST)
  ) axi_axil_adapter_wr_inst (
      .clk(clk),
      .rst(rst),

      /*
     * AXI slave interface
     */
      .s_axi_awid   (s_axi_awid),
      .s_axi_awaddr (s_axi_awaddr),
      .s_axi_awlen  (s_axi_awlen),
      .s_axi_awsize (s_axi_awsize),
      .s_axi_awburst(s_axi_awburst),
      .s_axi_awlock (s_axi_awlock),
      .s_axi_awcache(s_axi_awcache),
      .s_axi_awprot (s_axi_awprot),
      .s_axi_awvalid(s_axi_awvalid),
      .s_axi_awready(s_axi_awready),
      .s_axi_wdata  (s_axi_wdata),
      .s_axi_wstrb  (s_axi_wstrb),
      .s_axi_wlast  (s_axi_wlast),
      .s_axi_wvalid (s_axi_wvalid),
      .s_axi_wready (s_axi_wready),
      .s_axi_bid    (s_axi_bid),
      .s_axi_bresp  (s_axi_bresp),
      .s_axi_bvalid (s_axi_bvalid),
      .s_axi_bready (s_axi_bready),

      /*
     * AXI lite master interface
     */
      .m_axil_awaddr (m_axil_awaddr),
      .m_axil_awprot (m_axil_awprot),
      .m_axil_awvalid(m_axil_awvalid),
      .m_axil_awready(m_axil_awready),
      .m_axil_wdata  (m_axil_wdata),
      .m_axil_wstrb  (m_axil_wstrb),
      .m_axil_wvalid (m_axil_wvalid),
      .m_axil_wready (m_axil_wready),
      .m_axil_bresp  (m_axil_bresp),
      .m_axil_bvalid (m_axil_bvalid),
      .m_axil_bready (m_axil_bready)
  );

  axi_axil_adapter_rd #(
      .ADDR_WIDTH          (ADDR_WIDTH),
      .AXI_DATA_WIDTH      (AXI_DATA_WIDTH),
      .AXI_STRB_WIDTH      (AXI_STRB_WIDTH),
      .AXI_ID_WIDTH        (AXI_ID_WIDTH),
      .AXIL_DATA_WIDTH     (IOB_DATA_WIDTH),
      .AXIL_STRB_WIDTH     (IOB_STRB_WIDTH),
      .CONVERT_BURST       (CONVERT_BURST),
      .CONVERT_NARROW_BURST(CONVERT_NARROW_BURST)
  ) axi_axil_adapter_rd_inst (
      .clk(clk),
      .rst(rst),

      /*
     * AXI slave interface
     */
      .s_axi_arid   (s_axi_arid),
      .s_axi_araddr (s_axi_araddr),
      .s_axi_arlen  (s_axi_arlen),
      .s_axi_arsize (s_axi_arsize),
      .s_axi_arburst(s_axi_arburst),
      .s_axi_arlock (s_axi_arlock),
      .s_axi_arcache(s_axi_arcache),
      .s_axi_arprot (s_axi_arprot),
      .s_axi_arvalid(s_axi_arvalid),
      .s_axi_arready(s_axi_arready),
      .s_axi_rid    (s_axi_rid),
      .s_axi_rdata  (s_axi_rdata),
      .s_axi_rresp  (s_axi_rresp),
      .s_axi_rlast  (s_axi_rlast),
      .s_axi_rvalid (s_axi_rvalid),
      .s_axi_rready (s_axi_rready),

      /*
     * AXI lite master interface
     */
      .m_axil_araddr (m_axil_araddr),
      .m_axil_arprot (m_axil_arprot),
      .m_axil_arvalid(m_axil_arvalid),
      .m_axil_arready(m_axil_arready),
      .m_axil_rdata  (m_axil_rdata),
      .m_axil_rresp  (m_axil_rresp),
      .m_axil_rvalid (m_axil_rvalid),
      .m_axil_rready (m_axil_rready)
  );

endmodule
