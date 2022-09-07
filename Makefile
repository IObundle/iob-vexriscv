include config.mk

# Rules
.PHONY: vexriscv clean qemu

CPU ?= LinuxGen
#CPU ?= GenFullNoMmuNoCache

vexriscv:
	cp $(VEX_SOFTWARE_DIR)/vexriscv_core/* $(VEX_SUBMODULES_DIR)/VexRiscv/src/main/scala/vexriscv/demo/ && \
		cd submodules/VexRiscv && sbt "runMain vexriscv.demo.$(CPU)" && \
		cp VexRiscv.v $(VEXRISCV_SRC_DIR)

build-opensbi: clean-opensbi
	cp -r $(VEX_SOFTWARE_DIR)/opensbi_platform/* $(VEX_SUBMODULES_DIR)/OpenSBI/platform/ && \
		cd $(VEX_SUBMODULES_DIR)/OpenSBI && $(MAKE) run PLATFORM=iob_soc

build-rootfs: clean-rootfs
	cd $(VEX_SUBMODULES_DIR)/busybox && \
		cp $(VEX_SOFTWARE_DIR)/rootfs_busybox/busybox_config $(VEX_SUBMODULES_DIR)/busybox/configs/iob_config && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- iob_config && \
		CROSS_COMPILE=riscv64-unknown-linux-gnu- $(MAKE) -j$(nproc) && \
		CROSS_COMPILE=riscv64-unknown-linux-gnu- $(MAKE) install && \
		cd _install/ && cp $(VEX_SOFTWARE_DIR)/rootfs_busybox/init init && \
		mkdir -p dev && sudo mknod dev/console c 5 1 && sudo mknod dev/ram0 b 1 0 && \
		find -print0 | cpio -0oH newc | gzip -9 > $(VEX_OS_DIR)/rootfs.cpio.gz

build-linux-kernel: clean-linux-kernel
	cd $(VEX_SUBMODULES_DIR)/linux && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- rv32_iob_defconfig && \
		$(MAKE) ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- -j$(nproc)

build-dts:
	dtc -O dtb -o $(VEX_OS_DIR)/iob_soc.dtb $(VEX_SOFTWARE_DIR)/iob_soc.dts

build-buildroot: clean-buildroot
	cp $(VEX_SOFTWARE_DIR)/buildroot/iob_soc_defconfig $(VEX_SUBMODULES_DIR)/buildroot/configs/ && \
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
	cd $(VEX_SUBMODULES_DIR)/busybox && $(MAKE) distclean

clean-linux-kernel:
	cd $(VEX_SUBMODULES_DIR)/linux && $(MAKE) distclean

clean-buildroot:
	cd buildroot && $(MAKE) clean && rm -rf dl output

clean-OS:
	@rm -rf $(VEX_OS_DIR)/*

clean-all: clean-OS
