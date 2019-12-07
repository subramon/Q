// gcc -mavx2 -mfma -S -c  x.c   # to produce assembler
// gcc -mavx2 -mfma -O4 x.c -lm  # produces executable a.out
#include "q_incs.h"

#define N 35
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

static int
a_times_b_plus_c(
    float *A,
    float *B,
    float *C,
    float *D,
    int32_t nI
    )
{
  int status = 0;

  int bits_per_byte = 8;
  int stride = REG_WIDTH_IN_BITS / (bits_per_byte * sizeof(float));
  int nI_rem = ( nI % stride );

  // loop with fma
  for ( int i = 0; i < (nI-nI_rem); i += stride ) {
    __m256 a = _mm256_load_ps(A+i);
    __m256 b = _mm256_load_ps(B+i);
    __m256 c = _mm256_load_ps(C+i);

    __m256 d = _mm256_fmadd_ps(a, b, c);
    _mm256_store_ps(D+i, d);
  }

  // loop without fma
  for ( int i = (nI-nI_rem); i < nI; i++ ) {
    D[i] = C[i] + (A[i] * B[i]);
  }
BYE:
  return status;
}


int main() {
  float *A = memalign(32, N * sizeof(float));
  float *B = memalign(32, N * sizeof(float));
  float *C = memalign(32, N * sizeof(float));
  float *D = memalign(32, N * sizeof(float));
  for ( int i = 0; i < N; i++ ) { A[i] = i; }
  for ( int i = 0; i < N; i++ ) { B[i] = i*2; }
  for ( int i = 0; i < N; i++ ) { C[i] = i*4; }

  printf("starting\n");
  uint64_t t_end = 0, t_start = RDTSC();
  int status = a_times_b_plus_c(A, B, C, D, N);
  t_end = RDTSC();
  fprintf(stdout, "cycles  = %" PRIu64 "\n", ( t_end - t_start ) );

  for ( int i = 0; i < N; i++ ) { 
    printf("A = %lf \t", A[i]);
    printf("B = %lf \t", B[i]);
    printf("C = %lf \t", C[i]);
    printf("D = %lf \n", D[i]);
  }


  return status;
}

/* following gives basic assembler
// gcc -mavx2 -mfma -S x.c   -lm - x 
#include <immintrin.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define N 1048576

int main() {
  float *A;
  float *B;
  float *C;
  float *D;
  int register_width;
  int num_words_in_reg;
  for ( int i = 0; i < N/num_words_in_reg; i += num_words_in_reg ) { 
    __m256 a = _mm256_load_ps(A+i);
    __m256 b = _mm256_load_ps(B+i);
    __m256 c = _mm256_load_ps(C+i);
    __m256 d = _mm256_fmadd_ps(a, b, c);
    _mm256_store_ps(D+i, d);
  }
  return 0;
}
*/
