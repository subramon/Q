#include "q_incs.h"

typedef struct _rand_B1_rec_type {
  uint64_t seed;
  struct drand48_data buffer;
  double probability;
} RAND_B1_REC_TYPE;

extern int
rand_B1(
  uint64_t *X,
  uint64_t nX,
  RAND_B1_REC_TYPE *ptr_in,
  uint64_t idx
  );
