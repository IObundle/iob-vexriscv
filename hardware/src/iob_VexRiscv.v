/*
 *  IOb-VexRiscv -- A VexRiscv Wrapper
 */
`timescale 1 ns / 1 ps
`include "iob_vexriscv_conf.vh"
`include "iob_utils.vh"

module iob_VexRiscv #(
    parameter IBUS_AXI_ID_W   = 1,
    parameter IBUS_AXI_LEN_W  = 8,
    parameter IBUS_AXI_ADDR_W = 32,
    parameter IBUS_AXI_DATA_W = 32,
    parameter DBUS_AXI_ID_W   = 1,
    parameter DBUS_AXI_LEN_W  = 8,
    parameter DBUS_AXI_ADDR_W = 32,
    parameter DBUS_AXI_DATA_W = 32,
    `include "iob_vexriscv_params.vs"
) (
    input wire clk_i,
    input wire cke_i,
    input wire arst_i,
    input wire cpu_reset_i,

    // CLINT bus
    input  wire [ `REQ_W-1:0] clint_req,
    output wire [`RESP_W-1:0] clint_resp,

    // PLIC bus
    input  wire [ `REQ_W-1:0] plic_req,
    output wire [`RESP_W-1:0] plic_resp,
    input  wire [       31:0] plicInterrupts,

    // Axi instruction bus
    `include "iBus_axi_m_port.vs"
    // Axi data bus
    `include "dBus_axi_m_port.vs"

    input wire boot_i
);

  wire reset;

  wire                clint_iob_valid;
  wire [  ADDR_W-1:0] clint_iob_addr;
  wire [  DATA_W-1:0] clint_iob_wdata;
  wire [DATA_W/8-1:0] clint_iob_wstrb;
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

  wire                plic_iob_valid;
  wire [  ADDR_W-1:0] plic_iob_addr;
  wire [  DATA_W-1:0] plic_iob_wdata;
  wire [DATA_W/8-1:0] plic_iob_wstrb;
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

  wire [  DATA_W-1:0] iBus_axi_araddr_int;
  wire [         3:0] iBus_axi_arregion;
  wire                iBus_axi_arlock;
  reg  [  DATA_W-1:0] dBus_axi_awaddr;
  wire [  DATA_W-1:0] dBus_axi_awaddr_int;
  wire [         3:0] dBus_axi_awregion;
  wire                dBus_axi_awlock;
  reg  [  DATA_W-1:0] dBus_axi_araddr;
  wire [  DATA_W-1:0] dBus_axi_araddr_int;
  wire [         3:0] dBus_axi_arregion;
  wire                dBus_axi_arlock;
  wire                w_periphral_sel;
  wire                r_periphral_sel;

  assign reset = cpu_reset_i | arst_i;

  assign w_periphral_sel = &dBus_axi_awaddr_int[ADDR_W-1:ADDR_W-4];
  assign r_periphral_sel = &dBus_axi_araddr_int[ADDR_W-1:ADDR_W-4];

  assign iBus_axi_awvalid_o = 1'b0;
  assign iBus_axi_awaddr_o = {ADDR_W{1'b0}};
  assign iBus_axi_awid_o = 1'b0;
  assign iBus_axi_awlen_o = {IBUS_AXI_LEN_W{1'b0}};
  assign iBus_axi_awsize_o = {3{1'b0}};
  assign iBus_axi_awburst_o = {2{1'b0}};
  assign iBus_axi_awlock_o = 1'b0;
  assign iBus_axi_awcache_o = {4{1'b0}};
  assign iBus_axi_awqos_o = {4{1'b0}};
  assign iBus_axi_awprot_o = {3{1'b0}};
  assign iBus_axi_wvalid_o = 1'b0;
  assign iBus_axi_wdata_o = {DATA_W{1'b0}};
  assign iBus_axi_wstrb_o = {DATA_W / 8{1'b0}};
  assign iBus_axi_wlast_o = 1'b0;
  assign iBus_axi_bready_o = 1'b0;
  assign iBus_axi_araddr_o = {boot_i, iBus_axi_araddr_int[ADDR_W-2:0]};
  assign iBus_axi_arlock_o = {1'b0, iBus_axi_arlock};

  assign dBus_axi_awaddr_o = dBus_axi_awaddr;
  assign dBus_axi_araddr_o = dBus_axi_araddr;
  assign dBus_axi_awlock_o = {1'b0, dBus_axi_awlock};
  assign dBus_axi_arlock_o = {1'b0, dBus_axi_arlock};

  always @(*) begin
    if (w_periphral_sel) begin
      dBus_axi_awaddr = dBus_axi_awaddr_int;
    end else begin
      dBus_axi_awaddr = {
        boot_i & (~dBus_axi_awaddr_int[ADDR_W-1]), dBus_axi_awaddr_int[ADDR_W-2:0]
      };
    end
  end

  always @(*) begin
    if (r_periphral_sel) begin
      dBus_axi_araddr = dBus_axi_araddr_int;
    end else begin
      dBus_axi_araddr = {
        boot_i & (~dBus_axi_araddr_int[ADDR_W-1]), dBus_axi_araddr_int[ADDR_W-2:0]
      };
    end
  end

  assign {plic_iob_valid, plic_iob_addr, plic_iob_wdata, plic_iob_wstrb} = plic_req;
  assign plic_resp = {plic_iob_rdata, plic_iob_rvalid, plic_iob_ready};
  assign {clint_iob_valid, clint_iob_addr, clint_iob_wdata, clint_iob_wstrb} = clint_req;
  assign clint_resp = {clint_iob_rdata, clint_iob_rvalid, clint_iob_ready};
  // instantiate iob2axil clint
  iob2axil #(
      .AXIL_ADDR_W(16),
      .AXIL_DATA_W(32),
      .ADDR_W(ADDR_W),
      .DATA_W(DATA_W)
  ) clint_iob2axil (
      // IOb-bus slave signals
      .iob_valid_i(clint_iob_valid),
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
      .iob_valid_i(plic_iob_valid),
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
      .iBusAxi_arvalid(iBus_axi_arvalid_o),
      .iBusAxi_arready(iBus_axi_arready_i),
      .iBusAxi_araddr(iBus_axi_araddr_int),
      .iBusAxi_arid(iBus_axi_arid_o),
      .iBusAxi_arregion(iBus_axi_arregion),
      .iBusAxi_arlen(iBus_axi_arlen_o),
      .iBusAxi_arsize(iBus_axi_arsize_o),
      .iBusAxi_arburst(iBus_axi_arburst_o),
      .iBusAxi_arlock(iBus_axi_arlock),
      .iBusAxi_arcache(iBus_axi_arcache_o),
      .iBusAxi_arqos(iBus_axi_arqos_o),
      .iBusAxi_arprot(iBus_axi_arprot_o),
      .iBusAxi_rvalid(iBus_axi_rvalid_i),
      .iBusAxi_rready(iBus_axi_rready_o),
      .iBusAxi_rdata(iBus_axi_rdata_i),
      .iBusAxi_rid(iBus_axi_rid_i),
      .iBusAxi_rresp(iBus_axi_rresp_i),
      .iBusAxi_rlast(iBus_axi_rlast_i),
      .dBusAxi_awvalid(dBus_axi_awvalid_o),
      .dBusAxi_awready(dBus_axi_awready_i),
      .dBusAxi_awaddr(dBus_axi_awaddr_int),
      .dBusAxi_awid(dBus_axi_awid_o),
      .dBusAxi_awregion(dBus_axi_awregion),
      .dBusAxi_awlen(dBus_axi_awlen_o),
      .dBusAxi_awsize(dBus_axi_awsize_o),
      .dBusAxi_awburst(dBus_axi_awburst_o),
      .dBusAxi_awlock(dBus_axi_awlock),
      .dBusAxi_awcache(dBus_axi_awcache_o),
      .dBusAxi_awqos(dBus_axi_awqos_o),
      .dBusAxi_awprot(dBus_axi_awprot_o),
      .dBusAxi_wvalid(dBus_axi_wvalid_o),
      .dBusAxi_wready(dBus_axi_wready_i),
      .dBusAxi_wdata(dBus_axi_wdata_o),
      .dBusAxi_wstrb(dBus_axi_wstrb_o),
      .dBusAxi_wlast(dBus_axi_wlast_o),
      .dBusAxi_bvalid(dBus_axi_bvalid_i),
      .dBusAxi_bready(dBus_axi_bready_o),
      .dBusAxi_bid(dBus_axi_bid_i),
      .dBusAxi_bresp(dBus_axi_bresp_i),
      .dBusAxi_arvalid(dBus_axi_arvalid_o),
      .dBusAxi_arready(dBus_axi_arready_i),
      .dBusAxi_araddr(dBus_axi_araddr_int),
      .dBusAxi_arid(dBus_axi_arid_o),
      .dBusAxi_arregion(dBus_axi_arregion),
      .dBusAxi_arlen(dBus_axi_arlen_o),
      .dBusAxi_arsize(dBus_axi_arsize_o),
      .dBusAxi_arburst(dBus_axi_arburst_o),
      .dBusAxi_arlock(dBus_axi_arlock),
      .dBusAxi_arcache(dBus_axi_arcache_o),
      .dBusAxi_arqos(dBus_axi_arqos_o),
      .dBusAxi_arprot(dBus_axi_arprot_o),
      .dBusAxi_rvalid(dBus_axi_rvalid_i),
      .dBusAxi_rready(dBus_axi_rready_o),
      .dBusAxi_rdata(dBus_axi_rdata_i),
      .dBusAxi_rid(dBus_axi_rid_i),
      .dBusAxi_rresp(dBus_axi_rresp_i),
      .dBusAxi_rlast(dBus_axi_rlast_i),
      .clk(clk_i),
      .reset(reset)
  );


endmodule
