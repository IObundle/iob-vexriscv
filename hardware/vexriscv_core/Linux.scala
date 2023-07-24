package vexriscv.demo

import spinal.core._
import spinal.lib._
import vexriscv.ip.{DataCacheConfig, InstructionCacheConfig}
import vexriscv.plugin._
import vexriscv.{Riscv, VexRiscv, VexRiscvConfig, plugin}

object LinuxGen {
  def configFull(litex : Boolean, withMmu : Boolean, withSmp : Boolean = false) = {
    val cpuConfig = VexRiscvConfig(
      plugins = List(
          new IBusCachedPlugin(
            resetVector = 0x80000000l,
            prediction = STATIC,
            compressedGen = true,
            injectorStage = true,
            config = InstructionCacheConfig(
              cacheSize = 4096,
              bytePerLine = 4,
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
              bytePerLine       = 4,
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
            ioRange      = (x => x(31 downto 30) === 0x1 || x(31 downto 29) === 0x1 || x(31 downto 28) === 0x1 || x(31 downto 27) === 0x1)
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
          new CsrPlugin(CsrPluginConfig.linuxFull(0x80000020l).copy(mhartid = 0, misaExtensionsInit = Riscv.misaToInt(s"imac"), ebreakGen = true)),
          new YamlPlugin("cpu0.yaml")
      )
    )
    cpuConfig
  }

  def main(args: Array[String]) {
    val report = SpinalVerilog{
      val toplevel = new VexRiscv(configFull(
        litex = !args.contains("-r"),
        withMmu = true
      ))
      toplevel
    }
  }
}
