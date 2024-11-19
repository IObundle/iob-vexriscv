// SPDX-FileCopyrightText: 2024 IObundle
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

object VexRiscvAxi4LinuxPlicClint{
  def main(args: Array[String]) {
    val report = SpinalVerilog{

      //CPU configuration
      val cpuConfig = VexRiscvConfig(
        plugins = List(
          new IBusCachedPlugin(
            resetVector = 0x80000000l,
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
            ioRange = _(31 downto 30) === 0x3
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
        val clintCtrl = new AxiLite4Clint(1, bufferTime = false)
        val plicCtrl = new AxiLite4Plic(
          sourceCount = 31,
          targetCount = 2
        )

        val clint = clintCtrl.io.bus.toIo()
        val plic = plicCtrl.io.bus.toIo()
        val plicInterrupts = in Bits(32 bits)
        plicCtrl.io.sources := plicInterrupts >> 1

        AxiLite4SpecRenamer(clint)
        AxiLite4SpecRenamer(plic)
      }

      //CPU modifications to be an Avalon one
      cpu.setDefinitionName("VexRiscvAxi4LinuxPlicClint")
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
            plugin.timerInterrupt     setAsDirectionLess() := cpu.clintCtrl.io.timerInterrupt(0)
            plugin.softwareInterrupt  setAsDirectionLess() := cpu.clintCtrl.io.softwareInterrupt(0)
            plugin.externalInterrupt  setAsDirectionLess() := cpu.plicCtrl.io.targets(0)
            plugin.externalInterruptS setAsDirectionLess() := cpu.plicCtrl.io.targets(1)
            plugin.utime              setAsDirectionLess() := cpu.clintCtrl.io.time
          }
          case _ =>
        }
      }
      cpu
    }
  }
}
