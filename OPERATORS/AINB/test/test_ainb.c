#include "q_incs.h"
#include <strings.h>
#include "_bin_search_ainb_I4_I8.h"
#include "_simple_ainb_I4_I8.h"
#include "_bits_to_bytes.h"

static int 
sortcompare(
    const void *p1, 
    const void *p2)
{
  int64_t *p1_I4 = (int64_t *)p1;
  int64_t *p2_I4 = (int64_t *)p2;
  if ( *p1_I4 < *p2_I4 ) {
    return -1;
  }
  else if ( *p1_I4 > *p2_I4 ) {
    return 1; 
  }
  else {
    return 0;
  }
}

int
main(
    int argc,
    char **argv
    )
{
  int status = 0, b1_status = 0, b2_status = 0;
  int nA = 524288+17;
  int nB1 = 511;
  int nB2 = 31;
  int32_t *A = NULL;
  int64_t *B1 = NULL;
  int64_t *B2 = NULL;
  uint64_t *X = NULL; 
  uint8_t *Y = NULL; 
  int nY = nA;

  //----------------------------
  A = malloc(nA * sizeof(int32_t));
  return_if_malloc_failed(A);
  for ( int i = 0; i < nA; i++ ) { 
    A[i] = random() % 4096;
  }
  //----------------------------
  B1 = malloc(nB1 * sizeof(int64_t));
  return_if_malloc_failed(B1);
  for ( int i = 0; i < nB1; i++ ) { 
    B1[i] = random () % 1024;
  }
  qsort(B1, nB1, sizeof(int64_t), sortcompare);
  //----------------------------
  X = malloc(nA * sizeof(uint8_t)); // over  allocated 
  return_if_malloc_failed(X);
  uint8_t *lX = (uint8_t *)X;
  for ( int i = 0; i < nA; i++ ) { 
    lX[i] = 0xFF;
  }
  Y = malloc(nA * sizeof(uint8_t)); 
  return_if_malloc_failed(Y);
  //----------------------------
  status = bin_search_ainb_I4_I8(A, nA, B1, nB1, X); cBYE(status);
  status = bits_to_bytes(X, nA, Y, nY); cBYE(status);
  for ( int i = 0; i < nA; i++ ) { 
    bool found = false;
    for ( int j = 0; j < nB1; j++ ) { 
      if ( B1[j] == A[i] ) { found = true; break; }
    }
    if ( ( found == true ) && ( Y[i] != 1 ) ) { 
      b1_status = -1; WHEREAMI; 
      fprintf(stdout, "C: FAILURE at %d\n", i);  break;
    }
    if ( ( found == false ) && ( Y[i] != 0 ) ) { 
      b1_status = -1; WHEREAMI; 
      fprintf(stdout, "C: FAILURE at %d\n", i);  break;
    }
  }
  //----------------------------
  B2 = malloc(nB2 * sizeof(int64_t));
  return_if_malloc_failed(B2);
  for ( int i = 0; i < nB2; i++ ) { 
    B2[i] = random () % 1024;
  }
  status = simple_ainb_I4_I8(A, nA, B2, nB2, X); cBYE(status);
  status = bits_to_bytes(X, nA, Y, nY); cBYE(status);
  for ( int i = 0; i < nA; i++ ) { 
    bool found = false;
    for ( int j = 0; j < nB2; j++ ) { 
      if ( B2[j] == A[i] ) { found = true; break; }
    }
    if ( ( found == true ) && ( Y[i] != 1 ) ) { 
      b2_status = -1; WHEREAMI; 
      fprintf(stdout, "C: FAILURE at %d\n", i);  break;
    }
    if ( ( found == false ) && ( Y[i] != 0 ) ) { 
      b2_status = -1; WHEREAMI; 
      fprintf(stdout, "C: FAILURE at %d\n", i);  break;
    }
  }
  //----------------------------
  if ( ( b1_status == 0 ) && ( b2_status == 0 ) ) {
    fprintf(stdout, "C: SUCCESS\n"); 
  }
  //----------------------------
BYE:
  free_if_non_null(A);
  free_if_non_null(B1);
  free_if_non_null(B2);
  free_if_non_null(X);
  free_if_non_null(Y);
  return status;
}
