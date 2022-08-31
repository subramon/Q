#ifndef __HMAP_INT_TYPES_H
#define __HMAP_INT_TYPES_H
#include <stdint.h>
typedef uint32_t rs_hmap_key_t; // a vector is identified by a number

#define MAX_LEN_VEC_NAME 15 // for debugging 

typedef struct _vctr_meta_t {
  char name[MAX_LEN_VEC_NAME+1];
  uint64_t num_elements;
  uint32_t num_chunks;
  qtype_t qtype;
  bool is_eov;   // true => no changes allowed
  bool is_trash; // true => marked for garbage collection 
  // Much more to put in here
} vctr_meta_t;
typedef vctr_meta_t rs_hmap_val_t;
#endif //  __HMAP_INT_TYPES_H
