#!/usr/bin/env python3

import os
import sys

from iob_module import iob_module
from setup import setup

# Submodules
from iob_reg_re import iob_reg_re

class iob_vexriscv(iob_module):
    name = "iob_vexriscv"
    version = "V0.10"
    flows = ""
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        # Hardware headers & modules
        iob_reg_re.setup()

        cls._setup_confs()
        cls._setup_ios()
        cls._setup_block_groups()

        # Verilog modules instances
        # TODO

        # Copy sources of this module to the build directory
        super()._run_setup()

        # Setup core using LIB function
        setup(cls)


    @classmethod
    def _setup_confs(cls):
        super()._setup_confs([
            # Macros

            # Parameters
            {'name':'ADDR_W', 'type':'P', 'val':'32', 'min':'1', 'max':'?', 'descr':'description here'},
            {'name':'DATA_W', 'type':'P', 'val':'32', 'min':'1', 'max':'?', 'descr':'description here'},
            {'name':'E_BIT', 'type':'P', 'val':'67', 'min':'1', 'max':'?', 'descr':'description here'},
            {'name':'P_BIT', 'type':'P', 'val':'66', 'min':'1', 'max':'?', 'descr':'description here'},
            {'name':'USE_EXTMEM', 'type':'P', 'val':'0', 'min':'0', 'max':'1', 'descr':'Select if configured for usage with external memory.'},
        ])

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {'name': 'general', 'descr':'General interface signals', 'ports': [
                {'name':"clk", 'type':"I", 'n_bits':'1', 'descr':"CPU clock input"},
                {'name':"rst", 'type':"I", 'n_bits':'1', 'descr':"CPU reset input"},
                {'name':"boot", 'type':"I", 'n_bits':'1', 'descr':"CPU boot input"},
            ]},
            {'name': 'instruction_bus', 'descr':'Instruction bus', 'ports': [
                {'name':"ibus_req", 'type':"O", 'n_bits':'`REQ_W', 'descr':"Instruction bus request"},
                {'name':"ibus_resp", 'type':"I", 'n_bits':'`RESP_W', 'descr':"Instruction bus response"},
            ]},
            {'name': 'data_bus', 'descr':'Data bus', 'ports': [
                {'name':"dbus_req", 'type':"O", 'n_bits':'`REQ_W', 'descr':"Data bus request"},
                {'name':"dbus_resp", 'type':"I", 'n_bits':'`RESP_W', 'descr':"Data bus response"},
            ]}
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
