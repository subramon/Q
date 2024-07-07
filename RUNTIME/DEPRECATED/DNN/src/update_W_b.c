#include "q_incs.h"
#include "dnn_types.h"
#include "update_W_b.h"
int
update_W_b(
    float ***W,
    float ***dW,
    float **b,
    float **db,
    int nl,
    int *npl,
    bool **d, // true => dropout; false => keep
    float alpha // learning rate
    )
{
  int status = 0;
  // Updates the 'W' and 'b'
  for ( int l = 1; l < nl; l++ ) { // for layer, starting from one
    float **W_l  = W[l];
    float **dW_l = dW[l];
    float *b_l   = b[l];
    float *db_l  = db[l];
    bool *d_l   = d[l];
#pragma omp parallel for
    for ( int jprime = 0; jprime < npl[l-1]; jprime++ ) {
      // for neurons in layer l-1
      if ( d_l[jprime] ) { continue; } // TODO: Study carefully
      float  *W_l_jprime =  W_l[jprime];
      float *dW_l_jprime = dW_l[jprime];
#pragma omp simd
      for ( int j = 0; j < npl[l]; j++ ) { // for neurons in layer l
        W_l_jprime[j] -= ( alpha * dW_l_jprime[j] );
#ifdef COUNT
        num_b_flops += 2;
#endif
      }
      /* above is equivalent to below 
      for ( int j = 0; j < npl[l]; j++ ) { 
        *W_l_jprime++ -= ( alpha * *dW_l_jprime++ );
      }
      */
    }
#pragma omp simd
    for ( int j = 0; j < npl[l]; j++ ) { 
      b_l[j] -= ( alpha * db_l[j] );
#ifdef COUNT
      num_b_flops += 2;
#endif
    }
  }
BYE:
  return status;
}
