#include <omp.h>
#include "q_incs.h"
#include "dnn_types.h"
#include "act_fns.h"
#include "avx.h"

#include "fstep_a.h"

// This subroutine is best when n_out >> number of processors
// A single element of the input is in[0][i], in[1][i], ... in[n_in-1][i]
// A single element of the outnput is out[0][i], ... out[n_out-1][i]
// We use i as the index for each element in the batch 
// nI is the number of elements in the batch
// We use j as the index for each element in the input
// We use k as the index for each element in the output
// Given in, W, we update out
int fstep_a(
    float ** restrict in,  /* [n_in][nI] */
    float ** restrict W,   /* [n_in][n_out] */ 
    float * restrict b,    /* bias[n_out] */
    bool * restrict d_in,   /* [n_in]  dropout for input layer */
    bool * restrict d_out,  /* [n_out] dropout for output layer */
    float ** restrict out_z, /* [n_out][nI] */
    float ** restrict out_a, /* [n_out][nI] */
    int32_t nI, 
    int32_t n_in,  /* j is index for  input streaming */
    int32_t n_out,  /* k is index for output streaming */
    __act_fn_t afn
   )
{
  int status = 0;

  // This loop is the "b + " part of the formula 
#pragma omp parallel for
  for ( int k = 0; k < n_out; k++ ) {
    if ( d_out[k] ) { continue; }
    float *out_z_k = out_z[k];
    float b_k = b[k];
    for ( int i = 0; i < nI; i++ ) { 
      out_z_k[i] = b_k;
    }
  }
  // START: decide on which loop to parallelize
  int num_procs = 1; // omp_get_num_procs();
  bool outer_par = false, inner_par = false;
  if ( ( n_out == 1 ) && ( nI == 1 ) )  {
    outer_par = inner_par = false;
  }
  else {
    if ( n_out < num_procs ) {
      if ( nI < 1024 ) {  
        outer_par = true; inner_par = false;
      }
      else {
        outer_par = false; inner_par = true;
      }
    }
    else {
      outer_par = true; inner_par = false;
    }
  }
  if ( outer_par && inner_par ) { go_BYE(-1); }
  // STOP: decide on which loop to parallelize
  for ( int j = 0; j < n_in; j++ ) {  // for each neuron in input
    if ( d_in[j] ) { continue; }
    float *in_j = in[j];
    float *W_j = W[j];
// #pragma omp parallel for if ( outer_par )
#pragma omp parallel for 
    for ( int k = 0; k < n_out; k++ ) { // for each neuron in output
      if ( d_out[k] ) { continue; }
      float w_jk = W_j[k];
      float *out_z_k = out_z[k];
      status = va_times_sb_plus_vc(in_j, w_jk, out_z_k, out_z_k, nI);
      //cBYE(status);
      float *out_a_k = out_a[k];
      afn(out_z_k, nI, out_a_k);
    }
  }
BYE:
  return status;
}
