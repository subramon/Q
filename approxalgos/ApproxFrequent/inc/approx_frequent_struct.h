#ifndef __APPROX_FREQUENT_STRUCT_H
#define __APPROX_FREQUENT_STRUCT_H
typedef struct _cntrs_t { 
  double val;
  uint32_t freq;
} cntrs_t;

typedef struct _approx_frequent_state_t { 
  // START inputs 
  uint32_t n_input_vals_estimate;
  uint32_t err;
  uint32_t min_freq;
  uint32_t max_output;
  // STOP  inputs 
  cntrs_t *cntrs; // [sz_cntrs] 
  uint32_t sz_cntrs;
  uint32_t n_cntrs; // num actually in use 
  //-------------------------------
  uint32_t n_input_vals;
  //-------------------------
  double *buffer; // [sz_cntrs] 
  uint32_t n_buffer; // <= sz_cntrs
  //-----------------------------------
  cntrs_t *cnt_buffer; // [sz_cntrs] 
  uint32_t n_cnt_buffer; // <= sz_cntrs
  //-----------------------------------
  cntrs_t *merged_cntrs; // [2*sz_cntrs] 
  //-----------------------------------
  cntrs_t *output; 
  uint32_t n_output;
} approx_frequent_state_t;
#endif
