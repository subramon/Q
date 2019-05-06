
#include "_abs_F4.h"

static void __operation(
  float a,
  float *ptr_c
  )
{
  float c;
  c = fabsf(a);  
  *ptr_c = c;
}

int
abs_F4(  
      const float * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      float * out,
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
    float inv; 
    float outv; 
    inv = in[i];
    __operation(inv, &outv);
    out[i] = outv;
  } 
  BYE:
  return status;
}
   
