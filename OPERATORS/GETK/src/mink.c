#include "mink.h"

int
mink(
    const int32_t * restrict vals, // distance vector [n]
    uint64_t n, // size of distance/goal vectors
    const int32_t * restrict drags, // goal vector [n]
    void *ptr_in_args // structure maintaining k min distances and respective goals
    )

{
  int status = 0;

  if ( vals == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }
  if ( drags == NULL ) { go_BYE(-1); }
  if ( ptr_in_args == NULL ) { go_BYE(-1); }
  // This is okay. Will explain. if ( k > n ) { go_BYE(-1); }
  REDUCE_mink_ARGS *args = NULL;
  args = ptr_in_args;
  // REDUCE_mink_ARGS args = *((REDUCE_mink_ARGS *) ptr_in_args);

  int k = args->k; if ( k < 1 ) { go_BYE(-1); }
  
  for ( uint64_t i = 0; i < n; i++ ) {
    int32_t val  = vals[i];
    int32_t drag = drags[i];

    // first guy in gets a free pass
    if ( args->n == 0 ) {
      printf("Inserting %d \n", val);
      args->val[0]  = val;
      args->drag[0] = drag;
      args->n = args->n + 1;
      continue;
    }

    // if you are smaller than the max
    if ( val < args->val[k-1] ) {
      printf("Inserting %d \n", val);
      // find a spot for yourself
      int pos = -1;
      for ( int j = 0; j < args->k; j++ ) {
        if ( val < args->val[j] ) {
          pos = j; break;
        }
      }
      if ( pos < 0 ) { go_BYE(-1); }
      // Move everybody one to the right
      for ( int j = args->k - 2; j >= pos; j-- ) {
        args->val[j+1] = args->val[j];
      }
      args->val[pos]  = val; // put yourself in
      args->drag[pos] = drag; // put yourself in
      if ( args->n < args->k ) { // if there was space => one more
        args->n = args->n + 1;
      }
    }
  }
BYE:
  return status;
}
