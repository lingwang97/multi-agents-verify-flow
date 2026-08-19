#include <time.h>
int wallclock() {
   time_t t;
   t = time(NULL);
   
   return t/3600;
}

