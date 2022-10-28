#include "q_incs.h"
#include <strings.h>
#include <math.h>
#include "where_I4_BL.h"

char g_data_dir_root[128];
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int nA = 128; 
  // nA shoudl be multiple of 8 for exp_nC to be correct; also malloc
  int32_t *A = NULL;
  bool *B = NULL; 
  int32_t *C = NULL;
  uint64_t exp_nC = 0, nC = 0;

  //----------------------------
  A = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(A);
  for ( int i = 0; i < nA; i++ ) {
    A[i] = ( i + 1 ) * 10;
  }  

  //----------------------------
  B = malloc(nA * sizeof(bool));
  return_if_malloc_failed(B);

  //----------------------------
  C = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(C);

  for ( int j = 0; j < nA; j++ ) { 
    if ( ( j % 3 ) == 0 ) { 
      B[j] = true;
      exp_nC++;
    }
    else {
      B[j] = false;
    }
  }
  uint64_t aidx= 0;
  status = where_I4_BL(A, B, &aidx, nA, C, nA, &nC); cBYE(status);
  printf("Size of Output is %d\n", (int)nC);

  if ( nC != exp_nC ) { 
    printf("Length Mismatch\n"); printf("C: ERROR\n"); go_BYE(-1); 
  }
  int cidx = 0;
  for ( int aidx = 0; aidx < nA; aidx++ ) { 
    if ( B[aidx] ) { 
      if ( C[cidx] != A[aidx] ) { go_BYE(-1); } 
      cidx++;
    }
  }
  printf("C: SUCCESS\n");
BYE:
  free_if_non_null(A);
  free_if_non_null(B);
  free_if_non_null(C);
  return status;
}
