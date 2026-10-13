# SPDX-FileCopyrightText: 2026 IObundle
#
# SPDX-License-Identifier: GPL-3.0-only

// Assembly macros for iob_cpu - included via #include in .S files
// (Processed by C preprocessor then GNU Assembler)

// VexRiscv data cache size (used for full cache flush)
#define DCACHE_SIZE (32 * 1024)
#define CACHE_LINE_SIZE 64

// The NOPs let the preceding stores drain first
.macro iob_cpu_flush_dcache
  .rept 10; nop; .endr; .word 0x500F
.endm

// Range flush - VexRiscv ignores range and flushes entire cache
.macro iob_cpu_flush_dcache_range start, len
  iob_cpu_flush_dcache
.endm

.macro iob_cpu_invalidate_icache
  fence.i
.endm
