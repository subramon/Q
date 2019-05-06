
#include "_logit2_I8.h"

static void __operation(
  int64_t a,
  double *ptr_c
  )
{
  double c;
   c = 1.0 / mcr_sqr ( ( 1.0 + exp(-1.0 *a) ) );   
  *ptr_c = c;
}

int
logit2_I8(  
      const int64_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      double * out,
      uint64_t *nn_out
      )

{
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }

  int nT = sysconf(_SC_NPROCESSORS_ONLN);
  nT = 4; // undo hard coding
#pragma omp parallel for schedule(static) num_threads(nT)
  for ( uint64_t i = 0; i < nR; i++ ) { 
    int64_t inv; 
    double outv; 
    inv = in[i];
    __operation(inv, &outv);
    out[i] = outv;
  } 
  BYE:
  return status;
}
   
