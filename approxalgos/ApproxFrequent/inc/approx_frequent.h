#include "approx_frequent_struct.h"
extern int 
approx_frequent_make(
  uint32_t n_estimate,
  uint32_t err,
  uint32_t min_freq,
  approx_frequent_state_t *ptr_state
  );
extern int 
approx_frequent_add(
    approx_frequent_state_t *ptr_state,
    double val
    );
extern void
approx_frequent_free(
    approx_frequent_state_t *ptr_state
    );
