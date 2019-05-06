
#include "_incr_I2.h"

static void __operation(
  int16_t a,
  int16_t *ptr_c
  )
{
  int16_t c;
  c = a + 1;  
  *ptr_c = c;
}

int
incr_I2(  
      const int16_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int16_t * out,
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
    int16_t inv; 
    int16_t outv; 
    inv = in[i];
    __operation(inv, &outv);
    out[i] = outv;
  } 
  BYE:
  return status;
}
   
