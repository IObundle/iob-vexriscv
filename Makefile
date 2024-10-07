# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

#PATHS
VEXRISCV_DIR ?= $(shell pwd)
VEX_HARDWARE_DIR:=$(VEXRISCV_DIR)/hardware
VEXRISCV_SRC_DIR:=$(VEX_HARDWARE_DIR)/src
VEX_SUBMODULES_DIR:=$(VEXRISCV_DIR)/submodules

# Rules
.PHONY: vexriscv clean-all qemu

CPU ?= VexRiscvAxi4LinuxPlicClint
JDK_HOME := $(shell dirname $$(dirname $$(which java)))

# Primary targets
vexriscv:
	cp $(VEX_HARDWARE_DIR)/vexriscv_core/* $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/demo/
	cd submodules/VexRiscv && \
	sbt -java-home $(JDK_HOME) "runMain vexriscv.demo.$(CPU)" && \
	cp $(CPU).v $(VEXRISCV_SRC_DIR)

#
# Clean
#
clean-vexriscv:
	rm $(VEXRISCV_SRC_DIR)/$(CPU).v

clean-all: clean-vexriscv
