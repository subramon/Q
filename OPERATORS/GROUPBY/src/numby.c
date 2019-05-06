#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }
#define cBYE(x) { if ( status < 0 ) { go_BYE(x) ; } }

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

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
