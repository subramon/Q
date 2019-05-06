
#include "_decr_I4.h"

static void __operation(
  int32_t a,
  int32_t *ptr_c
  )
{
  int32_t c;
  c = a - 1;  
  *ptr_c = c;
}

int
decr_I4(  
      const int32_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int32_t * out,
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
    int32_t inv; 
    int32_t outv; 
    inv = in[i];
    __operation(inv, &outv);
    out[i] = outv;
  } 
  BYE:
  return status;
}
   
