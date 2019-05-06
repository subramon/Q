#include <immintrin.h>

#include "avx.h"

#define REG_WIDTH_IN_BITS 256

int a_times_sb_plus_c(
    float *A,
    float sB,
    float *C,
    float *D,
    int32_t nI
    )
{
  int status = 0;

#ifdef AVX

  int bits_per_byte = 8;
  int stride = REG_WIDTH_IN_BITS / (bits_per_byte * sizeof(float));
  int nI_rem = ( nI % stride );

  // loop with fma
  __m256 b = _mm256_setr_ps(sB, sB, sB, sB, sB, sB, sB, sB);
  for ( int i = 0; i < (nI-nI_rem); i += stride ) {
    __m256 a = _mm256_load_ps(A+i);
    __m256 c = _mm256_load_ps(C+i);
    __m256 d = _mm256_fmadd_ps(a, b, c);
    _mm256_store_ps(D+i, d);
#ifdef COUNT
    num_f_flops += 2*stride;
#endif
  }

  // loop without fma
  for ( int i = (nI-nI_rem); i < nI; i++ ) {
    D[i] = C[i] + ( A[i] * sB );
#ifdef COUNT
    num_f_flops += 2;
#endif
  }

#else

#pragma omp simd
  for ( int i = 0; i < nI; i++ ) {  // for batch size
    D[i] = C[i] + ( A[i] * sB );
#ifdef COUNT
    num_f_flops += 2;
#endif
  }

#endif

BYE:
  return status;
}
//===========================================================================

int a_dot_b(
    float *A,
    float *B,
    float *C,
    int32_t nI
    )
{
  int status = 0;
  float sum = 0;
#ifdef AVX
  int bits_per_byte = 8;
  int stride = REG_WIDTH_IN_BITS / (bits_per_byte * sizeof(float));
  int nI_rem = ( nI % stride );

  // loop with avx
  __m256 s = _mm256_setr_ps(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
  for ( int i = 0; i < (nI-nI_rem); i += stride ) {
    __m256 a = _mm256_load_ps(A+i);
    __m256 b = _mm256_load_ps(B+i);
    __m256 d = _mm256_dp_ps(a, b, 0xFF);
    s = _mm256_add_ps(d, s);
  }
  float tmp_prod[8] = {0};
  _mm256_store_ps(tmp_prod, s);
  //printf("%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n", tmp_prod[0], tmp_prod[1], tmp_prod[2], tmp_prod[3], tmp_prod[4], tmp_prod[5], tmp_prod[6], tmp_prod[7]);
  // TODO: update sum properly

  // loop for remaining elements
  for ( int i = (nI-nI_rem); i < nI; i++ ) {
    sum += A[i] * B[i];
#ifdef COUNT
    num_b_flops += 2;
#endif
  }

#else

#pragma omp simd reduction(+:sum)
  for ( int i = 0; i < nI; i++ ) {
    sum += A[i] * B[i];
#ifdef COUNT
    num_b_flops += 2;
#endif
  }
  *C = sum;

#endif

BYE:
  return status;
}

