#ifndef __APPROX_UNIQUE_H
#define __APPROX_UNIQUE_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <math.h>
typedef struct _approx_unique_state_t {
  int m;
  int *max_rho ; // [m] 
  uint64_t seed;
} approx_unique_state_t;

extern int 
approx_unique_make(
    approx_unique_state_t *ptr_state,
    int m
    );
extern int 
approx_unique_free(
    approx_unique_state_t *ptr_state
    );
extern int 
approx_unique_exec(
    approx_unique_state_t *ptr_state,
    char *x,
    int sz_x
    );
extern int 
approx_unique_final(
    approx_unique_state_t *ptr_state,
    int *ptr_estimate,
    double *ptr_estimate_accuracy_percent,
    int *ptr_estimate_is_good 
    );
#endif
