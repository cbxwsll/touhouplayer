# aarch64 (Raspberry Pi OS 64-bit) native-port fixes

Bug class: code written for wasm32 assumes 32-bit pointers / specific struct
layouts. On aarch64 these corrupt heap pointers. Symptom signature: a crash
pointer that equals a valid heap pointer **+/- 4 GiB** (zero-extended u32) or
with its **low 32 bits preserved and high 32 bits wrong** (u32 truncation).

## TH10 (th10_web) — 4 fixes, segfault on stage load

1. `cpp/game/ArchiveLifecycle.cpp` `parse_index`: computed the index block as
   `elements*16+4`, assuming a 16-byte `ArchiveEntry` (real size: 24 on
   aarch64). Replaced with a proper header + `ArchiveEntry[n]` allocation;
   `release_entries` mirrors the header arithmetic.
2. `cpp/game/AnmResources.cpp`: `scripts` (`AnmInstruction**`) allocated as
   `count*4` — must be `count*sizeof(AnmInstruction*)`.
3. `cpp/game/SoundResources.cpp` (two sites): `buffers` (`void**`) allocated
   as `count*4` — must be `count*sizeof(void*)`.

## TH11 (th11_web) — 3 fixes, segfault on first ECL backward jump

1. `cpp/game/EclInterpreter.cpp` `advance(const EclInstruction*, u32)`:
   ECL jump offsets are **signed**; a backward jump passes a negative i32,
   which converts to a huge u32 (e.g. -80 -> 0xFFFFFFB0). On wasm32, adding
   that to a 32-bit pointer wraps back to the right address; on aarch64 it
   zero-extends and adds ~4 GiB. Fix: take the offset as `i32` and pass
   `instruction->argument<i32>()` at the Jump/JumpIfZero/JumpIfNonzero site.
2. `Op::Return` / `call_subroutine` (`EclOwner.cpp`): the caller return
   address was stored on the ECL stack as a single u32 (truncated). Now
   pushed as two u32 slots (lo, hi) and recombined as
   `lo | (uintptr_t(hi)<<32)` on Return.
3. `call_subroutine` argument write offset: `old_top+8` -> `old_top+12`
   (stack frame layout with the two-slot return address).

## Debugging notes (Pi OS aarch64)

- Pi OS uses 39-bit virtual addresses: ASan's primary64 allocator cannot
  initialise (kSpaceBeg 0x500000000000 out of range). Use gdb batch scripts
  instead.
- Rebuild gotcha: after editing headers/sources, verify .o timestamps —
  an empty build log with stale binary means the build never ran.
- Only one kmsdrm process at a time; detached jobs need a pty
  (`setsid script -q -f -c 'SDL_VIDEODRIVER=kmsdrm ...' /tmp/log`).
- Stability convention: `SDL_VIDEODRIVER=kmsdrm timeout -k 5 45 ./thXXe`;
  exit 137/124 = survived the window, 139 = segfault.

Verified 2026-10-21 on Raspberry Pi 4B: th10 and th11 both stable through
45 s runs including demo play, with zh-hans thcrap packs and OGG BGM.
