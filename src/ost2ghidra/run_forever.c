// run_forever.c: A simple program that demonstrates what deep call stack looks
// like
#include <stdio.h>

#ifdef _WIN32

#include <windows.h>
#define SLEEP(seconds) Sleep(seconds)

#else

#include <time.h>
#define SLEEP(msecs)                                                           \
  ({                                                                           \
    struct timespec ts;                                                        \
    ts.tv_sec = msecs / 1000;                                                  \
    ts.tv_nsec = (msecs % 1000) * 1000 * 1000;                                 \
    nanosleep(&ts, NULL);                                                      \
  })

#endif

unsigned int count_down(unsigned int count) {
  unsigned int current = count - 1;
  printf("%d\n", current);
  SLEEP(1000);

  if (current == 0) {
    printf("Done\n");
    while (1) {
      SLEEP(1);
    }
  }

  return count_down(current);
}

int main() {
  unsigned int count = 20;

  printf("Starting %d second countdown...\n", count);
  count_down(count);
  return 0;
}
