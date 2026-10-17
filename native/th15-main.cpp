// Native entry point for the TH15 (eagler branch) SDL runtime.
// TH_HITBOX=always is handled inside PlayerAnmHost (focus indicator forced on).
#include <SDL3/SDL.h>
#include <cstdio>
#include <cstring>
#include "emscripten/html5.h"

extern "C" {
int th15_prepare_loading();
int th15_initialize();
void th15_loop_start();
}

int main(int argc, char **argv)
{
    (void)argc; (void)argv;
    if (!th15_prepare_loading()) { std::fprintf(stderr, "th15: prepare_loading failed\n"); return 1; }
    if (!th15_initialize()) { std::fprintf(stderr, "th15: initialize failed\n"); return 1; }
    std::fprintf(stderr, "th15: running\n");
    th15_loop_start();
    while (th_raf_cb) {
        if (!th_raf_cb(emscripten_get_now(), th_raf_arg)) break;
    }
    return 0;
}
