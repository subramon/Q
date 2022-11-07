
#include "q_incs.h"
#include "permute_F4_I4.h"

int
permute_F4_I4(
    float *x,
    int32_t *p,
    uint32_t n,
    float *y
    )
{
  int status = 0;
  for ( uint32_t i = 0; i < n; i++ ) { 
    float xval = x[i];
    int32_t pos = p[i];
    y[pos] = xval;
  }
BYE:
  return status;
}
#define TEST
#ifdef TEST
int
main(
    void
    )
{
  int status = 0;
  int n = 17;
  float x[n];
  int32_t p[n];
  float y[n];
  int blksz = 4;
  for ( int i = 0; i < n; i++ ) { x[i] = (i+1)*10; } 
  for ( int i = 0; i < n; i++ ) { p[i] = (n-1)-i; }
  for ( int blk = 0; blk < ceil((float)n/(float)blksz); blk++ ) { 
    int lb = blk * blksz;
    int ub = lb  + blksz;
    if ( ub > n ) { ub = n; }
    permute_F4_I4(x+lb, p+lb, (ub-lb), y); 
  }
  for ( int i = 0; i < n; i++ ) { 
    fprintf(stdout, "%2d: %5.1f %5.1f \n", i, x[i], y[i]);
  }
BYE:
  return status;
}


#endif
