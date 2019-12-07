#include "q_incs.h"
#include "matrix_multiply.h"
#include "_rdtsc.h"

int 
mm_simple(
    double ** x, 
    double ** y, 
    double ** z, 
    int m,
    int k,
    int n
    )
{
  int status = 0;
  printf("multiplying simple\n");
  uint64_t t_start, t_stop;

  t_start = RDTSC();
  int num_ops = 0;
  for ( int i = 0; i < m; i++) {
    for ( int j = 0; j < n; j++) {
      double sum = 0;
      for(int t = 0; t < k; t++){
        sum += x[t][i] * y[j][t];
        num_ops++;
      }
      z[j][i] = sum;
    }
  }
  t_stop = RDTSC();
  printf("Ops = %d, Time = %llu \n", num_ops, t_stop - t_start);

BYE:
  return status; 
}

int 
mm_fast_1d_alt(
    double ** x,  /* m by k */
    double ** y,  /* k by 1 */
    double ** z,  /* m by 1 */
    int m,
    int k,
    int n
    )
{
  int status = 0;

  printf("fast multiply 1D alt");
  //n = 1 in this special case
//#pragma omp parallel for
  for ( int i = 0; i < k; i++ ) {
    double scale = y[0][i];
    double *x_i = x[i];
#pragma omp parallel for
    for ( int j = 0; j < m; j++ ) { 
      z[0][j] += scale * x_i[j];
    }
  }
BYE:
  return status;
}

int 
mvmul_a(
    double ** x, 
    double * y, 
    double * z, 
    int m,
    int k
    )
{
  int status = 0;
  int nT = sysconf(_SC_NPROCESSORS_ONLN);

//#pragma omp parallel for schedule(static, 1)
  int block_size = m / nT;

  for ( int t = 0; t < nT; t++ ) {
    int lb = t * block_size;
    int ub = lb + block_size;
    if ( t == (nT-1) ) { ub = m; }
#pragma omp simd
    for ( int j = lb; j < ub; j++ ) {
      z[j] = 0;
    }
  }

  //n = 1 in this special case
  for ( int i = 0; i < k; i++ ) {
    double scale = y[i];
    double *x_i = x[i];
//#pragma omp parallel for schedule(static, 1)
    for ( int t = 0; t < nT; t++ ) { 
      int lb = t * block_size;
      int ub = lb + block_size;
      if ( t == (nT-1) ) { ub = m; }
      for ( int j = lb; j < ub; j++ ) {
        z[j] += scale * x_i[j];
      }
    }
      
  }
  
BYE:
  return status;
}

int 
mm_fast_many_cols(
    double ** x, 
    double ** y, 
    double ** z, 
    int m,
    int k,
    int n
    )
{
  int status = 0;
  printf("many columns\n");
#pragma omp parallel for
  for ( int i = 0; i < n; i++ ) {
    for ( int j = 0; j < m; j++ ) {
      z[i][j] = 0;
      for ( int t = 0; t < k; t++ ) {
        z[i][j] += x[t][j] * y[i][t]; 
      }
    }
  }
BYE:
  return status;
}

int 
mm_fast_many_rows(
    double ** x, 
    double ** y, 
    double ** z, 
    int m,
    int k,
    int n
    )
{
  printf("many rows\n");
  int status = 0;
  for (int t = 0; t < n; t++ ) { 
    for ( int i = 0; i < k; i++ ) {
      double scale = y[t][i];
      double *x_i = x[i];
#pragma omp parallel for
      for ( int j = 0; j < m; j++ ) { 
        z[t][j] += scale * x_i[j];
      }
    }
  }
BYE:
  return status;
}
