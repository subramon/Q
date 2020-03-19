#ifndef __APPROX_UNIQUE_STRUCT_H
#define __APPROX_UNIQUE_STRUCT_H
#include <stdint.h>
#include <inttypes.h>
typedef struct _approx_unique_state_t {
  int m;
  int *max_rho ; // [m] 
  uint64_t seed;
} approx_unique_state_t;
#endif
