#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include "macros.h"

#define N 64
#define MIN_LEAF 8
void
pr1(
    int *X,
    int *C,
    bool *b,
    int n
   )
{
  for ( int i = 0; i < n; i++ ) { 
    fprintf(stdout,"%5d:%d:%d\n", X[i], C[i], b[i]);
  }
}

int
main(
    int argc,
    char **argv
    )
{
  int status = 0; 
  int X[N]; // values
  int C[N]; // class
  bool b[N]; // whether selected or not
BYE:
  for ( int i = 0; i < N; i++ ) { X[i] = i+1; }
  for ( int i = 0; i < N; i++ ) { C[i] = random() & 1; }
  for ( int i = 0; i < N; i++ ) { b[i] = true; }
  pr1(X, C, b, N);
  //-------------------------------------
  int n_A = 0; int n_B = 0;
  for ( int i = 0; i < N; i++ ) { 
    if ( C[i] == 0 ) { n_A++; } else { n_B++; }
  }
  //-------------------------------------
  int n_L_A = 0; int n_L_B = 0;
  for ( int i = 0; i < MIN_LEAF; i++ ) { 
    if ( C[i] == 0 ) { n_L_A++; } else { n_L_B++; }
  }

  return status;
}

