// Native entry point for the TH09 (eagler branch) SDL runtime.
// Sequence mirrors the browser shell: prepare loading -> open -> start loop,
// then pump frames until the game exits.
#include <SDL3/SDL.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "emscripten/html5.h"

extern "C" {
unsigned th09_prepare_loading();
unsigned th09_game_open(unsigned seed);
void th09_loop_start();
void th09_always_hitbox(unsigned on);
}

int main(int argc, char **argv)
{
    (void)argc; (void)argv;
    if (!th09_prepare_loading()) { std::fprintf(stderr, "th09: prepare_loading failed\n"); return 1; }
    if (!th09_game_open(0)) { std::fprintf(stderr, "th09: game_open failed\n"); return 1; }
    { const char *hb = std::getenv("TH_HITBOX"); if (hb && !std::strcmp(hb, "always")) th09_always_hitbox(1); }
    std::fprintf(stderr, "th09: running\n");
    th09_loop_start();
    while (th_raf_cb) {
        if (!th_raf_cb(emscripten_get_now(), th_raf_arg)) break;
    }
    return 0;
}
