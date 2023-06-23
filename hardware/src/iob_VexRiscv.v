/*
 *  IOb-VexRiscv -- A VexRiscv Wrapper
 */
`timescale 1 ns / 1 ps
`include "iob_vexriscv_conf.vh"
`include "iob_lib.vh"

module iob_VexRiscv #(
    `include "iob_vexriscv_params.vs"
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

  `include "iob_VexRiscv_wires.vs"

  // Logic
  // // INSTRUCTIONS BUS
  // // // Unpacking the responce bus
  assign ibus_ready = ibus_resp[`READY(0)];
//assign ibus_ready = ibus_avalid_r ~^ ibus_ack; Used on OLD IObundle bus interface
  assign ibus_rvalid = ibus_resp[`RVALID(0)];
  assign ibus_resp_data = ibus_resp[`RDATA(0)];
  // // // VexRiscv error signal is equal to 0. Since the IOb-bus does not support errors.
  assign ibus_error = 1'b0;

  // // // Packing the request bus
  assign ibus_req = {
    ibus_avalid, ibus_addr_msb, ibus_addr[ADDR_W-2:0], {DATA_W{1'b0}}, {DATA_W / 8{1'b0}}
  };
  // // // IOb-bus address most significant bit should be 0 while executing the bootloader and 1 when running the firmware. This consideres that the firmware will always run in the external memory.
  assign ibus_addr_msb = ~boot_i;

  // // DATA BUS
  // // // Unpacking the responce bus
  assign dbus_ready = dbus_resp[`READY(0)];
//assign dbus_ready = dbus_avalid_r ~^ dbus_ack; Used on OLD IObundle bus interface
  assign dbus_rvalid = dbus_resp[`RVALID(0)];
  assign dbus_resp_data = dbus_resp[`RDATA(0)];
  // // // VexRiscv error signal is equal to 0. Since the IOb-bus does not support errors.
  assign dbus_error = 1'b0;
  // // // VexRiscv ack is either the rvalid (which happens when a read is executed) or a write ack (delayed 1 clk cycle) generated in this wrapper.
  assign dbus_ack = dbus_rvalid | dbus_wack_r;
  // // // The write ack is asserted to 1 when the avalid is sent to the SoC, if the strb signal is diferent than 4'h0.
  assign dbus_wack = (ibus_ready) & dbus_avalid & (|dbus_strb_int);

  // // // Packing the request bus
  assign dbus_req = {
    dbus_avalid, dbus_addr, dbus_req_data, dbus_strb
  };
  // // // IOb-Bus strb, if VexRiscv enables dbus_we then is equal to dbus_mask; if not it is 0.
  assign dbus_strb = dbus_we ? dbus_mask : 4'h0;

  `include "iob_VexRiscv_regs.vs"

  // VexRiscv instantiation
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
      .iBus_rsp_valid           (ibus_rvalid),
      .iBus_rsp_payload_data    (ibus_resp_data),
      .iBus_rsp_payload_error   (ibus_error),
      .clk                      (clk_i),
      .reset                    (arst_i)
  );

endmodule
