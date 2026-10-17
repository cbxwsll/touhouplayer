// Native entry point for the TH11 (eagler branch) SDL runtime.
#include <SDL3/SDL.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "emscripten/html5.h"

extern "C" {
int th11_initialize();
int th11_prepare_loading();
void th11_loop_start();
void th11_always_hitbox(unsigned on);
}

int main(int argc, char **argv)
{
    (void)argc; (void)argv;
    if (!th11_initialize()) { std::fprintf(stderr, "th11: initialize failed\n"); return 1; }
    if (!th11_prepare_loading()) { std::fprintf(stderr, "th11: prepare_loading failed\n"); return 1; }
    { const char *hb = std::getenv("TH_HITBOX"); if (hb && !std::strcmp(hb, "always")) th11_always_hitbox(1); }
    std::fprintf(stderr, "th11: running\n");
    th11_loop_start();
    while (th_raf_cb) {
        if (!th_raf_cb(emscripten_get_now(), th_raf_arg)) break;
    }
    return 0;
}
