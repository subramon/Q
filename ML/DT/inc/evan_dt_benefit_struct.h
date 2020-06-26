#ifndef _EVAN_DT_BENEFIT_STRUCT_H
#define _EVAN_DT_BENEFIT_STRUCT_H
// TODO P3 Need to keep this in sync with specializer
typedef struct _evan_dt_benefit_args {
  double   val; // best split point: set in C code
  uint64_t num; // number of values consumed so fa: set in C code
  double total_sum; // Should be set before call 
  uint64_t total_cnt; // Should be set before call 
  double l_sum; // initialized to 0, increments later on
  uint64_t l_cnt; // initialized to 0, increments later on
  double r_sum; // initialized to total_sum, decrements later on
  uint64_t r_cnt; // initialized to total_sum, decrements later on
  uint32_t min_size; // set in specializer
  double benefit; // initialized to 0, increments later on
} EVAN_DT_BENEFIT_ARGS;
  
#endif
