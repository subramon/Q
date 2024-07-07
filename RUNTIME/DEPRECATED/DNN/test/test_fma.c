// gcc -I../inc/ -mavx2 -mfma -DAVX avx.c test_fma.c  ----- produces a executable

#include <immintrin.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <inttypes.h>
#include "avx.h"

#define REGISTER_WIDTH_IN_BITS 512
#define BITS_IN_BYTE      8

static uint64_t
RDTSC(
    void
    )
{
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}

int main() {
  int status = 0;
  int32_t nI = 35;
 size_t alignment = REGISTER_WIDTH_IN_BITS / BITS_IN_BYTE;
  float *A = memalign(alignment, nI * sizeof(float));
  float B = 10;
  float *C = memalign(alignment, nI * sizeof(float));
  float *D = memalign(alignment, nI * sizeof(float));
  for ( int i = 0; i < nI; i++ ) { A[i] = i; }
  for ( int i = 0; i < nI; i++ ) { C[i] = i*4; }

  uint64_t t_end = 0, t_start = RDTSC();
  status = va_times_sb_plus_vc(A, B, C, D, nI);
  t_end = RDTSC();
  // fprintf(stdout, "cycles  = %" PRIu64 "\n", ( t_end - t_start ) );

  for ( int i = 0; i < nI; i++ ) { 
    printf("A = %lf \t", A[i]);
    printf("B = %lf \t", B);
    printf("C = %lf \t", C[i]);
    printf("D = %lf \n", D[i]);
  }


  return status;
}
