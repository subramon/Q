#include "q_incs.h"
#include <strings.h>
#include <math.h>
#include "_where_I4.h"

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
  uint64_t *B = NULL; 
  int32_t *C = NULL;
  uint64_t nC = 0;
  
  //----------------------------
  A = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(A);
  for ( int i = 0; i < nA; i++ ) {
    A[i] = ( i + 1 ) * 10;
  }  
  
  //----------------------------
  B = malloc(nA/64 * sizeof(uint64_t));
  return_if_malloc_failed(B);
  
  //----------------------------
  C = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(C);
  
  for ( int j = 0; j < 8; j++ ) { 
    uint8_t *Bptr = (uint8_t *)B;
    for ( int i = 0; i < nA/8; i++ ) { 
      Bptr[i] = j;
    }

    uint64_t aidx= 0;
    nC = 0;
    status = where_I4(A, B, &aidx, nA, C, nA, &nC); cBYE(status);
    printf("Size of Output is %d\n", (int)nC);
    int exp_nC = __builtin_popcountll((unsigned long long)j) * (nA / 8);

    if ( nC != exp_nC ) { 
      printf("Length Mismatch\n");
      printf("C: ERROR\n"); go_BYE(-1); 
    }
  }
  printf("C: SUCCESS\n");
BYE:
  free_if_non_null(A);
  free_if_non_null(B);
  free_if_non_null(C);
  return status;
}
