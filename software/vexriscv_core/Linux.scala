/*
 * SpinalHDL
 * Copyright (c) Dolu, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

package vexriscv.demo

import spinal.core._
import spinal.lib.eda.bench.{AlteraStdTargets, Bench, Rtl, XilinxStdTargets}
import spinal.lib.eda.icestorm.IcestormStdTargets
import spinal.lib.master
import vexriscv._
import vexriscv.ip._
import vexriscv.plugin._

object LinuxGen {
  def configFull(litex : Boolean, withMmu : Boolean, withSmp : Boolean = false) = {
    val config = VexRiscvConfig(
      plugins = List(
        new IBusCachedPlugin(
          resetVector = 0x00000000l,
          prediction = NONE,
          historyRamSizeLog2 = 10,
          compressedGen = true,
          injectorStage = true,
          config = InstructionCacheConfig(
            cacheSize = 4096*1,
            bytePerLine = 4,
            wayCount = 1,
            addressWidth = 32,
            cpuDataWidth = 32,
            memDataWidth = 32,
            catchIllegalAccess = true,
            catchAccessFault = true,
            asyncTagMemory = false,
            twoCycleRam = false,
            twoCycleCache = true
          ),
          memoryTranslatorPortConfig = withMmu generate MmuPortConfig(
            portTlbSize = 4
          )
        ),
        new DBusCachedPlugin(
          //dBusCmdMasterPipe = true,
          //dBusCmdSlavePipe = true,
          //dBusRspSlavePipe = true,
          config = new DataCacheConfig(
            cacheSize         = 4096*1,
            bytePerLine       = 4,
            wayCount          = 1,
            addressWidth      = 32,
            cpuDataWidth      = 32,
            memDataWidth      = 32,
            catchAccessError  = true,
            catchIllegal      = true,
            catchUnaligned    = true,
            withExclusive = withSmp,
            withInvalidate = withSmp,
            withLrSc = true,
            withAmo = true
          ),
          memoryTranslatorPortConfig = withMmu generate MmuPortConfig(
            portTlbSize = 4
          )
        ),
        new DecoderSimplePlugin(
          catchIllegalInstruction = true
        ),
        new RegFilePlugin(
          regFileReadyKind = plugin.SYNC,
          zeroBoot = true
        ),
        new IntAluPlugin,
        new SrcPlugin(
          separatedAddSub = true
        ),
        new FullBarrelShifterPlugin(earlyInjection = false),
        new HazardSimplePlugin(
          bypassExecute           = true,
          bypassMemory            = true,
          bypassWriteBack         = true,
          bypassWriteBackBuffer   = true,
          pessimisticUseSrc       = false,
          pessimisticWriteRegFile = false,
          pessimisticAddressMatch = false
        ),
        new MulPlugin,
        new MulDivIterativePlugin(
          genMul = false,
          genDiv = true,
          mulUnrollFactor = 32,
          divUnrollFactor = 4
        ),
        new CsrPlugin(CsrPluginConfig.linuxFull(0x08000020l).copy(misaExtensionsInit = 0x0141115, ebreakGen = true)),
        new DebugPlugin(ClockDomain.current.clone(reset = Bool().setName("debugReset"))),
        new BranchPlugin(
          earlyBranch = false,
          catchAddressMisaligned = true,
          fenceiGenAsAJump = false
        ),
        new YamlPlugin("cpu0.yaml")
      )
    )
    if(withMmu) config.plugins += new MmuPlugin(
      ioRange = (x => if(litex) x(31 downto 30) === 0x1 else x(31 downto 28) === 0xF)
    ) else {
      config.plugins += new StaticMemoryTranslatorPlugin(
        ioRange      = _(31 downto 28) === 0xF
      )
    }
    config
  }



  def main(args: Array[String]) {
    SpinalConfig(mergeAsyncProcess = false, anonymSignalPrefix = "_zz").generateVerilog {
      val toplevel = new VexRiscv(configFull(
        litex = !args.contains("-r"),
        withMmu = true
      ))
      toplevel
    }
  }
}

object LinuxSyntesisBench extends App{
  val withoutMmu = new Rtl {
    override def getName(): String = "VexRiscv Without Mmu"
    override def getRtlPath(): String = "VexRiscvWithoutMmu.v"
    SpinalConfig(inlineRom=true).generateVerilog(new VexRiscv(LinuxGen.configFull(litex = false, withMmu = false)).setDefinitionName(getRtlPath().split("\\.").head))
  }

  val withMmu = new Rtl {
    override def getName(): String = "VexRiscv With Mmu"
    override def getRtlPath(): String = "VexRiscvWithMmu.v"
    SpinalConfig(inlineRom=true).generateVerilog(new VexRiscv(LinuxGen.configFull(litex = false, withMmu = true)).setDefinitionName(getRtlPath().split("\\.").head))
  }

  val rtls = List(withoutMmu,withMmu)

  val targets = XilinxStdTargets(
    vivadoArtix7Path = "/media/miaou/HD/linux/Xilinx/Vivado/2018.3/bin"
  ) ++ AlteraStdTargets(
    quartusCycloneIVPath = "/media/miaou/HD/linux/intelFPGA_lite/18.1/quartus/bin",
    quartusCycloneVPath  = "/media/miaou/HD/linux/intelFPGA_lite/18.1/quartus/bin"
  )

  Bench(rtls, targets, "/media/miaou/HD/linux/tmp")
}

object LinuxSim extends App{
  import spinal.core.sim._

  SimConfig.allOptimisation.compile(new VexRiscv(LinuxGen.configFull(litex = false, withMmu = true))).doSim{dut =>

    var cycleCounter = 0l
    var lastTime = System.nanoTime()

    var iBus : IBusSimpleBus = null
    var dBus : DBusSimpleBus = null
    dut.plugins.foreach{
      case p : IBusSimplePlugin =>
        iBus = p.iBus
      case p : DBusSimplePlugin =>
        dBus = p.dBus
      case _ =>
    }

    dut.clockDomain.resetSim #= false
    dut.clockDomain.clockSim #= false
    sleep(1)
    dut.clockDomain.resetSim #= true
    sleep(1)

    def f(): Unit ={
      cycleCounter += 1

      if((cycleCounter & 8191) == 0){
        val currentTime = System.nanoTime()
        val deltaTime = (currentTime - lastTime)*1e-9
        if(deltaTime > 2.0) {
          println(f"[Info] Simulation speed : ${cycleCounter / deltaTime * 1e-3}%4.0f kcycles/s")
          lastTime = currentTime
          cycleCounter = 0
        }
      }
      dut.clockDomain.clockSim #= false
      iBus.cmd.ready #= ! iBus.cmd.ready.toBoolean
      dBus.cmd.ready #= ! dBus.cmd.ready.toBoolean
      delayed(1)(f2)
    }
    def f2(): Unit ={
      dut.clockDomain.clockSim #= true
      delayed(1)(f)
    }

    delayed(1)(f)

    sleep(100000000)
  }
}
