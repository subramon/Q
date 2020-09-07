// #include <stdint.h>
// #include "bs.h"

export void
bs(
    uniform float X[],
    uniform uint32 n,
    uniform float Y[],
    uniform uint32 m,
    uniform uint32 C[]
  )
{
  int status = 0;
  Y[0] = 0;
  foreach ( index = 0 ... m ) { 
    float yval = Y[index];
    int pos = -1;
    uint32 lb = 0;
    uint32 ub = n;
    for ( ; ; ) { 
      uint32 mid = (lb+ub) >> 1;
      float xval = X[mid];
      if ( yval <= xval ) { 
        if ( mid == 0 ) { pos = mid; break; }
        float pxval = X[mid-1];
        if ( yval > pxval ) { pos = mid; break; }
        ub = mid;
      }
      else { // yval > xval 
        if ( mid == n-1 ) { pos = mid+1; break; }
        float pxval = X[mid+1];
        if ( yval <= pxval ) { pos = mid+1; break; }
        lb = mid;
      }
    }
    // if ( pos < 0 )  { status = -1; }
    atomic_add_local(&C[pos], 1);
  }
  // return status;
}
