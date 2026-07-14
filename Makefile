# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT

#PATHS
VEXRISCV_DIR ?= $(shell pwd)
VEX_HARDWARE_DIR:=$(VEXRISCV_DIR)/hardware
VEXRISCV_SRC_DIR:=$(VEX_HARDWARE_DIR)/src
VEX_SUBMODULES_DIR:=$(VEXRISCV_DIR)/submodules

# Rules
.PHONY: vexriscv clean-all qemu

CPU ?= VexRiscvAxi4Linux
JDK_HOME := $(shell dirname $$(dirname $$(which java)))

GENERATE_PLIC_CLINT ?=0

ifneq ($(GENERATE_PLIC_CLINT),0)
SPINALHDL_ARGS=plic-clint
CPU_SUFFIX=PlicClint
endif

# Primary targets
vexriscv:
	cp $(VEX_HARDWARE_DIR)/vexriscv_core/$(CPU).scala $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/demo/
	cp $(VEX_HARDWARE_DIR)/vexriscv_core/MmuPlugin.scala $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/plugin/
	# Copy fixed IBus and DBus cached plugins
	cp $(VEX_HARDWARE_DIR)/vexriscv_core/IBusCachedPlugin.scala $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/plugin/
	cp $(VEX_HARDWARE_DIR)/vexriscv_core/DBusCachedPlugin.scala $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/plugin/
	cd submodules/VexRiscv && \
	sbt -java-home $(JDK_HOME) "runMain vexriscv.demo.$(CPU) $(SPINALHDL_ARGS)" && \
	cp $(CPU).v $(VEXRISCV_SRC_DIR)/$(CPU)$(CPU_SUFFIX).v

#
# Clean
#
clean-vexriscv:
	rm $(VEXRISCV_SRC_DIR)/$(CPU)$(CPU_SUFFIX).v

clean-all: clean-vexriscv
