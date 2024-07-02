#include "act_fns.h"
extern int 
fstep_a(
    float **in,  /* [n_in][nI] */
    float **W,   /* [n_in][n_out] */ /* TODO: Order to be debated */
    float *b,    /* bias[n_out] */
    bool *d_in,   /* dropout for input layer  */
    bool *d_out,  /* dropout for input layer  */
    float **out_z, /* [n_out][nI] */
    float **out_a, /* [n_out][nI] */
    int32_t nI, 
    int32_t n_in,  /* j is index for  input streaming */
    int32_t n_out,  /* k is index for output streaming */
    __act_fn_t afn
   );
