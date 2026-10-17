// Native entry point for the TH10 (eagler branch) SDL runtime.
#include <SDL3/SDL.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "emscripten/html5.h"

extern "C" {
void *sdl_game_open(unsigned chinese, unsigned seed);
void sdl_loop_start(void *app);
void application_touch_display(void *app, int hitbox);
}

int main(int argc, char **argv)
{
    (void)argc; (void)argv;
    void *app = sdl_game_open(0, 0);
    if (!app) { std::fprintf(stderr, "th10: sdl_game_open failed\n"); return 1; }
    { const char *hb = std::getenv("TH_HITBOX"); if (hb && !std::strcmp(hb, "always")) application_touch_display(app, 1); }
    std::fprintf(stderr, "th10: running\n");
    sdl_loop_start(app);
    while (th_raf_cb) {
        if (!th_raf_cb(emscripten_get_now(), th_raf_arg)) break;
    }
    return 0;
}
