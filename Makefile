include config.mk

# Rules
.PHONY: vexriscv clean qemu

CPU ?= LinuxGen
#CPU ?= GenFullNoMmuNoCache

vexriscv:
	cp $(VEX_CORE_DIR)/* $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/demo/ && \
		cd submodules/VexRiscv && sbt "runMain vexriscv.demo.$(CPU)" && \
		cp VexRiscv.v $(VEXRISCV_SRC_DIR)

build-opensbi: clean-opensbi
	cp -r $(VEX_PLATAFORM_DIR)/* $(VEX_SUBMODULES_DIR)/OpenSBI/platform/ && \
		cd $(VEX_SUBMODULES_DIR)/OpenSBI && $(MAKE) run PLATFORM=iob_soc

build-rootfs: clean-rootfs
	cd $(VEX_SUBMODULES_DIR)/BusyBox && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- defconfig

build-rootfs-hello:
	cd software/rootfs && \
	  riscv64-unknown-linux-gnu-gcc -static -march=rv32imac -mabi=ilp32 hello.c -o hello && \
	  mkdir sub && cp hello sub/init && cd sub && \
	  find . | cpio -o -H newc | gzip > $(VEX_OS_DIR)/rootfs.cpio.gz && \
	  cd .. && rm -rf sub

build-linux-kernel: clean-linux-kernel
	cd $(VEX_SUBMODULES_DIR)/linux && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- rv32_iob_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- -j$(nproc)

build-dts:
	dtc -O dtb -o $(VEX_OS_DIR)/iob_soc.dtb software/iob_soc.dts

buildroot: clean-buildroot
	cp $(VEXRISCV_DIR)/software/buildroot/iob_soc_defconfig $(VEX_SUBMODULES_DIR)/buildroot/configs/ && \
		$(MAKE) iob_soc_defconfig && $(MAKE) -j2 && \
		cp buildroot/output/images/* $(VEX_OS_DIR)

## BuildRoot QEMU to deprecate ##
build-qemu: clean-buildroot
	mkdir LinuxOS
	cd buildroot && $(MAKE) qemu_riscv32_virt_defconfig && $(MAKE) -j2
	cp buildroot/output/images/* LinuxOS

run-qemu:
	qemu-system-riscv32 -M virt -bios LinuxOS/fw_jump.elf -kernel LinuxOS/Image -append "rootwait root=/dev/vda ro" -drive file=LinuxOS/rootfs.ext2,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -netdev user,id=net0 -device virtio-net-device,netdev=net0 -nographic



#
# Clean
#
clean-opensbi:
	cd $(VEX_SUBMODULES_DIR)/OpenSBI && $(MAKE) distclean

clean-rootfs:
	cd $(VEX_SUBMODULES_DIR)/BusyBox && $(MAKE) distclean

clean-linux-kernel:
	cd $(VEX_SUBMODULES_DIR)/linux && $(MAKE) distclean

clean-buildroot:
	cd buildroot && $(MAKE) clean && rm -rf dl output

clean-linux:
	@rm -rf ./LinuxOS

clean-all: clean-buildroot clean-linux
