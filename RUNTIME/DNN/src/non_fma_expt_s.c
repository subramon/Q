// gcc -O4 -lm non_fma_expt_s.c  # produces executable a.out
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <inttypes.h>

#define N 1048576

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
  float *A = malloc(N * sizeof(float));
  float *B = malloc(N * sizeof(float));
  float *C = malloc(N * sizeof(float));
  float *D = malloc(N * sizeof(float));
  for ( int i = 0; i < N; i++ ) { A[i] = i; }
  for ( int i = 0; i < N; i++ ) { B[i] = i*2; }
  for ( int i = 0; i < N; i++ ) { C[i] = i*4; }

  printf("starting\n");
  uint64_t t_end = 0, t_start = RDTSC();
  for ( int i = 0; i < N; i++ ) { 
    float a = A[i];
    float b = B[i];
    float c = C[i];

    float d = ( a * b ) + c;
    D[i] = d;
  }
  t_end = RDTSC();
  fprintf(stdout, "cycles  = %" PRIu64 "\n", ( t_end - t_start ) );

  for ( int i = 0; i < 8; i++ ) { 
    printf("A = %lf \t", A[i]);
    printf("B = %lf \t", B[i]);
    printf("C = %lf \t", C[i]);
    printf("D = %lf \n", D[i]);
  }

  return 0;
}
