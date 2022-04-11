include config.mk

# Rules
.PHONY: vexriscv clean qemu

#CPU ?= LinuxGen
CPU ?= GenFullNoMmuNoCache

vexriscv:
	cd VexRiscv && sbt "runMain vexriscv.demo.$(CPU)" && cp VexRiscv.v ../hardware/src/

qemu:
	mkdir LinuxOS
	cd buildroot && $(MAKE) qemu_riscv32_virt_defconfig && $(MAKE) -j2
	cp buildroot/output/images/* LinuxOS
	qemu-system-riscv32 -M virt -bios LinuxOS/fw_jump.elf -kernel LinuxOS/Image -append "rootwait root=/dev/vda ro" -drive file=LinuxOS/rootfs.ext2,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -netdev user,id=net0 -device virtio-net-device,netdev=net0 -nographic

#
# Clean
#
clean-qemu:
	cd buildroot && $(MAKE) clean && rm -rf dl output

clean-all: clean-qemu
	@rm -rf ./LinuxOS/
