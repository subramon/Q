#include "act_fns.h"

extern int
compute_da_last(
    float **a,
    float **out,
    float **da,
    int num_in_last,
    int batch_size
    );

extern int
bstep(
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
    int32_t batch_size,
    __bak_act_fn_t afn
    );

