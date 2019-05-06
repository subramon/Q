#include "q_incs.h"
#include "dnn_types.h"
#include "act_fns.h"
#include "avx.h"

#include "bstep.h"

int compute_da_last(
    float ** restrict a,   /* 'a' value for last layer */
    float ** restrict out,   /* Xout */
    float ** restrict da,   /* 'da' value for last layer */
    int n_in_last,   /* number of neurons in last layer */
    int nI
    )
{
  int status = 0;

  for ( int j = 0; j < n_in_last; j++ ) { // for neurons in last layer
    float *out_j = out[j];
    float *a_j   = a[j];
    float *da_j  = da[j];
#pragma omp parallel for schedule(static, 16)
    // 16 is so that if cache line is 64 bytes and float is 4 bytes
    // then threads do not stomp on each other
    for ( int i = 0; i < nI; i++ ) { // for each instance
      da_j[i] = ( ( 1 - out_j[i] ) / ( 1 - a_j[i] ) ) 
        - ( out_j[i] / a_j[i] );
#ifdef COUNT
      num_b_flops += 5;
#endif
    }
  } // 'da' for last layer has been computed
BYE:
  return status;
}

//================================================================
/*
For backward propagation,
    in_layer --> current layer (l)
    out_layer -> previous layer (l-1)
*/
int bstep(
    float **z, /* 'z' at in_layer */
    float **a_prev, /* 'a' at out_layer */
    float **W, /* 'W' at in_layer */
    float **da, /* 'da' at in_layer */
    float **dz, /* 'dz' at in_layer */
    float **da_prev, /* 'da' at out_layer */
    float **dW, /* 'dW' at in_layer */
    float *db, /* 'db' at in_layer */
    int32_t n_in, /* neurons in in_layer */
    int32_t n_out, /* neurons in out_layer */
    int32_t nI,
    __bak_act_fn_t afn
    )
{
  int status = 0;

  // I think it might make sense to compute dW and db even if we don't 
  // use them because of the dropout

  // Initialize dz to zero
#pragma omp parallel for schedule(static)
  for ( int j = 0; j < n_in; j++ ) { // for neurons in in_layer
    float *dz_j = dz[j];
    // RAMESH: We should compare loop with memset
    // RAMESH: might as well do omp simd, will not hurt
#pragma omp simd
    for ( int i = 0; i < nI; i++ ) {
      dz_j[i] = 0;
    }
  }

  // Initialize da_prev to zero
  if ( da_prev != NULL ) { // avoid computing da[0], which is NULL
#pragma omp parallel for schedule(static)
    for ( int j = 0; j < n_out; j++ ) { // for neurons in out_layer
      float *da_prev_j = da_prev[j];
      // RAMESH: Same comments as earlier, 
      // compare with memset and simd won't hurt
#pragma omp simd
      for ( int i = 0; i < nI; i++ ) {
        da_prev_j[i] = 0;
      }
    }
  }

  // ----------- START - compute dz -----------
#pragma omp parallel for schedule(static)
  for ( int j = 0; j < n_in; j++ ) { // for neurons in in_layer
    int l_status = 0;
    if ( status < 0 ) { continue; }
    float *z_j = z[j];
    float *da_j = da[j];
    float *dz_j = dz[j];
    l_status = afn(z_j, da_j, nI, dz_j);
    if ( l_status < 0 ) { status = -1; continue; }
  }
  cBYE(status);
  // ----------- STOP - compute dz -----------

  // ----------- START - compute da_prev -----------
// TODO: if I enable below pragma omp instruction, 
// then I observe difference for few values of updated 'W' and 'b'
#pragma omp parallel for schedule(static)
  for ( int j = 0; j < n_in; j++ ) { // for neurons in in_layer
    float *dz_j = dz[j];
    if ( da_prev != NULL ) { // avoid computing da[0], which is NULL
      for ( int jprime = 0; jprime < n_out; jprime++ ) { // for neurons in out_layer
        float *W_jprime = W[jprime];
        float *da_prev_jprime = da_prev[jprime];
        status = a_times_sb_plus_c(dz_j, W_jprime[j], da_prev_jprime, da_prev_jprime, nI);
        //cBYE(status)
      }
    }
  }
  // ----------- STOP - compute da_prev -----------

  // ----------- START - compute dW & db -----------
#pragma omp parallel for schedule(static)
  for ( int j = 0; j < n_in; j++ ) { // for neurons in in_layer
    float sum = 0;
    float *dz_j = dz[j];
    for ( int jprime = 0; jprime < n_out; jprime++ ) { 
      // for neurons in out_layer
      sum = 0;
      float *a_prev_jprime = a_prev[jprime];
      status = a_dot_b(dz_j, a_prev_jprime, &sum, nI);
      //cBYE(status);
      sum /= nI;
#ifdef COUNT
      num_b_flops += 1;
#endif
      dW[jprime][j] = sum;
    }
    sum = 0;
#pragma omp simd reduction(+:sum)
    for ( int i = 0; i < nI; i++ ) {
      sum += dz_j[i];
#ifdef COUNT
      num_b_flops += 1;
#endif
    }
    sum /= nI;
#ifdef COUNT
    num_b_flops += 1;
#endif
    db[j] = sum;
  }
  // ----------- STOP - compute dW & db -----------
  
BYE:
  return status;
}
