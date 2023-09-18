#PATHS
VEXRISCV_DIR ?= $(shell pwd)
VEX_HARDWARE_DIR:=$(VEXRISCV_DIR)/hardware
VEXRISCV_SRC_DIR:=$(VEX_HARDWARE_DIR)/src
VEX_SUBMODULES_DIR:=$(VEXRISCV_DIR)/submodules

# Rules
.PHONY: vexriscv clean-all qemu

CPU ?= VexRiscvAxi4LinuxPlicClint

# Primary targets
vexriscv:
	cp $(VEX_HARDWARE_DIR)/vexriscv_core/* $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/demo/ && \
		cd submodules/VexRiscv && sbt "runMain vexriscv.demo.$(CPU)" && \
		cp VexRiscv.v $(VEXRISCV_SRC_DIR)

#
# Clean
#
clean-vexriscv:
	rm $(VEXRISCV_SRC_DIR)/VexRiscv.v

clean-all: clean-vexriscv
