#ifndef OPENSLIDE_SETJMP_H
#define OPENSLIDE_SETJMP_H

/* gcc extension */
#include_next <setjmp.h>

/* On 64-bit Windows, MinGW passes a frame pointer to _setjmp so longjmp
 * can do a SEH unwind.  This seems to work when the caller is also built
 * with MinGW, but sometimes crashes with STATUS_BAD_STACK when the
 * caller is built with MSVC; it appears that this is a longstanding
 * MinGW issue.  In 64-bit builds, override setjmp() to pass a NULL frame
 * pointer to skip the SEH unwind.  Our uses of setjmp/longjmp are all in
 * libpng/libjpeg error handling, which isn't expecting to do any cleanup
 * in intermediate stack frames, so this should be fine.
 * https://github.com/openslide/openslide-bin/issues/47
 */
#if defined _WIN32
#undef setjmp
#define setjmp(buf) _setjmp(buf, NULL)
#endif

#endif
