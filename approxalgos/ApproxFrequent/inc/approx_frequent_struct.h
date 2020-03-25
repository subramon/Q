#ifndef __APPROX_FREQUENT_STRUCT_H
#define __APPROX_FREQUENT_STRUCT_H
typedef struct _cntrs_t { 
  double val;
  uint32_t freq;
} cntrs_t;

typedef struct _approx_frequent_state_t { 
  cntrs_t *cntrs;
  uint32_t n_cntrs;
  uint32_t n_active_cntrs;
  //-------------------------------
  uint32_t n_input_vals;
  uint32_t n_input_vals_estimate;
  uint32_t err;
  uint32_t min_freq;
  //-------------------------
  double *buffer; // [sz_buffer] 
  uint32_t n_buffer; // <= sz_buffer
  uint32_t sz_buffer;  // > 0
  //-----------------------------------
  cntrs_t *cnt_buffer; // [sz_buffer] 
  uint32_t n_cnt_buffer; // <= sz_buffer
  //-----------------------------------
  bool is_final;
  double *high_rollers; // [sz_high_rollers]
  uint32_t n_high_rollers; 
  uint32_t sz_high_rollers; 
} approx_frequent_state_t;
#endif
