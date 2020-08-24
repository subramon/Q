#include <stdint.h>
#include "bs.h"

int
bs(
    float *X,
    uint32_t n,
    float *Y,
    uint32_t m,
    uint32_t *C
  )
{
  int status = 0;
  Y[0] = 0;
  for ( int i = 0; i < m; i++ ) { 
    int pos = -1;
    uint32_t lb = 0;
    uint32_t ub = n;
    for ( ; ; ) { 
      uint32_t mid = (lb+ub) >> 1;
      float val = X[mid];
      if ( Y[i] <= val ) { 
        if ( mid == 0 ) { pos = mid; break; }
        float pval = X[mid-1];
        if ( Y[i] > pval ) { pos = mid; break; }
        ub = mid;
      }
      else { // Y[i] > val 
        if ( mid == n-1 ) { pos = mid+1; break; }
        float pval = X[mid+1];
        if ( Y[i] <= pval ) { pos = mid+1; break; }
        lb = mid;
      }
    }
    if ( pos < 0 )  { status = -1; }
    C[pos]++;
  }
  return status;
}
