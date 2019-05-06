
#include "q_incs.h"
#include "_rdtsc.h"

// Below structure needs to be same as structure template in rand_mem_initialize.lua
typedef struct _rand_I4_rec_type {
  uint64_t seed;
  struct drand48_data buffer;
  int32_t lb;
  int32_t ub;
} RAND_I4_REC_TYPE;

extern int
rand_I4(
  int32_t *X,
  uint64_t nX,
  RAND_I4_REC_TYPE *ptr_rand_info,
  uint64_t idx
  );
   
