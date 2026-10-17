#!/bin/bash
# Native (Linux/SDL3) build for the TH09 eagler web runtime on ARM64.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"
WS="$ROOT/.."
COMMON="$WS/third_party/eagler-common"
OUT="$ROOT/artifacts/native"
mkdir -p "$OUT"

CXXFLAGS="-O2 -g0 -fno-strict-aliasing -ffp-contract=off -std=c++17 -fno-exceptions -fno-rtti \
-DTH_NATIVE_PLATFORM=1 -DTH_ENABLE_THCRAP=1 -DTH09_DEVELOPMENT_HARNESS=0 \
-I$ROOT/cpp/native -I$ROOT/cpp/sdl -I$ROOT/cpp/multiplayer -I$COMMON/include -I$WS"

export CXXFLAGS ROOT WS COMMON OUT

compile_one() {
    src="$1"
    obj="$OUT/$(echo "$src" | sed 's#[/ ]#_#g').o"
    g++ $CXXFLAGS -c "$src" -o "$obj" || { echo "FAIL: $src"; exit 1; }
}
export -f compile_one

{
  find cpp/game cpp/sdl cpp/multiplayer -name '*.cpp'
  for n in BrowserPeerTransport NetplayCore NetplayProtocol NetplaySession SessionChannel RollbackJournal; do
    echo "$COMMON/src/netplay/$n.cpp"
  done
  echo "$WS/portable/sdl/Renderer.cpp"
  echo "cpp/native/main.cpp"
  echo "cpp/native/raf_state.cpp"
} | xargs -P "$(nproc)" -I{} bash -c 'compile_one "$@"' _ {}

[ $? -ne 0 ] && { echo BUILD FAILED; exit 1; }
g++ "$OUT"/*.o -o "$OUT/th09" -lSDL3 -lSDL3_ttf -lGLESv2 -lm || { echo LINK FAILED; exit 1; }
echo "OK: $OUT/th09"
