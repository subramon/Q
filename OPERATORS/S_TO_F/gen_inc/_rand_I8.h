
#include "q_incs.h"
#include "_rdtsc.h"

// Below structure needs to be same as structure template in rand_mem_initialize.lua
typedef struct _rand_I8_rec_type {
  uint64_t seed;
  struct drand48_data buffer;
  int64_t lb;
  int64_t ub;
} RAND_I8_REC_TYPE;

extern int
rand_I8(
  int64_t *X,
  uint64_t nX,
  RAND_I8_REC_TYPE *ptr_rand_info,
  uint64_t idx
  );
   
