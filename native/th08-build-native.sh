#!/bin/bash
# Native ARM64 build for TH08 (eagler branch) SDL runtime.
set -e
cd "$(dirname "$0")/../../.."
ROOT=th08_web
OUT=$ROOT/artifacts/native
mkdir -p "$OUT"
export CXXFLAGS="-O2 -g0 -fno-strict-aliasing -ffp-contract=off -std=c++17 -fno-exceptions -fno-rtti -DTH_SDL3=1 -DTH_NATIVE_PLATFORM=1 -DTH_ENABLE_THCRAP=1 -DIMGUI_DISABLE_WIN32_FUNCTIONS -I$ROOT/cpp/native -Iportable/sdl -I$ROOT/cpp/third_party/imgui -Ithird_party/eagler-common/include -I/usr/include/freetype2"
export OUT
compile_one() {
  f="$1"; o="$OUT/$(echo "$f" | tr / _).o"
  [ -f "$o" ] && return 0
  g++ $CXXFLAGS -c "$f" -o "$o"
}
export -f compile_one
SRC=$(ls $ROOT/cpp/game/*.cpp | grep -v -E "RuntimeExports.cpp|LocalizationStub.cpp")
SRC="$SRC $(ls $ROOT/cpp/platform/*.cpp)"
SRC="$SRC $(ls $ROOT/cpp/sdl/*.cpp)"
SRC="$SRC $ROOT/cpp/native/main.cpp $ROOT/cpp/native/raf_state.cpp"
SRC="$SRC $ROOT/cpp/third_party/imgui/imgui.cpp $ROOT/cpp/third_party/imgui/imgui_draw.cpp $ROOT/cpp/third_party/imgui/imgui_freetype.cpp $ROOT/cpp/third_party/imgui/imgui_tables.cpp $ROOT/cpp/third_party/imgui/imgui_widgets.cpp"
SRC="$SRC portable/sdl/Renderer.cpp"
NPROC=$(nproc)
echo "Compiling $(echo $SRC | wc -w) C++ units with -j$NPROC ..."
FAIL=0
printf "%s\n" $SRC | xargs -P $NPROC -I{} bash -c 'compile_one "$@"' _ {} || FAIL=1
gcc -O2 -std=gnu11 -fgnu89-inline -DSOFTFLOAT_FAST_INT64 -DINLINE_LEVEL=5 -c $ROOT/cpp/third_party/softfloat.c -o $OUT/softfloat.o
if [ $FAIL -ne 0 ]; then echo "COMPILE_FAILED"; exit 1; fi
echo "Linking ..."
g++ $OUT/*.o -o $OUT/th08 -lSDL3 -lSDL3_ttf -lGLESv2 -lfreetype -lm
echo "NATIVE_BUILD_OK $OUT/th08"
