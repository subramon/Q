#include "q_incs.h"
#include "_numby_I4.h"

int main(void)
{
  int status = 0;
  int nX = 105, nZ = 10;
  int32_t X[nX];
  int64_t Z[nZ];
  int start = 0;
  for ( int i = 0; i < nX; i++ ) { 
    X[i] = start++; 
    if ( start == nZ ) { start = 0; }
  }
  for ( int i = 0; i < nZ; i++ ) { Z[i] = 0; }
  status = numby_I4(X, nX, Z, nZ, true); cBYE(status);
  for ( int i = 0; i < 5; i++ ) { if ( Z[i] != 11 ) { go_BYE(-1); } }
  for ( int i = 5; i < nZ; i++ ) { if ( Z[i] != 10 ) { go_BYE(-1); } }
BYE:
  return status;
}
