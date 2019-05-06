#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <string.h>
#include <limits.h>
#include <inttypes.h>
#include <ctype.h>
#include "q_macros.h"
#include "mmap.h"
#include "aux_driver.h"
#include "positive_solver.h"

#define PI 3.14159265358979

bool
is_valid_chars_for_num(
      char * const X
      )
{
  if ( ( X == NULL ) || ( *X == '\0' ) ) { WHEREAMI; return false; }
  for ( char *cptr = X; *cptr != '\0'; cptr++ ) { 
    if ( isdigit(*cptr) || 
        ( *cptr == '-' )  ||
        ( *cptr == '.' ) ) {
      continue;
    }
    return false;
  }
  return true;
}
//------------------------------
int
txt_to_F8(
      char * const X,
      double *ptr_out
      )
{
  int status = 0;
  char *endptr = NULL;
  double out;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  if ( !is_valid_chars_for_num(X) ) { go_BYE(-1); }
  out = strtold(X, &endptr);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  if ( endptr == X ) { go_BYE(-1); }
  if ( ( out < DBL_MIN ) || ( out > DBL_MAX ) ) { go_BYE(-1); }
  *ptr_out = (double)out;
 BYE:
  return status ;
}

//-------------------
int
dump_to_file(
    double *Y, 
    int nT,
    char *filename
    )
{
  int status = 0;
  FILE *ofp = fopen(filename, "w");
  return_if_fopen_failed(ofp, filename,"w");
  for ( int i = 0; i < nT; i++ ) { 
    fprintf(ofp, "%d,%lf\n", i, Y[i]);
  }
BYE:
  fclose_if_non_null(ofp);
  return status;
}
//------------------------------
int
load_col_csv(
    char *infile,
    double **ptr_X,
    int *ptr_nX
    )
{
  int status = 0;
  char buf[32];
  char *Y = NULL; size_t nY = 0;
  double *X = NULL; int nX = 0; double tempF8;
  status = rs_mmap(infile, &Y, &nY, 0); cBYE(status);
  for ( int i = 0; i < nY; i++ ) { 
    if ( Y[i] == '\n' ) { nX++; }
  }
  if ( nX == 0 ) { go_BYE(-1); }
  X = malloc(nX * sizeof(double));
  return_if_malloc_failed(X);
  int bufidx = 0; int yidx = 0; int xidx = 0;
  memset(buf, '\0', 32); 
  for ( ; ; yidx++ ) { 
    if ( yidx >= nY ) { go_BYE(-1); }
    if ( Y[yidx] == '\n' ) {
      status = txt_to_F8(buf, &tempF8); cBYE(status);
      X[xidx++] = tempF8;
      if ( xidx == nX ) { break; }
      bufidx = 0;
      memset(buf, '\0', 32); 
    }
    else {
      if ( bufidx == 32 ) { go_BYE(-1); }
      buf[bufidx++] = Y[yidx];
    }
  }
  *ptr_X  = X;
  *ptr_nX = nX;
BYE:
  rs_munmap(Y, nY);
  return status;
}

int
main(
    int argc,
    char **argv
    )

{
  int status = 0;
  double *X = NULL; int nT = 0;
  double *Y = NULL; 
  double *Z1 = NULL; 
  double *Z1a = NULL; 
  double *Z7 = NULL; 
  double *W = NULL;
  double *Wm = NULL;
  double **U = NULL;
  double **A = NULL;
  double *a = NULL; double *b = NULL;
  double **Aprime = NULL; double *bprime = NULL;
  double *gamma = NULL;
  double *rho = NULL;
  FILE *ofp = NULL;

  if ( argc != 4 ) { go_BYE(-1); }
  char *infile = argv[1];
  char *opfile = argv[2];
  char *str_period = argv[3];
  ofp = fopen(opfile, "w");
  if ( strcmp(infile, opfile) == 0 ) { go_BYE(-1); }
  return_if_fopen_failed(ofp, opfile, "w");
  status = load_col_csv(infile, &X, &nT); cBYE(status);
  char *endptr = NULL;
  int period = strtoll(str_period, &endptr, 10);
  if ( period <= 0 ) { go_BYE(-1); }

  //-------------------------------------
  Y = malloc(nT * sizeof(double));
  return_if_malloc_failed(Y);
  for ( int i = 0; i < nT; i++ ) { 
    Y[i] = log(X[i]);
  }
  status = dump_to_file(Y, nT,"_y.csv"); cBYE(status);
  //-------------------------------------

  nT -= 1;
  Z1 = malloc(nT * sizeof(double));
  return_if_malloc_failed(Z1);

  for ( int i = 0; i < nT; i++ ) { Z1[i] = Y[i+1] - Y[i]; }
  status = dump_to_file(Z1, nT,"_z1.csv"); cBYE(status);

  nT -= 1;
  Z1a = malloc(nT * sizeof(double));
  return_if_malloc_failed(Z1a);

  for ( int i = 0; i < nT; i++ ) { Z1a[i] = Z1[i+1] - Z1[i]; }
  status = dump_to_file(Z1a, nT,"_z1a.csv"); cBYE(status);

  nT -= 7;
  Z7 = malloc(nT * sizeof(double));
  return_if_malloc_failed(Z7);

  for ( int i = 0; i < nT; i++ ) { Z7[i] = Z1a[i+7] - Z1a[i]; }
  status = dump_to_file(Z7, nT,"_z7.csv"); cBYE(status);

  char buf[16];
  int nJ = 1+(period-1)+(period-1); // number of functions used
  U = malloc(nJ * sizeof(double *));
  return_if_malloc_failed(U);

  for ( int j = 0; j < nJ; j++ ) { 
    U[j] = malloc(nT * sizeof(double));
    return_if_malloc_failed(U[j]);
  }

  for ( int t = 0; t < nT; t++ ) { 
    U[0][t] = 1;
  }
  for ( int j = 1; j < period; j++ ) { 
    for ( int t = 0; t < nT; t++ ) { 
      U[j][t] = cos ( 2 * PI * j * (double)t / (double)period );
    }
    sprintf(buf, "_u_%d.csv", j);
    dump_to_file(U[j], nT, buf);
  }
  int j_shifted;
  for ( int j = 1; j < period; j++ ) { 
    j_shifted = j + period -1;
    for ( int t = 0; t < nT; t++ ) { 
      U[j_shifted][t] = sin ( 2 * PI * j * (double)t / (double)period );
    }
    sprintf(buf, "_u_%d.csv", j_shifted);
    dump_to_file(U[j_shifted], nT, buf);
  }
  //-------------------------------------

  //  Create symmetric matrix A
  status = alloc_matrix(&A, nJ); cBYE(status);
  for ( int j1 = 0; j1 < nJ; j1++ ) { 
    for ( int j2 = 0; j2 < nJ; j2++ ) { 
      double sum = 0;
      for ( int t = 0; t < nT; t++ ) { 
        sum += ( U[j1][t] * U[j2][t] );
      }
      A[j1][j2] = sum;
    }
  }
  //-------------------------------------
  //  Create b
  b = malloc(nJ * sizeof(double));
  return_if_malloc_failed(b);
  for ( int j = 0; j < nJ; j++ ) { 
    double sum = 0;
    for ( int t = 0; t < nT; t++ ) { 
      sum += Z7[t] * U[j][t];
    }
    b[j] = sum;
  }
  //-------------------------------------
  // Solve for a 
  a = malloc(nJ * sizeof(double));
  return_if_malloc_failed(a);
  for ( int j = 0; j < nJ; j++ ) { a[j] = 0; }

  status = convert_matrix_for_solver(A, nJ, &Aprime); cBYE(status);
  // make a copy of b in bprime
  bprime = malloc(nJ * sizeof(double));
  return_if_malloc_failed(bprime);
  for ( int j = 0; j < nJ; j++ ) { 
    bprime[j] = b[j];
  }
  // print_input(A, Aprime, a, b, nJ);
  status = positive_solver(Aprime, a, b, nJ); cBYE(status);
  // Verify solution 
  for ( int j = 0; j < nJ; j++ ) { 
    double sum = 0;
    for ( int j2 = 0; j2 < nJ; j2++ ) { 
      sum += A[j][j2] * a[j2];
    }
    double minval = mcr_min(sum, bprime[j]);
    if ( ( sum/bprime[j] > 1.01 ) || ( sum / bprime[j] < 0.99 ) ) {
      printf("Error on b[%d]: %lf versus %lf \n", j, sum, bprime[j]);
    }
  }
  //---------------------------------
  W = malloc(nT * sizeof(double));
  Wm = malloc(nT * sizeof(double));
  return_if_malloc_failed(W);
  for ( int t = 0; t < nT; t++ ) { 
    double sum = 0;
    for ( int j = 0; j < nJ; j++ ) { 
      sum += a[j] * U[j][t];
    }
    Wm[t] =  sum;
    W[t] = Z7[t] -  sum;
  }
  status = dump_to_file(Wm, nT,"_wm.csv"); cBYE(status);
  status = dump_to_file(W, nT,"_w.csv"); cBYE(status);
  //--------------------------------
  double mu = 0;
  for ( int t = 0; t < nT; t++ ) { 
    mu += W[t];
  }
  mu /= nT;
  fprintf(stderr, "mu = %lf \n", mu);
  //--------------------------------
  gamma = malloc(nT * sizeof(double));
  return_if_malloc_failed(gamma);
  for ( int t1 = 0; t1 < nT; t1++ ) { 
    double sum = 0;
    for ( int t2 = 0; t2 < nT -t1; t2++ ) {
      sum += ((W[t2] - mu) * (W[t2+t1] - mu));
    }
    gamma[t1] = sum;
  }
  //--------------------------------
  rho = malloc(nT * sizeof(double));
  return_if_malloc_failed(rho);
  for ( int t = 0; t < nT; t++ ) { 
    rho[t] = gamma[t] / gamma[0];
  }
  fprintf(stderr, "gamma[0] = %lf \n", gamma[0]);
  //----------------------
  for ( int t = 0; t < nT; t++ ) {
    fprintf(ofp, "%lf\n", rho[t]);
  }
  //----------------------
  printf("ALL DONE\n");
BYE:
  free_matrix(A, nJ);
  if ( Aprime != NULL ) {
    for ( int j = 0; j < nJ; j++ ) { 
      free_if_non_null(Aprime[j]);
    }
  }
  free_if_non_null(Aprime);
  if ( U != NULL ) {
    for ( int j = 0; j < nJ; j++ ) { 
      free_if_non_null(U[j]);
    }
  }
  fclose_if_non_null(ofp);
  free_if_non_null(U);
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(Z1a);
  free_if_non_null(Z1);
  free_if_non_null(Z7);
  free_if_non_null(W);
  free_if_non_null(a);
  free_if_non_null(b);
  free_if_non_null(gamma);
  free_if_non_null(rho);
  return status;
}
