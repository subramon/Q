#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include "q_macros.h"
#include "_mix_UI8.h"
#include "_rand_file_name.h"

static inline uint64_t RDTSC()
{
  unsigned int hi, lo;
    __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
      return ((uint64_t)hi << 32) | lo;
}
//START_FUNC_DECL
int
rand_file_name(
    char *buf,
    size_t bufsz
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char hex[16] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
               'A', 'B', 'C', 'D', 'E', 'F' };
  if (  bufsz < 31 ) { go_BYE(-1); }
  memset(buf, '\0', bufsz);
  uint64_t t = RDTSC();
  t = mix_UI8(t);
  char ct[8];
  memcpy(ct, &t, 8);
  int bufidx = 0;
  buf[bufidx++] = '_';
  for ( int i = 0; i < 8; i++ ) {  // 8 bytes
    uint8_t c = ct[i];
    uint8_t c1 = c & 15;
    uint8_t c2 = c >> 4;
    buf[bufidx++] = hex[c1];
    buf[bufidx++] = hex[c2];
  }
  buf[bufidx++] = '.';
  buf[bufidx++] = 'b';
  buf[bufidx++] = 'i';
  buf[bufidx++] = 'n';
BYE:
  return status;
}
#ifdef STAND_ALONE
int
main()
{
  char X[32];
  rand_file_name(X, 32);
  fprintf(stderr, "X = %s \n", X);
}
#endif
