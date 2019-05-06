#include<stdio.h>

int main(void)
{
  int status = 0;
  int n = 10;
  int32_t X[n];
  int32_t Y[n];
  int32_t Z[n];
  uint32_t nX = 10, nY = 10, nZ = 10, num_in_Z;
  for ( int i = 0; i < nX; i++ ) { X[i] = 2*i; }
  for ( int i = 0; i < nY; i++ ) { Y[i] = 2*i+1; }
  status = merge_min(X, nX, Y, nY, Z, nZ, &num_in_Z);
  for ( int i = 0; i < num_in_Z; i++ ) { printf("%d: %d \n", i, Z[i]); }
BYE:
  return status;
}

