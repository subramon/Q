#ifndef __APPROX_QUANTILE_STRUCT
#define __APPROX_QUANTILE_STRUCT

#define EPS_OR_SIZ_BAD 1
#define SIZ_INCONSISTENT_WITH_EPS 2
#define MAX_SZ 1048576

typedef struct _approx_quantile_state_t { 
  uint64_t n_input_vals_estimate;
  bool is_final;
  int b;
  int k;
  int num_empty_buffers;
  double **buffer; // [b][k]
  int *weight; // [b] 
  double *quantiles; // [num_quantiles] 
  int num_quantiles;
  double eps;
  double *in_buffer; // [n_in_buffer]
  int n_in_buffer; 
} approx_quantile_state_t;

#endif
