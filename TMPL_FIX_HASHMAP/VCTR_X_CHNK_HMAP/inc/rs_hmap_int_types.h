#ifndef __HMAP_INT_TYPES_H
#define __HMAP_INT_TYPES_H
#include <stdint.h>
// Example of key is 4th chunk of vector 17
// Example of val is chunk number 25
typedef struct _rs_hmap_key_t {
  uint32_t vctr_uqid;
  uint32_t chnk_idx;
} rs_hmap_key_t;

typedef uint32_t rs_hmap_val_t;
#endif //  __HMAP_INT_TYPES_H
