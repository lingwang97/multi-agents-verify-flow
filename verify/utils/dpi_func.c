#include <time.h>
// Verilator compiles this file as C++ and its generated DPI-C wrappers expect
// the unmangled C symbol; VCS compiles it as C, where this is a no-op.
#ifdef __cplusplus
extern "C"
#endif
int wallclock() {
   time_t t;
   t = time(NULL);

   return t/3600;
}

