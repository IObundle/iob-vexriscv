include config.mk

# Rules
.PHONY: vexriscv clean qemu

CPU ?= LinuxGen
#CPU ?= GenFullNoMmuNoCache

vexriscv:
	cd VexRiscv && sbt "runMain vexriscv.demo.$(CPU)" && cp VexRiscv.v ../hardware/src/

build-iob-linux: clean-buildroot
	mkdir LinuxOS
	cd buildroot && $(MAKE) iob_riscv32_defconfig && $(MAKE) -j3
	cp buildroot/output/images/* LinuxOS

build-qemu: clean-buildroot
	mkdir LinuxOS
	cd buildroot && $(MAKE) qemu_riscv32_virt_defconfig && $(MAKE) -j2
	cp buildroot/output/images/* LinuxOS

run-qemu:
	qemu-system-riscv32 -M virt -bios LinuxOS/fw_jump.elf -kernel LinuxOS/Image -append "rootwait root=/dev/vda ro" -drive file=LinuxOS/rootfs.ext2,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -netdev user,id=net0 -device virtio-net-device,netdev=net0 -nographic

check-dts:
	dtc -O dtb -o iob_soc.dtb software/iob_soc.dts
	rm iob_soc.dtb

#
# Clean
#
clean-buildroot:
	cd buildroot && $(MAKE) clean && rm -rf dl output


clean-linux:
	@rm -rf ./LinuxOS

clean-all: clean-buildroot clean-linux
