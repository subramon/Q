#include "q_incs.h"
#ifdef AVX
#include <immintrin.h> // for AVX
#include <smmintrin.h> // for AVX
#endif
#include "avx.h"

#if defined(__GNUC__)
#define PORTABLE_ALIGN16 __attribute__((aligned(16)))
#else
#define PORTABLE_ALIGN16 __declspec(align(16))
#endif
#define REG_WIDTH_IN_BITS 256
#define BITS_PER_BYTE     8

int va_times_sb_plus_vc(
    float *A,
    float sB,
    float *C,
    float *D,
    int32_t nI
    )
{
  int status = 0;
  if ( A == NULL ) { go_BYE(-1); }
  if ( C == NULL ) { go_BYE(-1); }
  if ( D == NULL ) { go_BYE(-1); }
  if ( nI <= 0   ) { go_BYE(-1); }

#ifdef AVX

  int stride = REG_WIDTH_IN_BITS / (BITS_PER_BYTE * sizeof(float));
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

int va_dot_vb(
    float *A,
    float *B,
    float *C,
    int32_t nI
    )
{
  int status = 0;
  if ( A == NULL ) { go_BYE(-1); }
  if ( B == NULL ) { go_BYE(-1); }
  if ( C == NULL ) { go_BYE(-1); }
  if ( nI <= 0   ) { go_BYE(-1); }
  float sum = 0;
#ifdef AVX
  int stride = REG_WIDTH_IN_BITS / (BITS_PER_BYTE * sizeof(float));
  int nI_rem = ( nI % stride );

  __m256 num1, num2, num3, num4;

  float PORTABLE_ALIGN16 tmpres[stride];
  num4 = _mm256_setzero_ps();  //sets sum to zero


  for ( i = 0; i < n; i += stride) {

    //loads array a into num1  num1= a[7]  a[6] ... a[1]  a[0]
    num1 = _mm256_loadu_ps(a+i);   

    //loads array b into num2  num2= b[7]  b[6] ... b[1]  b[0]
    num2 = _mm256_loadu_ps(b+i);   

    // performs multiplication   
    // num3 = a[7]*b[7]  a[6]*b[6]  ... a[1]*b[1]  a[0]*b[0]
    num3 = _mm256_mul_ps(num1, num2); 

    //horizontal addition by converting to scalars
    _mm256_store_ps(tmpres, num3);
    // accumulate in sum
    sum += tmpres[0] + tmpres[1] + tmpres[2] + tmpres[3] + 
             tmpres[4] + tmpres[5] + tmpres[6] + tmpres[7];
  }
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

