#include "q_incs.h"
#include "_qsort_asc_val_F8_idx_I4.h"
#include "_qsort_dsc_val_I8_idx_I2.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int N  = 1048576+3;
  double *Y = NULL; uint64_t *Y2 = NULL; 
  int32_t *idx = NULL; int16_t *idx2 = NULL;
  //--------------------------------
  Y = malloc(N * sizeof(double)); return_if_malloc_failed(Y);
  for ( int i = 0; i < N; i++ ) { Y[i] = N+1-i; }
  //--------------------------------
  idx = malloc(N * sizeof(int32_t)); return_if_malloc_failed(idx);
  for ( int i = 0; i < N; i++ ) { idx[i] = i; }
  //--------------------------------
  qsort_asc_val_F8_idx_I4(idx, Y, N);
  for ( int i = 0; i < N; i++, i++ ) { 
    if ( idx[i] != (N-i-1) ) {  
      fprintf(stdout, "C: FAILURE\n"); go_BYE(-1); }
  }
  for ( int i = 1; i < N; i++, i++ ) { 
    if ( Y[i] < Y[i-1] ) { fprintf(stdout, "C: FAILURE\n"); go_BYE(-1); }
  }  
  //--------------------------------
  int N2 = 32767;;
  Y2 = malloc(N2 * sizeof(uint64_t)); return_if_malloc_failed(Y2);
  for ( int i = 0; i < N2; i++ ) { Y2[i] = i+1; }
  //--------------------------------
  idx2 = malloc(N2 * sizeof(int16_t)); return_if_malloc_failed(idx2);
  for ( int i = 0; i < N2; i++ ) { idx2[i] = i; }
  //--------------------------------
  qsort_dsc_val_I8_idx_I2(idx2, Y2, N2);
  for ( int i = 0; i < N2; i++, i++ ) { 
    if ( idx2[i] != N2-i-1 ) { 
      fprintf(stdout, "C: FAILURE\n"); go_BYE(-1); }
  }
  for ( int i = 1; i < N2; i++, i++ ) { 
    if ( Y2[i] > Y2[i-1] ) { fprintf(stdout, "C: FAILURE\n"); go_BYE(-1); }
  }  
  fprintf(stdout, "C: SUCCESS\n");
  //--------------------------------
BYE:
  free_if_non_null(idx);
  free_if_non_null(Y);
  free_if_non_null(idx2);
  free_if_non_null(Y2);
  return status;
}
