# iob-vexriscv
This repository contains the hardware necessary to integrate the VexRiscv CPU on IOb-SoC. Furthermore, you can find here the needed tools to create a Linux Operating System that is capable of running in IOb-SoC with the VexRiscv core.

## Requirements
- RISC-V Linux/GNU toolchain: can be obtained from https://github.com/riscv-collab/riscv-gnu-toolchain; after cloning the repository in the terminal `cd` to the respective directory and configure with `./configure --prefix=/opt/riscv --enable-multilib`; After configuring you can build the Linux cross-compiler with `make Linux`.

## Makefile Targets
- vexriscv: build the Verilog RTL VexRiscv CPU core.
- build-opensbi: build the OpenSBI Linux Bootloader.
- build-rootfs: build the Linux root file system with busybox.
- build-linux-kernel: build the Linux kernel (WIP)
- build-dts: build the IOb-SoC device tree needed by the Linux Kernel
- build-buildroot: build all of the OS with buildroot (WIP)
- build-qemu: build all of the OS to test with qemu (WIP)
- run-qemu: run the OS in qemu
- clean-opensbi: remove the OpenSBI files
- clean-rootfs: remove the root file system files
- clean-linux-kernel: remove the Linux kernel files
- clean-buildroot: remove the buildroot files
- clean-OS: remove all of the OS files
- clean-all: do all of the cleaning above