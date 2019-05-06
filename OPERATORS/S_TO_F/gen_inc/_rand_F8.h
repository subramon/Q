
#include "q_incs.h"
#include "_rdtsc.h"

// Below structure needs to be same as structure template in rand_mem_initialize.lua
typedef struct _rand_F8_rec_type {
  uint64_t seed;
  struct drand48_data buffer;
  double lb;
  double ub;
} RAND_F8_REC_TYPE;

extern int
rand_F8(
  double *X,
  uint64_t nX,
  RAND_F8_REC_TYPE *ptr_rand_info,
  uint64_t idx
  );
   
