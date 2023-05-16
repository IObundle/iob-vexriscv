/*
 *  IOb-VexRiscv -- A VexRiscv Wrapper
 */
`timescale 1 ns / 1 ps
`include "iob_vexriscv_conf.vh"
`include "iob_lib.vh"

module iob_VexRiscv #(
    `include "iob_vexriscv_params.vh"
) (
    input wire clk_i,
    input wire cke_i,
    input wire arst_i,
    input wire boot_i,

    // instruction bus
    output wire [ `REQ_W-1:0] ibus_req,
    input  wire [`RESP_W-1:0] ibus_resp,

    // data bus
    output [ `REQ_W-1:0] dbus_req,
    input  [`RESP_W-1:0] dbus_resp,

    input wire       timerInterrupt,     // Machine level timer interrupts
    input wire       softwareInterrupt,  // Machine level software interrupts
    input wire [1:0] externalInterrupts  // Both Machine and Supervisor level external interrupts
);

  // Wires
  // // INSTRUCTIONS BUS
  wire                ibus_avalid;
  wire                ibus_avalid_int;
  wire                ibus_ready;
  wire [  ADDR_W-1:0] ibus_addr;
  wire [  ADDR_W-1:0] ibus_addr_int;
  wire [         1:0] ibus_size;
  wire                ibus_ack;
  wire [  DATA_W-1:0] ibus_resp_data;
  wire                ibus_error;
  wire                ibus_avalid_r;
  wire [  ADDR_W-1:0] ibus_addr_r;

  // // DATA BUS
  wire                dbus_avalid;
  wire                dbus_ready;
  wire                dbus_avalid_int;
  wire                dbus_we;
  wire                dbus_uncached;
  wire [         1:0] dbus_size;
  wire                dbus_req_last;
  wire [  ADDR_W-1:0] dbus_addr;
  wire [  ADDR_W-1:0] dbus_addr_int;
  wire [  DATA_W-1:0] dbus_req_data;
  wire [  DATA_W-1:0] dbus_req_data_int;
  wire [DATA_W/8-1:0] dbus_strb;
  wire [DATA_W/8-1:0] dbus_strb_int;
  wire [DATA_W/8-1:0] dbus_mask;
  wire                dbus_ack;
  wire                dbus_resp_last;
  wire [  DATA_W-1:0] dbus_resp_data;
  wire                dbus_error;
  wire                dbus_avalid_r;
  wire [  ADDR_W-1:0] dbus_addr_r;
  wire [  DATA_W-1:0] dbus_req_data_r;
  wire [DATA_W/8-1:0] dbus_strb_r;


  // Logic
  // // INSTRUCTIONS BUS
  //modify addresses if DDR used according to boot status
  generate
    if (USE_EXTMEM) begin : g_use_extmem
      assign ibus_req = {
        ibus_avalid_int, ~boot, ibus_addr_int[ADDR_W-2:0], {DATA_W{1'b0}}, {DATA_W / 8{1'b0}}
      };
    end else begin : g_not_use_extmem
      assign ibus_req = {
        ibus_avalid_int, {1'b0}, ibus_addr_int[ADDR_W-2:0], {DATA_W{1'b0}}, {DATA_W / 8{1'b0}}
      };
    end
  endgenerate
  //assign ibus_ready = ibus_avalid_r ~^ ibus_ack; Used on OLD IObundle bus interface
  assign ibus_ready = ibus_resp[`READY(0)];
  assign ibus_avalid_int = (ibus_ready | ibus_ack) ? ibus_avalid : ibus_avalid_r;
  assign ibus_addr_int = (ibus_ready | ibus_ack) ? ibus_addr : ibus_addr_r;
  assign ibus_ack = (ibus_ready) & (ibus_avalid_r);
  assign ibus_resp_data = ibus_resp[`RDATA(0)];
  assign ibus_error = 1'b0;

  // // DATA BUS
  //modify addresses if DDR used according to boot status
  generate
    if (USE_EXTMEM) begin : g_use_extmem
      assign dbus_req = {
        dbus_avalid_int,
        (~boot & ~dbus_addr_int[P_BIT]) | (dbus_addr_int[E_BIT]),
        dbus_addr_int[ADDR_W-2:0],
        dbus_req_data_int,
        dbus_strb_int
      };
    end else begin : g_not_use_extmem
      assign dbus_req = {dbus_avalid_int, dbus_addr_int, dbus_req_data_int, dbus_strb_int};
    end
  endgenerate
  //assign dbus_ready = dbus_avalid_r ~^ dbus_ack; Used on OLD IObundle bus interface
  assign dbus_ready = dbus_resp[`READY(0)];
  assign dbus_avalid_int = (dbus_ready | dbus_ack) ? dbus_avalid : dbus_avalid_r;
  assign dbus_addr_int = (dbus_ready | dbus_ack) ? dbus_addr : dbus_addr_r;
  assign dbus_req_data_int = (dbus_ready | dbus_ack) ? dbus_req_data : dbus_req_data_r;
  assign dbus_strb_int = (dbus_ready | dbus_ack) ? dbus_strb : dbus_strb_r;
  assign dbus_strb = dbus_we ? dbus_mask : 4'h0;
  assign dbus_ack = (dbus_ready) & (dbus_avalid_r);
  assign dbus_resp_data = dbus_resp[`RDATA(0)];
  assign dbus_error = 1'b0;


  // Module intanciation
  // // INSTRUCTIONS BUS
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_i_avalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (ibus_ready),
      .data_i(ibus_avalid),
      .data_o(ibus_avalid_r)
  );
  iob_reg_re #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
  ) iob_reg_i_addr (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (ibus_ready),
      .data_i(ibus_addr),
      .data_o(ibus_addr_r)
  );

  // // DATA BUS
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_d_avalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (dbus_ready),
      .data_i(dbus_avalid),
      .data_o(dbus_avalid_r)
  );
  iob_reg_re #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
  ) iob_reg_d_addr (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (dbus_ready),
      .data_i(dbus_addr),
      .data_o(dbus_addr_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
  ) iob_reg_d_data (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (dbus_ready),
      .data_i(dbus_req_data),
      .data_o(dbus_req_data_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W / 8),
      .RST_VAL(0)
  ) iob_reg_d_strb (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (dbus_ready),
      .data_i(dbus_strb),
      .data_o(dbus_strb_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W / 8),
      .RST_VAL(0)
  ) iob_reg_d_last (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(dbus_req_last),
      .data_o(dbus_resp_last)
  );

  // // VexRiscv instantiation
  VexRiscv VexRiscv_core (
      .dBus_cmd_valid           (dbus_avalid),
      .dBus_cmd_ready           (dbus_ready),
      .dBus_cmd_payload_wr      (dbus_we),
      .dBus_cmd_payload_uncached(dbus_uncached),
      .dBus_cmd_payload_address (dbus_addr),
      .dBus_cmd_payload_data    (dbus_req_data),
      .dBus_cmd_payload_mask    (dbus_mask),
      .dBus_cmd_payload_size    (dbus_size),
      .dBus_cmd_payload_last    (dbus_req_last),
      .dBus_rsp_valid           (dbus_ack),
      .dBus_rsp_payload_last    (dbus_resp_last),
      .dBus_rsp_payload_data    (dbus_resp_data),
      .dBus_rsp_payload_error   (dbus_error),
      .timerInterrupt           (timerInterrupt),
      .externalInterrupt        (externalInterrupts[0]),
      .softwareInterrupt        (softwareInterrupt),
      .externalInterruptS       (externalInterrupts[1]),
      .iBus_cmd_valid           (ibus_avalid),
      .iBus_cmd_ready           (ibus_ready),
      .iBus_cmd_payload_address (ibus_addr),
      .iBus_cmd_payload_size    (ibus_size),
      .iBus_rsp_valid           (ibus_ack),
      .iBus_rsp_payload_data    (ibus_resp_data),
      .iBus_rsp_payload_error   (ibus_error),
      .clk                      (clk),
      .reset                    (rst)
  );

endmodule
