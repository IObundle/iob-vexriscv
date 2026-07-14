# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT

import os


def setup(py_params_dict):
    # Each generated cpu verilog module must have a unique name due to different python parameters (can't have two differnet verilog modules with same name).
    assert "name" in py_params_dict, print(
        "Error: Missing name for generated vexriscv module."
    )

    params = {
        "reset_addr": 0x00000000,
        "uncached_start_addr": 0x00000000,
        "uncached_size": 2**32,
    }

    # Update params with values from py_params_dict
    for param in py_params_dict:
        if param in params:
            params[param] = py_params_dict[param]

    attributes_dict = {
        "name": py_params_dict["name"],
        "version": "0.1.0",
        "generate_hw": True,
        "confs": [
            {
                "name": "AXI_ID_W",
                "descr": "AXI ID bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "AXI_ADDR_W",
                "descr": "AXI address bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "AXI_DATA_W",
                "descr": "AXI data bus width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 32,
            },
            {
                "name": "AXI_LEN_W",
                "descr": "AXI burst length width",
                "type": "P",
                "val": 0,
                "min": 0,
                "max": 4,
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst_s",
                "descr": "Clock, clock enable and reset",
                "signals": {"type": "iob_clk"},
            },
            {
                "name": "rst_i",
                "descr": "Synchronous reset",
                "signals": [
                    {
                        "name": "rst_i",
                        "descr": "CPU synchronous reset",
                        "width": "1",
                    },
                ],
            },
            {
                "name": "i_bus_m",
                "descr": "iob-picorv32 instruction bus",
                "signals": {
                    "type": "axi",
                    "prefix": "ibus_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
            },
            {
                "name": "d_bus_m",
                "descr": "iob-picorv32 data bus",
                "signals": {
                    "type": "axi",
                    "prefix": "dbus_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
            },
            {
                "name": "interrupt_i",
                "descr": "Standard RISC‑V interrupt pending bits",
                "signals": [
                    {"name": "msip_i", "descr": "Machine software interrupt.", "width": "1"},
                    {"name": "mtip_i", "descr": "Machine timer interrupt.", "width": "1"},
                    {"name": "meip_i", "descr": "Machine external interrupt.", "width": "1"},
                    {"name": "seip_i", "descr": "Supervisor external interrupt.", "width": "1"},
                ],
            },
            {
                "name": "timebase_i",
                "descr": "Timebase interface",
                "signals": [
                    {"name": "mtime_i", "descr": "Input from external 64-bit counter for time CSRs", "width": "64"},
                ],
            },
        ],
        "wires": [
            {
                "name": "cpu_reset",
                "descr": "cpu reset signal",
                "signals": [
                    {"name": "cpu_reset", "width": "1"},
                ],
            },
            {
                "name": "ibus_int",
                "descr": "ibus internal signals",
                "signals": [
                    {"name": "ibus_axi_arregion_int", "width": "4"},
                ],
            },
            {
                "name": "dbus_int",
                "descr": "dbus internal signals",
                "signals": [
                    {"name": "dbus_axi_awregion_int", "width": "4"},
                    {"name": "dbus_axi_arregion_int", "width": "4"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    wire [7:0] ibus_axi_arlen_int;
    wire [7:0] dbus_axi_arlen_int;
    wire [7:0] dbus_axi_awlen_int;


  // Instantiation of VexRiscv core
  VexRiscvAxi4Linux CPU (
      // Interrupt sources
      .msip(msip_i),
      .mtip(mtip_i),
      .meip(meip_i),
      .seip(seip_i),
      // Timbase input
      .mtime(mtime_i),
""" + f"""\
      // CPU reset address
      .externalResetVector(32'h{params["reset_addr"]:x}),
      // Uncached memory
      .ioStartAddr(32'h{params["uncached_start_addr"]:x}),
      .ioSize(32'h{params["uncached_size"]:x}),
""" + """\
      // Instruction Bus
      .iBusAxi_arvalid(ibus_axi_arvalid_o),
      .iBusAxi_arready(ibus_axi_arready_i),
      .iBusAxi_araddr(ibus_axi_araddr_o),
      .iBusAxi_arid(ibus_axi_arid_o),
      .iBusAxi_arregion(ibus_axi_arregion_int),
      .iBusAxi_arlen(ibus_axi_arlen_int),
      .iBusAxi_arsize(ibus_axi_arsize_o),
      .iBusAxi_arburst(ibus_axi_arburst_o),
      .iBusAxi_arlock(ibus_axi_arlock_o),
      .iBusAxi_arcache(ibus_axi_arcache_o),
      .iBusAxi_arqos(ibus_axi_arqos_o),
      .iBusAxi_arprot(),
      .iBusAxi_rvalid(ibus_axi_rvalid_i),
      .iBusAxi_rready(ibus_axi_rready_o),
      .iBusAxi_rdata(ibus_axi_rdata_i),
      .iBusAxi_rid(ibus_axi_rid_i),
      .iBusAxi_rresp(ibus_axi_rresp_i),
      .iBusAxi_rlast(ibus_axi_rlast_i),
      // Data Bus
      .dBusAxi_awvalid(dbus_axi_awvalid_o),
      .dBusAxi_awready(dbus_axi_awready_i),
      .dBusAxi_awaddr(dbus_axi_awaddr_o),
      .dBusAxi_awid(dbus_axi_awid_o),
      .dBusAxi_awregion(dbus_axi_awregion_int),
      .dBusAxi_awlen(dbus_axi_awlen_int),
      .dBusAxi_awsize(dbus_axi_awsize_o),
      .dBusAxi_awburst(dbus_axi_awburst_o),
      .dBusAxi_awlock(dbus_axi_awlock_o),
      .dBusAxi_awcache(dbus_axi_awcache_o),
      .dBusAxi_awqos(dbus_axi_awqos_o),
      .dBusAxi_awprot(),
      .dBusAxi_wvalid(dbus_axi_wvalid_o),
      .dBusAxi_wready(dbus_axi_wready_i),
      .dBusAxi_wdata(dbus_axi_wdata_o),
      .dBusAxi_wstrb(dbus_axi_wstrb_o),
      .dBusAxi_wlast(dbus_axi_wlast_o),
      .dBusAxi_bvalid(dbus_axi_bvalid_i),
      .dBusAxi_bready(dbus_axi_bready_o),
      .dBusAxi_bid(dbus_axi_bid_i),
      .dBusAxi_bresp(dbus_axi_bresp_i),
      .dBusAxi_arvalid(dbus_axi_arvalid_o),
      .dBusAxi_arready(dbus_axi_arready_i),
      .dBusAxi_araddr(dbus_axi_araddr_o),
      .dBusAxi_arid(dbus_axi_arid_o),
      .dBusAxi_arregion(dbus_axi_arregion_int),
      .dBusAxi_arlen(dbus_axi_arlen_int),
      .dBusAxi_arsize(dbus_axi_arsize_o),
      .dBusAxi_arburst(dbus_axi_arburst_o),
      .dBusAxi_arlock(dbus_axi_arlock_o),
      .dBusAxi_arcache(dbus_axi_arcache_o),
      .dBusAxi_arqos(dbus_axi_arqos_o),
      .dBusAxi_arprot(),
      .dBusAxi_rvalid(dbus_axi_rvalid_i),
      .dBusAxi_rready(dbus_axi_rready_o),
      .dBusAxi_rdata(dbus_axi_rdata_i),
      .dBusAxi_rid(dbus_axi_rid_i),
      .dBusAxi_rresp(dbus_axi_rresp_i),
      .dBusAxi_rlast(dbus_axi_rlast_i),
      // Clock and Reset
      .clk(clk_i),
      .reset(cpu_reset)
  );



   assign cpu_reset = rst_i | arst_i;

   assign ibus_axi_awvalid_o = 1'b0;
   assign ibus_axi_awaddr_o = {AXI_ADDR_W{1'b0}};
   assign ibus_axi_awid_o = 1'b0;
   assign ibus_axi_awlen_o = {AXI_LEN_W{1'b0}};
   assign ibus_axi_awsize_o = {3{1'b0}};
   assign ibus_axi_awburst_o = {2{1'b0}};
   assign ibus_axi_awlock_o = 1'b0;
   assign ibus_axi_awcache_o = {4{1'b0}};
   assign ibus_axi_awqos_o = {4{1'b0}};
   assign ibus_axi_wvalid_o = 1'b0;
   assign ibus_axi_wdata_o = {AXI_DATA_W{1'b0}};
   assign ibus_axi_wstrb_o = {AXI_DATA_W / 8{1'b0}};
   assign ibus_axi_wlast_o = 1'b0;
   assign ibus_axi_bready_o = 1'b0;

   generate
      if (AXI_LEN_W < 8) begin : gen_if_less_than_8
         assign ibus_axi_arlen_o = ibus_axi_arlen_int[AXI_LEN_W-1:0];
         assign dbus_axi_arlen_o = dbus_axi_arlen_int[AXI_LEN_W-1:0];
         assign dbus_axi_awlen_o = dbus_axi_awlen_int[AXI_LEN_W-1:0];
      end else begin : gen_if_equal_8
         assign ibus_axi_arlen_o = ibus_axi_arlen_int;
         assign dbus_axi_arlen_o = dbus_axi_arlen_int;
         assign dbus_axi_awlen_o = dbus_axi_awlen_int;
      end
   endgenerate
"""
            }
        ],
    }

    # Disable linter for `VexRiscvAxi4Linux.v` source.
    if py_params_dict.get("py2hwsw_target", "") == "setup":
        build_dir = py_params_dict.get("build_dir")
        os.makedirs(f"{build_dir}/hardware/lint/verilator", exist_ok=True)
        with open(f"{build_dir}/hardware/lint/verilator_config.vlt", "a") as file:
            file.write(
                f"""
// Lines generated by {os.path.basename(__file__)}
lint_off -file "*/VexRiscvAxi4Linux.v"
"""
            )

    return attributes_dict
