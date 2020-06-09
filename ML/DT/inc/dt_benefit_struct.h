#ifndef _DT_BENEFIT_STRUCT_H
#define _DT_BENEFIT_STRUCT_H
// TODO P3 Need to keep this in sync with specializer
typedef struct _dt_benefit_args {
  double   val; // best split point 
  uint64_t num; // number of values consumed so far
  uint64_t n_T_L; // initialized to 0, increments later on
  uint64_t n_H_L; // initialized to 0, increments later on
  uint64_t n_T; // set before first call 
  uint64_t n_H; // set before first call 
  uint64_t min_size; // set in specializer
  double wt_prior;
  double benefit; // initialized to 0, increments later on
} DT_BENEFIT_ARGS;
  
#endif
