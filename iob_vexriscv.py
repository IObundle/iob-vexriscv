def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_vexriscv",
        "name": "iob_vexriscv",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "E_BIT",
                "type": "P",
                "val": "67",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "P_BIT",
                "type": "P",
                "val": "66",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "USE_EXTMEM",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "1",
                "descr": "Select if configured for usage with external memory.",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "descr": "Clock, clock enable and reset",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
            },
            {
                "name": "rst",
                "descr": "Synchronous reset",
                "signals": [
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": "1",
                        "descr": "CPU synchronous reset",
                    },
                    # TODO: Deprecate boot input. Instead update reset address to 0x80000000.
                    # {
                    #    "name": "boot",
                    #    "direction": "input",
                    #    "width": "1",
                    #    "descr": "CPU boot mode",
                    # },
                ],
            },
            # TODO: Deprecate REQ and RESP
            # {
            #    "name": "instruction_bus",
            #    "descr": "Instruction bus",
            #    "signals": [
            #        {
            #            "name": "ibus_req",
            #            "direction": "output",
            #            "n_bits": "`REQ_W",
            #            "descr": "Instruction bus request",
            #        },
            #        {
            #            "name": "ibus_resp",
            #            "direction": "input",
            #            "n_bits": "`RESP_W",
            #            "descr": "Instruction bus response",
            #        },
            #    ],
            # },
            # {
            #    "name": "data_bus",
            #    "descr": "Data bus",
            #    "signals": [
            #        {
            #            "name": "dbus_req",
            #            "direction": "output",
            #            "n_bits": "`REQ_W",
            #            "descr": "Data bus request",
            #        },
            #        {
            #            "name": "dbus_resp",
            #            "direction": "input",
            #            "n_bits": "`RESP_W",
            #            "descr": "Data bus response",
            #        },
            #    ],
            # },
            {
                "name": "i_bus",
                "descr": "iob-picorv32 instruction bus",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "port_prefix": "ibus_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
            {
                "name": "d_bus",
                "descr": "iob-picorv32 data bus",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "port_prefix": "dbus_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
        ],
    }

    return attributes_dict
