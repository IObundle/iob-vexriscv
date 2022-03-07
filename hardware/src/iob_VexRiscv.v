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


   //intantiate VexRiscv

   VexRiscv VexRiscv_core(
     .dBus_cmd_valid                (dbus_req[`valid(0)]),
     .dBus_cmd_ready                (dbus_req[`ready(0)]),
     .dBus_cmd_payload_wr           (),
     .dBus_cmd_payload_uncached     (),
     .dBus_cmd_payload_address      (dbus_req[`address(0, `ADDR_W)]),
     .dBus_cmd_payload_data         (dbus_req[`wdata(0)]),
     .dBus_cmd_payload_mask         (dbus_req[`wstrb(0)]),
     .dBus_cmd_payload_size         (DATA_W),
     .dBus_cmd_payload_last         (),
     .dBus_rsp_valid                (dbus_resp[`ready(0)]),
     .dBus_rsp_payload_last         (),
     .dBus_rsp_payload_data         (dbus_resp[`rdata(0)]),
     .dBus_rsp_payload_error        (),
     .timerInterrupt                (),
     .externalInterrupt             (),
     .softwareInterrupt             (),
     .externalInterruptS            (),
     .debug_bus_cmd_valid           (),
     .debug_bus_cmd_ready           (),
     .debug_bus_cmd_payload_wr      (),
     .debug_bus_cmd_payload_address (),
     .debug_bus_cmd_payload_data    (),
     .debug_bus_rsp_data            (),
     .debug_resetOut                (trap),
     .iBus_cmd_valid                (ibus_req[`valid(0)]),
     .iBus_cmd_ready                (ibus_req[`ready(0)]),
     .iBus_cmd_payload_address      (ibus_req[`address(0, `ADDR_W)]),
     .iBus_cmd_payload_size         (DATA_W),
     .iBus_rsp_valid                (ibus_resp[`ready(0)]),
     .iBus_rsp_payload_data         (ibus_resp[`rdata(0)]),
     .iBus_rsp_payload_error        (),
     .clk                           (clk),
     .reset                         (~rst),
     .debugReset                    ()
     );

endmodule
