# Native port kits (ARM64 Linux / SDL3)

Shared shim (`emscripten.h`, `emscripten/html5.h`, `raf_state.cpp`) plus a
per-game `main.cpp` entry point and `build-native.sh`. Copy the shim into
`<repo>/<thXX_web>/cpp/native/`, the game main.cpp beside it, and the build
script into `<repo>/<thXX_web>/scripts/`, then run on the Pi.

Common fixes applied to the web-only sources before building natively:
- `static_assert(sizeof(...))` layout guards assume wasm32; prefixed with
  `sizeof(void*)!=4||` (repo's own convention) so 64-bit builds pass.
- Mesa treats `packed` as reserved in GLSL -> renamed in ResampleShader.hpp.
- softfloat.c (th08/th10): delete the two self-define lines for
  shiftRightJam256M/shiftRightJam128Extra, compile with -fgnu89-inline.
- imgui has no imgui_demo.cpp in these trees; build imgui_freetype instead.

Runtime layout on the Pi (symlinks): /game -> ~/games/th08, /th09.dat,
/th11.dat, /th15.dat per game, /save -> ~/games/save (shared, distinct
filenames), /savesth08, /savesth10, /bgm-ogg -> ~/games/bgm-ogg,
/music -> ~/games/th11/music, /fonts -> ~/games/fonts (msgothic.ttc,
cp932.bin, blend.bin, codepages.bin generated locally).

Hitbox: TH_HITBOX=off|focus|always via launcher; th08 sdl_touch_display,
th09 th09_always_hitbox, th10 application_touch_display, th11
th11_always_hitbox, th15 via patches/th15-hitbox.patch (env checked in
PlayerAnmHost::focus_begin).

Game .dat files and music are ZUN's copyrighted assets and are NOT included;
supply your own copies.