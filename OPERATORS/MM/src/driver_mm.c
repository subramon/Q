/*
 *gcc -O4 -Wall driver_mm.c matrix_multiply.c -fopenmp -lgomp -lm -o mm -I ../../UTILS/inc/
 */
#include "q_incs.h"
#include "matrix_multiply.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  uint64_t t_start, t_simple, t_fast, t_alt;
  /* multiply X(m by k) x Y(k x n ) = Z(m x n) */
  int k, m, n;
  double **X = NULL, **Y = NULL, **Z = NULL, **chk_Z = NULL, **alt_Z = NULL;

  if ( argc != 4 ) { go_BYE(-1); }
  m = atoi(argv[1]); if ( m < 2 ) { go_BYE(-1); }
  k = atoi(argv[2]); if ( k < 2 ) { go_BYE(-1); }
  n = atoi(argv[3]); if ( n < 1 ) { go_BYE(-1); }

  status = alloc_matrix(m, k, &X); cBYE(status);
  status = alloc_matrix(k, n, &Y); cBYE(status);
  status = alloc_matrix(m, n, &Z); cBYE(status);
  status = alloc_matrix(m, n, &alt_Z); cBYE(status);
  status = alloc_matrix(m, n, &chk_Z); cBYE(status);

  status = set_matrix(X, m, k); cBYE(status);
  status = set_matrix(Y, k, n); cBYE(status);

  t_start = RDTSC();
  status = mm_simple(X, Y, chk_Z, m, k, n); cBYE(status);
  t_simple = RDTSC() - t_start; printf("simple time = %llu \n", t_simple);
  //t_start = RDTSC();
  //status = mm_fast_1d_alt(X, Y, alt_Z, m, k, n); cBYE(status);
  //t_alt = RDTSC() - t_start; printf("alt fast time = %llu \n", t_alt);
  t_start = RDTSC();
  //status = mm_fast_1d(X, Y, Z, m, k, n); cBYE(status);
  status = mm_fast_many_cols(X, Y, Z, m, k, n); cBYE(status);
  t_fast = RDTSC() - t_start; printf("fast  time = %llu \n", t_fast);
  printf("speedup = %lf \n", (double)t_simple/(double)t_fast);
  //printf("alt speedup = %lf \n", (double)t_simple/(double)t_alt);

  double threshold = 0.00001;
#ifdef DEBUG
  print_matrix(X, m, k);
  print_matrix(Y, k, n);
  printf("what the matrix should be\n");
  print_matrix(chk_Z, m , n);
  printf("what it is\n");
  print_matrix(Z, m , n);
#endif

  if ( cmp_matrix(Z, chk_Z, m, n, threshold) || cmp_matrix(alt_Z, chk_Z, m, n, threshold) ) { 
    printf("SUCCESS\n"); 
  } 
  else { 
    printf("FAILURE\n"); go_BYE(-1);  
  }
  free_matrix(X, k);
  free_matrix(Y, n);
  free_matrix(Z, n);
  free_matrix(chk_Z, n);
BYE:
  return status;
}
