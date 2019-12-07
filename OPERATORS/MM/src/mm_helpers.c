#include "q_incs.h"
#include "mm_helpers.h"

void 
print_matrix(
    double** m, 
    int rows, 
    int cols
    )
{
  printf("printing matrix\n");
  for ( int i = 0; i < rows; i++) {
    for ( int j = 0; j < cols; j++) {
      printf("%lf ", m[j][i]);
    }
    printf("\n");
  }
}

int 
alloc_matrix(
    int num_rows, 
    int num_cols,
    double ***ptr_x
    )
{
  printf("allocating matrix\n");
  int status = 0;
  double **x = NULL;
  if ( num_rows < 1 ) { go_BYE(-1); }
  if ( num_cols < 1 ) { go_BYE(-1); }
  if ( ( num_rows == 1 ) && ( num_cols == 1 ) )  { go_BYE(-1); }
  x = (double **) calloc(num_cols, sizeof(double *));
  return_if_malloc_failed(x);
  for ( int i = 0; i < num_cols; i++) {
    x[i] = (double *) calloc(num_rows, sizeof(double));	
    return_if_malloc_failed(x[i]);
  }
  *ptr_x = x;
BYE:
   return status;
}

void
free_matrix(
    double **m,
    int num_cols
    )
{
  for ( int i = 0; i < num_cols; i++ ) {
    free(m[i]);
  }
  free(m);
}

int
set_matrix(
    double **m, 
    int num_rows, 
    int num_cols
    )
{
  int status = 0;
  if ( m == NULL ) { 
    go_BYE(-1); 
  }
  if ( num_rows < 1 ) { 
    go_BYE(-1); 
  }
  if ( num_cols < 1 ) { 
    go_BYE(-1); 
  }

  printf("setting matrix randomly\n");
  for ( int i = 0; i < num_rows; i++ ) {
    for ( int j = 0; j < num_cols; j++ ) {
      m[j][i] = (double)(rand() % 100)/(double)((rand() % 100)+1);
    }
  }
BYE:
  return status;
}

bool
cmp_matrix(
    double **x,
    double **y,
    int m,
    int n,
    double threshold
    )
{
  bool equals = true;
  for ( int i = 0; i < m; i++ ) { 
    for ( int j = 0; j < n; j++ ) { 
      if ( fabs(x[j][i] - y[j][i]) > threshold ) { 
        equals = false; break;
      }
    }
    if ( !equals ) { break; }
  }
  return equals;
}

/* assembly code to read the TSC */
uint64_t 
RDTSC(void)
{
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
}

