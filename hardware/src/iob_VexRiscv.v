/*
 *  IOb-VexRiscv -- A VexRiscv Wrapper
 */
`timescale 1 ns / 1 ps
`include "iob_vexriscv_conf.vh"
`include "iob_utils.vh"

module iob_VexRiscv #(
    `include "iob_vexriscv_params.vs"
) (
    input wire clk_i,
    input wire cke_i,
    input wire arst_i,
    input wire cpu_reset_i,
    input wire boot_i,

    // CLINT bus
    input  wire [ `REQ_W-1:0] clint_req,
    output wire [`RESP_W-1:0] clint_resp,

    // PLIC bus
    input  wire [ `REQ_W-1:0] plic_req,
    output wire [`RESP_W-1:0] plic_resp,
    input  wire [       31:0] plicInterrupts,

    // instruction bus
    output wire [ `REQ_W-1:0] ibus_req,
    input  wire [`RESP_W-1:0] ibus_resp,

    // data bus
    output [ `REQ_W-1:0] dbus_req,
    input  [`RESP_W-1:0] dbus_resp
);

  wire                clint_iob_avalid;
  wire [  ADDR_W-1:0] clint_iob_addr;
  wire [  DATA_W-1:0] clint_iob_wdata;
  wire [DATA_W/8-1:0] clint_iob_wsrtb;
  wire                clint_iob_rvalid;
  wire [  DATA_W-1:0] clint_iob_rdata;
  wire                clint_iob_ready;

  wire                clint_awvalid;
  wire                clint_awready;
  wire [        15:0] clint_awaddr;
  wire [         2:0] clint_awprot;
  wire                clint_wvalid;
  wire                clint_wready;
  wire [        31:0] clint_wdata;
  wire [         3:0] clint_wstrb;
  wire                clint_bvalid;
  wire                clint_bready;
  wire [         1:0] clint_bresp;
  wire                clint_arvalid;
  wire                clint_arready;
  wire [        15:0] clint_araddr;
  wire [         2:0] clint_arprot;
  wire                clint_rvalid;
  wire                clint_rready;
  wire [        31:0] clint_rdata;
  wire [         1:0] clint_rresp;

  wire                plic_iob_avalid;
  wire [  ADDR_W-1:0] plic_iob_addr;
  wire [  DATA_W-1:0] plic_iob_wdata;
  wire [DATA_W/8-1:0] plic_iob_wsrtb;
  wire                plic_iob_rvalid;
  wire [  DATA_W-1:0] plic_iob_rdata;
  wire                plic_iob_ready;

  wire                plic_awvalid;
  wire                plic_awready;
  wire [        21:0] plic_awaddr;
  wire [         2:0] plic_awprot;
  wire                plic_wvalid;
  wire                plic_wready;
  wire [        31:0] plic_wdata;
  wire [         3:0] plic_wstrb;
  wire                plic_bvalid;
  wire                plic_bready;
  wire [         1:0] plic_bresp;
  wire                plic_arvalid;
  wire                plic_arready;
  wire [        21:0] plic_araddr;
  wire [         2:0] plic_arprot;
  wire                plic_rvalid;
  wire                plic_rready;
  wire [        31:0] plic_rdata;
  wire [         1:0] plic_rresp;

  wire                iBus_iob_avalid;
  wire [  ADDR_W-1:0] iBus_iob_addr;
  wire [  DATA_W-1:0] iBus_iob_wdata;
  wire [DATA_W/8-1:0] iBus_iob_wsrtb;
  wire                iBus_iob_rvalid;
  wire [  DATA_W-1:0] iBus_iob_rdata;
  wire                iBus_iob_ready;

  wire                iBusAxi_arvalid;
  wire                iBusAxi_arready;
  wire [        31:0] iBusAxi_araddr;
  wire [         0:0] iBusAxi_arid;
  wire [         3:0] iBusAxi_arregion;  // Not used on axi2iob
  wire [         7:0] iBusAxi_arlen;
  wire [         2:0] iBusAxi_arsize;
  wire [         1:0] iBusAxi_arburst;
  wire [         0:0] iBusAxi_arlock;
  wire [         3:0] iBusAxi_arcache;
  wire [         3:0] iBusAxi_arqos;  // Not used on axi2iob
  wire [         2:0] iBusAxi_arprot;
  wire                iBusAxi_rvalid;
  wire                iBusAxi_rready;
  wire [        31:0] iBusAxi_rdata;
  wire [         0:0] iBusAxi_rid;
  wire [         1:0] iBusAxi_rresp;
  wire                iBusAxi_rlast;

  wire                dBus_iob_avalid;
  wire [  ADDR_W-1:0] dBus_iob_addr;
  wire [  DATA_W-1:0] dBus_iob_wdata;
  wire [DATA_W/8-1:0] dBus_iob_wsrtb;
  wire                dBus_iob_rvalid;
  wire [  DATA_W-1:0] dBus_iob_rdata;
  wire                dBus_iob_ready;

  wire                dBusAxi_awvalid;
  wire                dBusAxi_awready;
  wire [        31:0] dBusAxi_awaddr;
  wire [         0:0] dBusAxi_awid;
  wire [         3:0] dBusAxi_awregion;  // Not used on axi2iob
  wire [         7:0] dBusAxi_awlen;
  wire [         2:0] dBusAxi_awsize;
  wire [         1:0] dBusAxi_awburst;
  wire [         0:0] dBusAxi_awlock;
  wire [         3:0] dBusAxi_awcache;
  wire [         3:0] dBusAxi_awqos;  // Not used on axi2iob
  wire [         2:0] dBusAxi_awprot;
  wire                dBusAxi_wvalid;
  wire                dBusAxi_wready;
  wire [        31:0] dBusAxi_wdata;
  wire [         3:0] dBusAxi_wstrb;
  wire                dBusAxi_wlast;
  wire                dBusAxi_bvalid;
  wire                dBusAxi_bready;
  wire [         0:0] dBusAxi_bid;
  wire [         1:0] dBusAxi_bresp;
  wire                dBusAxi_arvalid;
  wire                dBusAxi_arready;
  wire [        31:0] dBusAxi_araddr;
  wire [         0:0] dBusAxi_arid;
  wire [         3:0] dBusAxi_arregion;  // Not used on axi2iob
  wire [         7:0] dBusAxi_arlen;
  wire [         2:0] dBusAxi_arsize;
  wire [         1:0] dBusAxi_arburst;
  wire [         0:0] dBusAxi_arlock;
  wire [         3:0] dBusAxi_arcache;
  wire [         3:0] dBusAxi_arqos;  // Not used on axi2iob
  wire [         2:0] dBusAxi_arprot;
  wire                dBusAxi_rvalid;
  wire                dBusAxi_rready;
  wire [        31:0] dBusAxi_rdata;
  wire [         0:0] dBusAxi_rid;
  wire [         1:0] dBusAxi_rresp;
  wire                dBusAxi_rlast;
  wire                periphral_sel;

  wire                jtag_tms;
  wire                jtag_tdi;
  wire                jtag_tdo;
  wire                jtag_tck;
  wire                debugReset;
  wire                debug_resetOut;

  assign jtag_tms = 1'b0;
  assign jtag_tdi = 1'b0;
  assign jtag_tck = 1'b0;
  assign debugReset = 1'b0;

  assign ibus_req = {
    iBus_iob_avalid, ~boot_i, iBus_iob_addr[ADDR_W-2:0], iBus_iob_wdata, iBus_iob_wsrtb
  };
  assign {iBus_iob_rdata, iBus_iob_rvalid, iBus_iob_ready} = ibus_resp;

  assign periphral_sel = (~dBus_iob_addr[ADDR_W-1]) & (|dBus_iob_addr[ADDR_W-2:ADDR_W-5]);
  assign dbus_req = {
    dBus_iob_avalid,
    (~boot_i) & (~periphral_sel),
    dBus_iob_addr[ADDR_W-2:0],
    dBus_iob_wdata,
    dBus_iob_wsrtb
  };
  assign {dBus_iob_rdata, dBus_iob_rvalid, dBus_iob_ready} = dbus_resp;

  assign plic_req = {plic_iob_avalid, plic_iob_addr, plic_iob_wdata, plic_iob_wsrtb};
  assign {plic_iob_rdata, plic_iob_rvalid, plic_iob_ready} = plic_resp;
  assign clint_req = {clint_iob_avalid, clint_iob_addr, clint_iob_wdata, clint_iob_wsrtb};
  assign {clint_iob_rdata, clint_iob_rvalid, clint_iob_ready} = clint_resp;
  // instantiate iob2axil clint
  iob2axil #(
      .AXIL_ADDR_W(16),
      .AXIL_DATA_W(32),
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W)
  ) clint_iob2axil (
      // IOb-bus slave signals
      .iob_avalid_i(clint_iob_avalid),
      .iob_addr_i(clint_iob_addr),
      .iob_wdata_i(clint_iob_wdata),
      .iob_wstrb_i(clint_iob_wstrb),
      .iob_rvalid_o(clint_iob_rvalid),
      .iob_rdata_o(clint_iob_rdata),
      .iob_ready_o(clint_iob_ready),
      // AXIL master signals
      .axil_awvalid_o(clint_awvalid),
      .axil_awready_i(clint_awready),
      .axil_awaddr_o(clint_awaddr),
      .axil_awprot_o(clint_awprot),
      .axil_wvalid_o(clint_wvalid),
      .axil_wready_i(clint_wready),
      .axil_wdata_o(clint_wdata),
      .axil_wstrb_o(clint_wstrb),
      .axil_bvalid_i(clint_bvalid),
      .axil_bready_o(clint_bready),
      .axil_bresp_i(clint_bresp),
      .axil_arvalid_o(clint_arvalid),
      .axil_arready_i(clint_arready),
      .axil_araddr_o(clint_araddr),
      .axil_arprot_o(clint_arprot),
      .axil_rvalid_i(clint_rvalid),
      .axil_rready_o(clint_rready),
      .axil_rdata_i(clint_rdata),
      .axil_rresp_i(clint_rresp)
  );
  // instantiate iob2axil plic
  iob2axil #(
      .AXIL_ADDR_W(22),
      .AXIL_DATA_W(32),
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W)
  ) plic_iob2axil (
      // IOb-bus slave signals
      .iob_avalid_i(plic_iob_avalid),
      .iob_addr_i(plic_iob_addr),
      .iob_wdata_i(plic_iob_wdata),
      .iob_wstrb_i(plic_iob_wstrb),
      .iob_rvalid_o(plic_iob_rvalid),
      .iob_rdata_o(plic_iob_rdata),
      .iob_ready_o(plic_iob_ready),
      // AXIL master signals
      .axil_awvalid_o(plic_awvalid),
      .axil_awready_i(plic_awready),
      .axil_awaddr_o(plic_awaddr),
      .axil_awprot_o(plic_awprot),
      .axil_wvalid_o(plic_wvalid),
      .axil_wready_i(plic_wready),
      .axil_wdata_o(plic_wdata),
      .axil_wstrb_o(plic_wstrb),
      .axil_bvalid_i(plic_bvalid),
      .axil_bready_o(plic_bready),
      .axil_bresp_i(plic_bresp),
      .axil_arvalid_o(plic_arvalid),
      .axil_arready_i(plic_arready),
      .axil_araddr_o(plic_araddr),
      .axil_arprot_o(plic_arprot),
      .axil_rvalid_i(plic_rvalid),
      .axil_rready_o(plic_rready),
      .axil_rdata_i(plic_rdata),
      .axil_rresp_i(plic_rresp)
  );

  // instantiate axi2iob CPU instructions
  axi2iob #(
      .ADDR_WIDTH(ADDR_W),
      .AXI_DATA_WIDTH(DATA_W),
      .AXI_STRB_WIDTH((DATA_W / 8)),
      .AXI_ID_WIDTH(1),
      .IOB_DATA_WIDTH(DATA_W),
      .IOB_STRB_WIDTH((DATA_W / 8)),
      .CONVERT_BURST(1),
      .CONVERT_NARROW_BURST(0)
  ) iBus_axi2iob (
      .clk(clk_i),
      .rst(arst_i),
      .s_axi_awid(1'b0),
      .s_axi_awaddr(32'h00000000),
      .s_axi_awlen(8'h00),
      .s_axi_awsize(3'b000),
      .s_axi_awburst(2'b00),
      .s_axi_awlock(1'b0),
      .s_axi_awcache(4'h0),
      .s_axi_awprot(3'b000),
      .s_axi_awvalid(1'b0),
      .s_axi_awready(),
      .s_axi_wdata(32'h00000000),
      .s_axi_wstrb(4'h0),
      .s_axi_wlast(1'b0),
      .s_axi_wvalid(1'b0),
      .s_axi_wready(),
      .s_axi_bid(),
      .s_axi_bresp(),
      .s_axi_bvalid(),
      .s_axi_bready(1'b0),
      .s_axi_arid(iBusAxi_arid),
      .s_axi_araddr(iBusAxi_araddr),
      .s_axi_arlen(iBusAxi_arlen),
      .s_axi_arsize(iBusAxi_arsize),
      .s_axi_arburst(iBusAxi_arburst),
      .s_axi_arlock(iBusAxi_arlock),
      .s_axi_arcache(iBusAxi_arcache),
      .s_axi_arprot(iBusAxi_arprot),
      .s_axi_arvalid(iBusAxi_arvalid),
      .s_axi_arready(iBusAxi_arready),
      .s_axi_rid(iBusAxi_rid),
      .s_axi_rdata(iBusAxi_rdata),
      .s_axi_rresp(iBusAxi_rresp),
      .s_axi_rlast(iBusAxi_rlast),
      .s_axi_rvalid(iBusAxi_rvalid),
      .s_axi_rready(iBusAxi_rready),
      // IOb-bus signals
      .iob_avalid_o(iBus_iob_avalid),
      .iob_addr_o(iBus_iob_addr),
      .iob_wdata_o(iBus_iob_wdata),
      .iob_wstrb_o(iBus_iob_wsrtb),
      .iob_rvalid_i(iBus_iob_rvalid),
      .iob_rdata_i(iBus_iob_rdata),
      .iob_ready_i(iBus_iob_ready)
  );

  // instantiate axi2iob CPU data
  axi2iob #(
      .ADDR_WIDTH(ADDR_W),
      .AXI_DATA_WIDTH(DATA_W),
      .AXI_STRB_WIDTH((DATA_W / 8)),
      .AXI_ID_WIDTH(1),
      .IOB_DATA_WIDTH(DATA_W),
      .IOB_STRB_WIDTH((DATA_W / 8)),
      .CONVERT_BURST(1),
      .CONVERT_NARROW_BURST(0)
  ) dBus_axi2iob (
      .clk(clk_i),
      .rst(arst_i),
      .s_axi_awid(dBusAxi_awid),
      .s_axi_awaddr(dBusAxi_awaddr),
      .s_axi_awlen(dBusAxi_awlen),
      .s_axi_awsize(dBusAxi_awsize),
      .s_axi_awburst(dBusAxi_awburst),
      .s_axi_awlock(dBusAxi_awlock),
      .s_axi_awcache(dBusAxi_awcache),
      .s_axi_awprot(dBusAxi_awprot),
      .s_axi_awvalid(dBusAxi_awvalid),
      .s_axi_awready(dBusAxi_awready),
      .s_axi_wdata(dBusAxi_wdata),
      .s_axi_wstrb(dBusAxi_wstrb),
      .s_axi_wlast(dBusAxi_wlast),
      .s_axi_wvalid(dBusAxi_wvalid),
      .s_axi_wready(dBusAxi_wready),
      .s_axi_bid(dBusAxi_bid),
      .s_axi_bresp(dBusAxi_bresp),
      .s_axi_bvalid(dBusAxi_bvalid),
      .s_axi_bready(dBusAxi_bready),
      .s_axi_arid(dBusAxi_arid),
      .s_axi_araddr(dBusAxi_araddr),
      .s_axi_arlen(dBusAxi_arlen),
      .s_axi_arsize(dBusAxi_arsize),
      .s_axi_arburst(dBusAxi_arburst),
      .s_axi_arlock(dBusAxi_arlock),
      .s_axi_arcache(dBusAxi_arcache),
      .s_axi_arprot(dBusAxi_arprot),
      .s_axi_arvalid(dBusAxi_arvalid),
      .s_axi_arready(dBusAxi_arready),
      .s_axi_rid(dBusAxi_rid),
      .s_axi_rdata(dBusAxi_rdata),
      .s_axi_rresp(dBusAxi_rresp),
      .s_axi_rlast(dBusAxi_rlast),
      .s_axi_rvalid(dBusAxi_rvalid),
      .s_axi_rready(dBusAxi_rready),
      // IOb-bus signals
      .iob_avalid_o(dBus_iob_avalid),
      .iob_addr_o(dBus_iob_addr),
      .iob_wdata_o(dBus_iob_wdata),
      .iob_wstrb_o(dBus_iob_wsrtb),
      .iob_rvalid_i(dBus_iob_rvalid),
      .iob_rdata_i(dBus_iob_rdata),
      .iob_ready_i(dBus_iob_ready)
  );


  // Instantiation of VexRiscvAxi4LinuxPlicClint
  VexRiscvAxi4LinuxPlicClint CPU (
      .clint_awvalid(clint_awvalid),
      .clint_awready(clint_awready),
      .clint_awaddr(clint_awaddr),
      .clint_awprot(clint_awprot),
      .clint_wvalid(clint_wvalid),
      .clint_wready(clint_wready),
      .clint_wdata(clint_wdata),
      .clint_wstrb(clint_wstrb),
      .clint_bvalid(clint_bvalid),
      .clint_bready(clint_bready),
      .clint_bresp(clint_bresp),
      .clint_arvalid(clint_arvalid),
      .clint_arready(clint_arready),
      .clint_araddr(clint_araddr),
      .clint_arprot(clint_arprot),
      .clint_rvalid(clint_rvalid),
      .clint_rready(clint_rready),
      .clint_rdata(clint_rdata),
      .clint_rresp(clint_rresp),
      .plic_awvalid(plic_awvalid),
      .plic_awready(plic_awready),
      .plic_awaddr(plic_awaddr),
      .plic_awprot(plic_awprot),
      .plic_wvalid(plic_wvalid),
      .plic_wready(plic_wready),
      .plic_wdata(plic_wdata),
      .plic_wstrb(plic_wstrb),
      .plic_bvalid(plic_bvalid),
      .plic_bready(plic_bready),
      .plic_bresp(plic_bresp),
      .plic_arvalid(plic_arvalid),
      .plic_arready(plic_arready),
      .plic_araddr(plic_araddr),
      .plic_arprot(plic_arprot),
      .plic_rvalid(plic_rvalid),
      .plic_rready(plic_rready),
      .plic_rdata(plic_rdata),
      .plic_rresp(plic_rresp),
      .plicInterrupts(plicInterrupts),
      .debug_resetOut(debug_resetOut),
      .iBusAxi_arvalid(iBusAxi_arvalid),
      .iBusAxi_arready(iBusAxi_arready),
      .iBusAxi_araddr(iBusAxi_araddr),
      .iBusAxi_arid(iBusAxi_arid),
      .iBusAxi_arregion(iBusAxi_arregion),
      .iBusAxi_arlen(iBusAxi_arlen),
      .iBusAxi_arsize(iBusAxi_arsize),
      .iBusAxi_arburst(iBusAxi_arburst),
      .iBusAxi_arlock(iBusAxi_arlock),
      .iBusAxi_arcache(iBusAxi_arcache),
      .iBusAxi_arqos(iBusAxi_arqos),
      .iBusAxi_arprot(iBusAxi_arprot),
      .iBusAxi_rvalid(iBusAxi_rvalid),
      .iBusAxi_rready(iBusAxi_rready),
      .iBusAxi_rdata(iBusAxi_rdata),
      .iBusAxi_rid(iBusAxi_rid),
      .iBusAxi_rresp(iBusAxi_rresp),
      .iBusAxi_rlast(iBusAxi_rlast),
      .dBusAxi_awvalid(dBusAxi_awvalid),
      .dBusAxi_awready(dBusAxi_awready),
      .dBusAxi_awaddr(dBusAxi_awaddr),
      .dBusAxi_awid(dBusAxi_awid),
      .dBusAxi_awregion(dBusAxi_awregion),
      .dBusAxi_awlen(dBusAxi_awlen),
      .dBusAxi_awsize(dBusAxi_awsize),
      .dBusAxi_awburst(dBusAxi_awburst),
      .dBusAxi_awlock(dBusAxi_awlock),
      .dBusAxi_awcache(dBusAxi_awcache),
      .dBusAxi_awqos(dBusAxi_awqos),
      .dBusAxi_awprot(dBusAxi_awprot),
      .dBusAxi_wvalid(dBusAxi_wvalid),
      .dBusAxi_wready(dBusAxi_wready),
      .dBusAxi_wdata(dBusAxi_wdata),
      .dBusAxi_wstrb(dBusAxi_wstrb),
      .dBusAxi_wlast(dBusAxi_wlast),
      .dBusAxi_bvalid(dBusAxi_bvalid),
      .dBusAxi_bready(dBusAxi_bready),
      .dBusAxi_bid(dBusAxi_bid),
      .dBusAxi_bresp(dBusAxi_bresp),
      .dBusAxi_arvalid(dBusAxi_arvalid),
      .dBusAxi_arready(dBusAxi_arready),
      .dBusAxi_araddr(dBusAxi_araddr),
      .dBusAxi_arid(dBusAxi_arid),
      .dBusAxi_arregion(dBusAxi_arregion),
      .dBusAxi_arlen(dBusAxi_arlen),
      .dBusAxi_arsize(dBusAxi_arsize),
      .dBusAxi_arburst(dBusAxi_arburst),
      .dBusAxi_arlock(dBusAxi_arlock),
      .dBusAxi_arcache(dBusAxi_arcache),
      .dBusAxi_arqos(dBusAxi_arqos),
      .dBusAxi_arprot(dBusAxi_arprot),
      .dBusAxi_rvalid(dBusAxi_rvalid),
      .dBusAxi_rready(dBusAxi_rready),
      .dBusAxi_rdata(dBusAxi_rdata),
      .dBusAxi_rid(dBusAxi_rid),
      .dBusAxi_rresp(dBusAxi_rresp),
      .dBusAxi_rlast(dBusAxi_rlast),
      .jtag_tms(jtag_tms),
      .jtag_tdi(jtag_tdi),
      .jtag_tdo(jtag_tdo),
      .jtag_tck(jtag_tck),
      .clk(clk_i),
      .reset(arst_i | cpu_reset_i),
      .debugReset(debugReset)
  );


endmodule
