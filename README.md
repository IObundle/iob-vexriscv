<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# iob-vexriscv
This repository contains the hardware necessary to integrate the VexRiscv CPU on IOb-SoC.

## Requirements
- scala sbt: instructions of how to download can be found in https://www.scala-sbt.org/download.html;

## Makefile Targets
- vexriscv: build the Verilog RTL VexRiscv CPU core.
- clean-all: do all of the cleaning above

## Makefile Variables
- CPU: by default it has the value `LinuxGen`. However, the value could be any of the CPUs present in the VexRiscv demo directory (`submodules/VexRiscv/src/main/scala/vexriscv/demo`).

## Example:
To generate a new VexRiscv.v simply do:
- `make vexriscv CPU=LinuxGen`