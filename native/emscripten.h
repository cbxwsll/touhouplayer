#pragma once
// Native (Linux/SDL) shim for the subset of Emscripten APIs used by the
// eagler web runtimes. EM_JS bodies are browser JavaScript; natively the
// host services they call do not exist, so every stub returns a zero value.
#include <SDL3/SDL.h>

static inline double emscripten_get_now() { return (double)SDL_GetTicksNS() / 1.0e6; }

// Deferred call: single-player never schedules network recovery, so running
// it inline is faithful enough for the native port.
static inline void emscripten_async_call(void (*func)(void *), void *arg, int millis)
{
    (void)millis;
    func(arg);
}

#define EM_JS(ret, name, args, ...) ret name args { return ret(); }
#define EM_ASM(...)
#define EM_ASM_INT(...) 0
#define EMSCRIPTEN_KEEPALIVE
#define EM_BOOL bool
#ifndef EM_TRUE
#define EM_TRUE 1
#define EM_FALSE 0
#endif
