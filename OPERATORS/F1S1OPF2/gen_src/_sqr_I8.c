
#include "_sqr_I8.h"

static void __operation(
  int64_t a,
  int64_t *ptr_c
  )
{
  int64_t c;
  c = (a * a);  
  *ptr_c = c;
}

int
sqr_I8(  
      const int64_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int64_t * out,
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
    int64_t outv; 
    inv = in[i];
    __operation(inv, &outv);
    out[i] = outv;
  } 
  BYE:
  return status;
}
   
