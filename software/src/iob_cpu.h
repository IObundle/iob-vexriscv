/*
 * SPDX-FileCopyrightText: 2026 IObundle
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

// CPU-specific software operations: each CPU module provides this header, so
// the bootloader and the firmware stay CPU agnostic. Usable from C.
//
//   iob_cpu_flush_dcache: write the entire data cache back to memory and invalidate it
//   iob_cpu_flush_dcache_range: write a specific data cache range back to memory and invalidate it
//   iob_cpu_invalidate_icache: make the instruction cache see the memory contents (invalidate only)
//
// VexRiscv: the data cache has no standard flush; 0x500F is its custom data
// cache flush + invalidate (flushes entire cache). fence.i only invalidates
// the instruction cache.
// VexRiscv ignores start/len arguments for range flush as it flushes the entire cache.
//
// For assembly (.S): include "iob_cpu.s" instead
#ifndef IOB_CPU_H
#define IOB_CPU_H

// VexRiscv data cache size (used for full cache flush)
#define DCACHE_SIZE (32 * 1024)
#define CACHE_LINE_SIZE 64

#include <stdint.h>
#include <stddef.h>

static inline void iob_cpu_flush_dcache(void) {
  for (unsigned int i = 0; i < 10; i++)
    __asm__ volatile("nop");
  __asm__ volatile(".word 0x500F" ::: "memory");
}

// Range flush - VexRiscv ignores range and flushes entire cache
static inline void iob_cpu_flush_dcache_range(void *start, size_t len) {
  (void)start;
  (void)len;
  iob_cpu_flush_dcache();
}

static inline void iob_cpu_invalidate_icache(void) {
  __asm__ volatile("fence.i" ::: "memory");
}

#endif