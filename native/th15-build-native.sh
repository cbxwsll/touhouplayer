#!/bin/bash
# Native (Linux/SDL3) build for the TH15 eagler web runtime on ARM64.
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"
WS="$ROOT/.."
COMMON="$WS/third_party/eagler-common"
OUT="$ROOT/artifacts/native"
mkdir -p "$OUT"

CXXFLAGS="-O2 -g0 -fno-strict-aliasing -ffp-contract=off -std=c++17 -fno-exceptions -fno-rtti \
-DTH_SDL3=1 -DTH_NATIVE_PLATFORM=1 -DTH_ENABLE_THCRAP=1 -DTH_ENABLE_THPRAC=1 -DIMGUI_DISABLE_WIN32_FUNCTIONS \
-I$WS/portable/sdl -I$ROOT/cpp/native -I$ROOT/cpp/sdl -I$ROOT/cpp/third_party/imgui -I$COMMON/include -I$WS \
-I/usr/include/freetype2"

export CXXFLAGS ROOT WS COMMON OUT

compile_one() {
    src="$1"
    obj="$OUT/$(echo "$src" | sed 's#[/ ]#_#g').o"
    g++ $CXXFLAGS -c "$src" -o "$obj" || { echo "FAIL: $src"; exit 1; }
}
export -f compile_one

{
  find cpp/game cpp/sdl -name '*.cpp'
  echo "$WS/portable/sdl/Renderer.cpp"
  echo "cpp/native/main.cpp"
  echo "cpp/native/raf_state.cpp"
  for f in imgui imgui_draw imgui_tables imgui_widgets imgui_freetype; do
    echo "cpp/third_party/imgui/$f.cpp"
  done
} | xargs -P "$(nproc)" -I{} bash -c 'compile_one "$@"' _ {}

[ $? -ne 0 ] && { echo BUILD FAILED; exit 1; }
g++ "$OUT"/*.o -o "$OUT/th15" -lSDL3 -lSDL3_ttf -lGLESv2 -lfreetype -lm || { echo LINK FAILED; exit 1; }
echo "OK: $OUT/th15"
