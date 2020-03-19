#ifndef __APPROX_QUANTILE
#define __APPROX_QUANTILE

#include "approx_quantile_struct.h"

extern int 
approx_quantile_make(
    int num_quantiles,
    uint64_t n_input_vals_estimate,
    approx_quantile_state_t *ptr_state,
    double eps,
    int *ptr_error_code
    );
extern int approx_quantile_add(
    approx_quantile_state_t *ptr_state,
    double val
    );
extern int approx_quantile_free(
    approx_quantile_state_t *ptr_state
    );
extern int 
approx_quantile_exec(
    approx_quantile_state_t *ptr_state
    );
extern int 
approx_quantile_final(
    approx_quantile_state_t *ptr_state
    );
#endif
