#include "q_incs.h"
#include "calc_benefit.h"

int
calc_benefit(
    uint64_t n_T_L,
    uint64_t n_H_L,
    uint64_t n_T,
    uint64_t n_H,
    uint64_t min_size,
    double wt_prior,
    double *ptr_benefit
    )
{
  int status = 0;
  *ptr_benefit = 0;
  uint64_t n = n_H + n_T;
  if ( ( n_T == 0 ) || ( n_H == 0 ) ) { go_BYE(-1); }
  if ( min_size == 0 ) { go_BYE(-1); }
  if ( n_H_L > n_H ) { 
    go_BYE(-1); }
  if ( n_T_L > n_T ) { 
    go_BYE(-1); }
  uint64_t n_H_R = n_H - n_H_L;
  uint64_t n_T_R = n_T - n_T_L;
  uint64_t n_L = n_H_L + n_T_L;
  uint64_t n_R = n - n_L;
  if ( n_L < min_size ) { return status; }
  if ( n_R < min_size ) { return status; }
  double b_L = n_H_L / (double)n_L;
  double b_R = n_H_R / (double)n_R;
  if ( ( b_L < 0 ) || ( b_L > 1 ) ) { go_BYE(-1); }
  if ( ( b_R < 0 ) || ( b_R > 1 ) ) { go_BYE(-1); }
  if ( b_L > b_R ) { 
    *ptr_benefit = b_L;
  }
  else {
    *ptr_benefit = b_R;
  }
BYE:
  return status;
}
