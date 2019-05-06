
#include "_abs_I1.h"

static void __operation(
  int8_t a,
  int8_t *ptr_c
  )
{
  int8_t c;
  c = (int8_t)abs(a);  
  *ptr_c = c;
}

int
abs_I1(  
      const int8_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int8_t * out,
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
    int8_t inv; 
    int8_t outv; 
    inv = in[i];
    __operation(inv, &outv);
    out[i] = outv;
  } 
  BYE:
  return status;
}
   
