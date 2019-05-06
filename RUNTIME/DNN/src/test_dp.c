// gcc -I../inc/ -mavx2 -mfma -DAVX avx.c test_dp.c  ----- produces a executable

#include <immintrin.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <inttypes.h>
#include "avx.h"

#define REG_WIDTH_IN_BITS 256

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
  float *A = memalign(32, nI * sizeof(float));
  float *B = memalign(32, nI * sizeof(float));
  float sum = 0;
  for ( int i = 0; i < nI; i++ ) { A[i] = i; }
  for ( int i = 0; i < nI; i++ ) { B[i] = i*4; }

  uint64_t t_end = 0, t_start = RDTSC();
  status = a_dot_b(A, B, &sum, nI);
  t_end = RDTSC();
  fprintf(stdout, "cycles  = %" PRIu64 "\n", ( t_end - t_start ) );

  for ( int i = 0; i < nI; i++ ) {
    printf("A = %lf \t", A[i]);
    printf("B = %lf \t", B[i]);
    printf("Ai*Bi = %lf \t", A[i]*B[i]);
  }
  printf("a_dot_b = %f", sum);


  return status;
}
