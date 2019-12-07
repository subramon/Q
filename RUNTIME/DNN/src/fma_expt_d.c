// gcc -mavx2 -mfma -S x.c   -lm - x  -I../../../UTILS/inc/
#include "q_incs.h"
#define N 1048576

int main() {
  double *A = memalign(256, N * sizeof(double));
  double *B = memalign(256, N * sizeof(double));
  double *C = memalign(256, N * sizeof(double));
  double *D = memalign(256, N * sizeof(double));
  for ( int i = 0; i < N; i++ ) { A[i] = i; }
  for ( int i = 0; i < N; i++ ) { B[i] = i*2; }
  for ( int i = 0; i < N; i++ ) { C[i] = i*4; }

  printf("starting\n");
  for ( int i = 0; i < 1; i++ ) { 
    /*
    __m256d a = _mm256_setr_pd(A[i], A[i+1], A[i+2], A[i+3]);
    __m256d b = _mm256_setr_pd(B[i], B[i+1], B[i+2], B[i+3]);
    __m256d c = _mm256_setr_pd(C[i], C[i+1], C[i+2], C[i+3]);
    */
    __m256d a = _mm256_load_pd(A+i);
    __m256d b = _mm256_load_pd(B+i);
    __m256d c = _mm256_load_pd(C+i);

    /* Display the elements of the input vector a */
    double * aptr = (double*)&a;
    printf("A: %lf %lf %lf %lf\n", aptr[0], aptr[1], aptr[2], aptr[3]);
    double * bptr = (double*)&b;
    printf("B: %lf %lf %lf %lf\n", bptr[0], bptr[1], bptr[2], bptr[3]);
    double * cptr = (double*)&c;
    printf("C: %lf %lf %lf %lf\n", cptr[0], cptr[1], cptr[2], cptr[3]);

    __m256d d = _mm256_fmadd_pd(a, b, c);
    double * dptr = (double*)&d;
    printf("D: %lf %lf %lf %lf\n", dptr[0], dptr[1], dptr[2], dptr[3]);
    // memcpy(D, dptr, 256);
    printf("storing..\n");
    _mm256_store_pd(D, d);
    printf("stored\n");
  }

  for ( int i = 0; i < 4; i++ ) { 
    printf("A = %f \t", A[i]);
    printf("B = %f \t", B[i]);
    printf("C = %f \t", C[i]);
    printf("D = %f \n", D[i]);
  }


  return 0;
}


