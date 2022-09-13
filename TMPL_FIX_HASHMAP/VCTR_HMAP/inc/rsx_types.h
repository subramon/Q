#ifndef __RSX_TYPES_H
#define __RSX_TYPES_H
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <inttypes.h>
#include "qtypes.h"
typedef uint32_t vctr_rs_hmap_key_t; // a vector is identified by a number

#define MAX_LEN_VCTR_NAME 15 // for debugging 

typedef struct _vctr_meta_t {
  char name[MAX_LEN_VCTR_NAME+1];
  uint64_t num_elements;
  uint32_t num_chnks;
  uint32_t max_num_in_chnk;
  uint32_t width;
  // Note that chunk size = max_num_in_chnk * width 
  int memo_len;
  qtype_t qtype;
  bool is_eov;   // true => no appends allowed
  bool is_persist;   // l2 should not be deleted on vector delete
  bool is_writable;   // false => no changes allowed
  bool is_trash; // true => marked for garbage collection 
  // Much more to put in here
} vctr_meta_t;
typedef vctr_meta_t vctr_rs_hmap_val_t;
#endif //  __HMAP_INT_TYPES_H
