/*
 *  IOb-VexRiscv -- A VexRiscv Wrapper
 */


`timescale 1 ns / 1 ps
`include "system.vh"
`include "iob_intercon.vh"

//the look ahead interface is not working because mem_instr is unknown at request
//`define LA_IF

module iob_VexRiscv
  #(
    parameter ADDR_W=32,
    parameter DATA_W=32
    )
   (
    input               clk,
    input               rst,
    input               boot,
    output              trap,

    // instruction bus
    output [`REQ_W-1:0] ibus_req,
    input [`RESP_W-1:0] ibus_resp,

    // data bus
    output [`REQ_W-1:0] dbus_req,
    input [`RESP_W-1:0] dbus_resp
    );

    wire                ibus_req_valid;
    wire                ibus_req_ready;
    wire [ADDR_W-1:0] ibus_req_address;
    wire [DATA_W-1:0]    ibus_req_data;
    wire               ibus_resp_ready;
    wire [DATA_W-1:0]   ibus_resp_data;

    assign ibus_req_valid = ibus_req[`valid(0)];
    assign ibus_req_ready = ibus_req_valid & ~ibus_resp_ready;
    assign ibus_req_address = ibus_req[`address(0, `ADDR_W)];
    assign ibus_req_data = ibus_req[`wdata(0)];
    assign ibus_resp_ready = ibus_resp[`ready(0)];
    assign ibus_resp_data = ibus_resp[`rdata(0)];

    wire                dbus_req_valid;
    wire                dbus_req_ready;
    wire [ADDR_W-1:0] dbus_req_address;
    wire [DATA_W-1:0]    dbus_req_data;
    wire                 dbus_req_strb;
    wire               dbus_resp_ready;
    wire [DATA_W-1:0]   dbus_resp_data;

    assign dbus_req_valid = dbus_req[`valid(0)];
    assign dbus_req_ready = dbus_req_valid & ~dbus_resp_ready;
    assign dbus_req_address = dbus_req[`address(0, `ADDR_W)];
    assign dbus_req_data = dbus_req[`wdata(0)];
    assign dbus_req_strb = dbus_req[`wstrb(0)];
    assign dbus_resp_ready = dbus_resp[`ready(0)];
    assign dbus_resp_data = dbus_resp[`rdata(0)];

   //intantiate VexRiscv

   VexRiscv VexRiscv_core(
     .dBus_cmd_valid                (dbus_req_valid),
     .dBus_cmd_ready                (dbus_req_ready),
     .dBus_cmd_payload_wr           (),
     .dBus_cmd_payload_uncached     (),
     .dBus_cmd_payload_address      (dbus_req_address),
     .dBus_cmd_payload_data         (dbus_req_data),
     .dBus_cmd_payload_mask         (dbus_req_strb),
     .dBus_cmd_payload_size         (),
     .dBus_cmd_payload_last         (),
     .dBus_rsp_valid                (dbus_resp_ready),
     .dBus_rsp_payload_last         (1'b0),
     .dBus_rsp_payload_data         (dbus_resp_data),
     .dBus_rsp_payload_error        (1'b0),
     .timerInterrupt                (1'b0),
     .externalInterrupt             (1'b0),
     .softwareInterrupt             (1'b0),
     .externalInterruptS            (1'b0),
     .debug_bus_cmd_valid           (1'b0),
     .debug_bus_cmd_ready           (),
     .debug_bus_cmd_payload_wr      (1'b0),
     .debug_bus_cmd_payload_address (8'd0),
     .debug_bus_cmd_payload_data    (32'd0),
     .debug_bus_rsp_data            (),
     .debug_resetOut                (trap),
     .iBus_cmd_valid                (ibus_req_valid),
     .iBus_cmd_ready                (ibus_req_ready),
     .iBus_cmd_payload_address      (ibus_req_address),
     .iBus_cmd_payload_size         (),
     .iBus_rsp_valid                (ibus_resp_ready),
     .iBus_rsp_payload_data         (ibus_resp_data),
     .iBus_rsp_payload_error        (1'b0),
     .clk                           (clk),
     .reset                         (~rst),
     .debugReset                    (~rst)
     );

endmodule
