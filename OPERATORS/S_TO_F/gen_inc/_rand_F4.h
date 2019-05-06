
#include "q_incs.h"
#include "_rdtsc.h"

// Below structure needs to be same as structure template in rand_mem_initialize.lua
typedef struct _rand_F4_rec_type {
  uint64_t seed;
  struct drand48_data buffer;
  float lb;
  float ub;
} RAND_F4_REC_TYPE;

extern int
rand_F4(
  float *X,
  uint64_t nX,
  RAND_F4_REC_TYPE *ptr_rand_info,
  uint64_t idx
  );
   
