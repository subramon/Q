
#include <stdbool.h>
#include <stdint.h>

typedef struct _random_F8_rec_type { 
  uint64_t seed;
  double lb;
  double ub;

} RANDOM_F8_REC_TYPE;

extern int
random_F8(
  double *X,
  uint64_t nX,
  RANDOM_F8_REC_TYPE *ptr_in,
  bool is_first
  );
