#include "incs.h"
#include "node_struct.h"
#include "make_fake_data.h"

// make fake data 
int
make_fake_data(
    int num_features,
    int num_instances, 
    float **ptr_X // [num_features*num_instances]
    )
{
  int status = 0;
  float *X = NULL;
  X = malloc(num_features * num_instances * sizeof(float *));
  return_if_malloc_failed(X);
  *ptr_X = X;
  srandom(time(NULL));
  for ( int fidx =  0; fidx < num_features; fidx++ ) { 
    for ( int ridx =  0; ridx < num_instances; ridx++ ) { 
      int r = random();
      r = r & 0x00FFFFFF;
      float range = 1 << 24;
      *X = (float)r / range; 
      X++;
    }
  }
BYE:
  return status;
}
