// SPDX-FileCopyrightText: 2025 IObundle
//
// SPDX-License-Identifier: MIT

package vexriscv.demo

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi.{Axi4ReadOnly, Axi4SpecRenamer}
import spinal.lib.bus.amba4.axilite.AxiLite4SpecRenamer
import spinal.lib.misc.AxiLite4Clint
import spinal.lib.misc.plic.AxiLite4Plic
import vexriscv.ip.{DataCacheConfig, InstructionCacheConfig}
import vexriscv.plugin._
import vexriscv.{Riscv, VexRiscv, VexRiscvConfig, plugin}

object VexRiscvAxi4Linux{
  def main(args: Array[String]) {
    val generatePlicClint = args.contains("plic-clint")
    val report = SpinalVerilog{

      //CPU configuration
      val cpuConfig = VexRiscvConfig(
        plugins = List(
          new IBusCachedPlugin(
            resetVector = null,
            prediction = NONE,
            compressedGen = true,
            injectorStage = true,
            config = InstructionCacheConfig(
              cacheSize = 4096,
              bytePerLine = 64,
              wayCount = 1,
              addressWidth = 32,
              cpuDataWidth = 32,
              memDataWidth = 32,
              catchIllegalAccess = true,
              catchAccessFault = true,
              asyncTagMemory = false,
              twoCycleRam = true,
              twoCycleCache = true
            ),
            memoryTranslatorPortConfig = MmuPortConfig(
              portTlbSize = 4,
              latency = 1,
              earlyRequireMmuLockup = true,
              earlyCacheHits = true
            )
          ),
          new DBusCachedPlugin(
            config = new DataCacheConfig(
              cacheSize         = 4096,
              bytePerLine       = 64,
              wayCount          = 1,
              addressWidth      = 32,
              cpuDataWidth      = 32,
              memDataWidth      = 32,
              catchAccessError  = true,
              catchIllegal      = true,
              catchUnaligned    = true,
              withLrSc = true,
              withAmo = true
            ),
            memoryTranslatorPortConfig = MmuPortConfig(
              portTlbSize = 4,
              latency = 1,
              earlyRequireMmuLockup = true,
              earlyCacheHits = true
            )
          ),
          new MmuPlugin(
            ioRange = null
          ),
          new DecoderSimplePlugin(
            catchIllegalInstruction = true
          ),
          new RegFilePlugin(
            regFileReadyKind = plugin.SYNC,
            zeroBoot = false
          ),
          new IntAluPlugin,
          new SrcPlugin(
            separatedAddSub = false,
            executeInsertion = true
          ),
          new FullBarrelShifterPlugin,
          new MulPlugin,
          new DivPlugin,
          new HazardSimplePlugin(
            bypassExecute           = true,
            bypassMemory            = true,
            bypassWriteBack         = true,
            bypassWriteBackBuffer   = true,
            pessimisticUseSrc       = false,
            pessimisticWriteRegFile = false,
            pessimisticAddressMatch = false
          ),
          new BranchPlugin(
            earlyBranch = false,
            catchAddressMisaligned = true
          ),
          new CsrPlugin(CsrPluginConfig.linuxFull(0x80000020l).copy(misaExtensionsInit = 0x0141105, ebreakGen = true).copy(utimeAccess = CsrAccess.READ_ONLY)),
          new YamlPlugin("cpu0.yaml")
        )
      )

      //CPU instanciation
      val cpu = new VexRiscv(cpuConfig){
        var clintCtrl: AxiLite4Clint = null
        var plicCtrl: AxiLite4Plic = null

        if(generatePlicClint) {
          clintCtrl = new AxiLite4Clint(1, bufferTime = false)
          plicCtrl = new AxiLite4Plic(
            sourceCount = 31,
            targetCount = 2
          )
        }

        val clint = if(generatePlicClint) clintCtrl.io.bus.toIo() else null
        val plic = if(generatePlicClint) plicCtrl.io.bus.toIo() else null

        val externalInterrupts = if (generatePlicClint) in(Bits(32 bits)) else null

        // External Timer Interrupt: Connect to an external timer interrupt source.
        val mtip = if(!generatePlicClint) in(Bool) else null
        // External Software Interrupt: Connect to an external software interrupt source.
        val msip = if(!generatePlicClint) in(Bool) else null
        // External Machine-mode External Interrupt: Connect to an external machine-mode interrupt source.
        val meip = if(!generatePlicClint) in(Bool) else null
        // External Supervisor-mode External Interrupt: Connect to an external supervisor-mode interrupt source.
        val seip = if(!generatePlicClint) in(Bool) else null
        // External mtime: Connect to an external 64-bit time counter.
        val mtime = if(!generatePlicClint) in(UInt(64 bits)) else null

        if(generatePlicClint) {
          plicCtrl.io.sources := externalInterrupts >> 1

          AxiLite4SpecRenamer(clint)
          AxiLite4SpecRenamer(plic)
        }
      }

      //CPU modifications to be an Avalon one
      cpu.setDefinitionName("VexRiscvAxi4Linux")
      cpu.rework {
        for (plugin <- cpuConfig.plugins) plugin match {
          case plugin: IBusCachedPlugin => {
            plugin.iBus.setAsDirectionLess() //Unset IO properties of iBus
            Axi4SpecRenamer(
              master(plugin.iBus.toAxi4ReadOnly().toFullConfig())
                .setName("iBusAxi")
                .addTag(ClockDomainTag(ClockDomain.current)) //Specify a clock domain to the iBus (used by QSysify)
            )
          }
          case plugin: DBusCachedPlugin => {
            plugin.dBus.setAsDirectionLess()
            Axi4SpecRenamer(
              master(plugin.dBus.toAxi4Shared().toAxi4().toFullConfig())
                .setName("dBusAxi")
                .addTag(ClockDomainTag(ClockDomain.current))
            )
          }
          case plugin: CsrPlugin => {
            if(generatePlicClint) {
              plugin.timerInterrupt.setAsDirectionLess().setName("csr_timerInterrupt") := cpu.clintCtrl.io.timerInterrupt(0)
              plugin.softwareInterrupt.setAsDirectionLess().setName("csr_softwareInterrupt") := cpu.clintCtrl.io.softwareInterrupt(0)
              plugin.externalInterrupt.setAsDirectionLess().setName("csr_externalInterrupt") := cpu.plicCtrl.io.targets(0)
              plugin.externalInterruptS.setAsDirectionLess().setName("csr_externalInterruptS") := cpu.plicCtrl.io.targets(1)
              plugin.utime.setAsDirectionLess().setName("csr_utime") := cpu.clintCtrl.io.time
            } else {
              plugin.timerInterrupt.setAsDirectionLess().setName("csr_timerInterrupt") := cpu.mtip
              plugin.softwareInterrupt.setAsDirectionLess().setName("csr_softwareInterrupt") := cpu.msip
              plugin.externalInterrupt.setAsDirectionLess().setName("csr_externalInterrupt") := cpu.meip
              plugin.externalInterruptS.setAsDirectionLess().setName("csr_externalInterruptS") := cpu.seip
              plugin.utime.setAsDirectionLess().setName("csr_utime") := cpu.mtime
            }
          }
          case _ =>
        }
      }
      cpu
    }
  }
}
