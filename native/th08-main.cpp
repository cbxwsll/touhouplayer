// Native entry point for the TH08 (eagler branch) SDL runtime.
// Mirrors what the browser shell does: open -> prepare assets -> initialize
// -> start loop, then pump frames until the game exits.
#include <SDL3/SDL.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "emscripten/html5.h"

namespace th08 { void sdl_audio_pump(); }

extern "C" {
void *sdl_game_open(unsigned milliseconds);
void sdl_touch_display(unsigned hitbox);
unsigned sdl_prepare_total();
int sdl_prepare_next();
bool sdl_game_initialize();
void sdl_loop_start();
}

int main(int argc, char **argv)
{
    (void)argc; (void)argv;
    if (!sdl_game_open(0)) { std::fprintf(stderr, "th08: sdl_game_open failed\n"); return 1; }
    const unsigned total = sdl_prepare_total();
    for (;;) {
        int r = sdl_prepare_next();
        if (r == 0) break;
        if (r < 0) { std::fprintf(stderr, "th08: asset prepare failed\n"); return 1; }
        if ((unsigned)r % 20 == 0) std::fprintf(stderr, "th08: loading %u/%u\r", (unsigned)r, total);
    }
    if (!sdl_game_initialize()) { std::fprintf(stderr, "th08: initialize failed\n"); return 1; }
    { const char *hb = std::getenv("TH_HITBOX"); if (hb && !std::strcmp(hb, "always")) sdl_touch_display(1); }
    std::fprintf(stderr, "th08: running\n");
    sdl_loop_start();
    while (th_raf_cb) {
        if (!th_raf_cb(emscripten_get_now(), th_raf_arg)) break;
    }
    return 0;
}
