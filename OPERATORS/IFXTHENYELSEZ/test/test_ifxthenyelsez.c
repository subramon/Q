#include "q_incs.h"
#include <strings.h>
#include "_vv_ifxthenyelsez_I4.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int n = 65;
  int32_t Y[n];
  int32_t Z[n];
  int32_t W[n];
  uint8_t X[n]; // over allocated
  
  for ( int i = 0; i < n; i++ ) { 
    Y[i] = i+1;
    Z[i] = -1*(i+1);
  }
  for ( int i = 0; i < n; i++ ) { 
    X[i] = 0x55;
  }
  status = vv_ifxthenyelsez_I4((uint64_t *)X, Y, Z, W, n); 
  if ( status == 0 ) { 
    fprintf(stderr, "C: SUCCESS\n"); 
  }
  else {
    fprintf(stderr, "C: FAILURE\n"); 
  }
  for ( int i = 0; i < n; i++ ) { 
    fprintf(stdout, "%3d: %3d \n", i, W[i]);
  }

  cBYE(status);
  //----------------------------
BYE:
  return status;
}
