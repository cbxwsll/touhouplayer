#pragma once
// emscripten_request_animation_frame_loop replacement: the native main loop
// stores the callback and drives it manually (vsync comes from
// SDL_GL_SetSwapInterval(1) in Renderer::initialize).
#include "emscripten.h"

typedef EM_BOOL (*th_raf_callback)(double, void *);

extern th_raf_callback th_raf_cb;
extern void *th_raf_arg;

static inline void emscripten_request_animation_frame_loop(th_raf_callback cb, void *arg)
{
    th_raf_cb = cb;
    th_raf_arg = arg;
}
