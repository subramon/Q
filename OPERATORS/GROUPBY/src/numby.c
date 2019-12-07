#include "q_incs.h"

int numby_I4(
    int32_t *X, /* [nX] */
    uint32_t nX,
    int32_t *Z, /* [nZ] */
    uint32_t nZ,
    bool is_safe
    )
{
  int status = 0;

  for ( int i = 0; i < nX; i++ ) {
    int32_t x = X[i];
    if ( is_safe ) {
      if ( ( x < 0 ) || ( x >= nZ ) ) { go_BYE(-1); }
    }
    Z[x]++;
  }
BYE:
  return status;
}
#define STAND_ALONE_TEST
#ifdef STAND_ALONE_TEST
int main(void)
{
  int status = 0;
  int nX = 105, nZ = 10;
  int32_t X[nX];
  int32_t Z[nZ];
  int start = 0;
  for ( int i = 0; i < nX; i++ ) { 
    X[i] = start++; 
    if ( start == nZ ) { start = 0; }
  }
  for ( int i = 0; i < nZ; i++ ) { Z[i] = 0; }
  status = numby_I4(X, nX, Z, nZ, true); cBYE(status);
  for ( int i = 0; i < nZ; i++ ) { printf("%d: %d \n", i, Z[i]); }
BYE:
  return status;
}
#endif
