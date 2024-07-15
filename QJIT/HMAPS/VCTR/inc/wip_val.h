#include <stdbool.h>
#include "qtypes.h"

#ifndef __VCTR_RS_HMAP_VAL_TYPE_H
#define __VCTR_RS_HMAP_VAL_TYPE_H

#define MAX_LEN_VCTR_NAME 31 // for debugging 

// some of the fields in the struct do not change once the vector 
// has at least one element in it. We call them WRITE-ONCE. 
typedef struct _vctr_meta_t {
  char name[MAX_LEN_VCTR_NAME+1];
  uint64_t num_elements;
  // num_chnks == (max_chnk_idx - min_chnk_idx +1), except
  // when num_elements == 0 in which case it is 0 
  uint32_t min_chnk_idx;
  uint32_t max_chnk_idx;
  uint32_t max_num_in_chnk; // WRITE-ONCE
  uint32_t width; // WRITE-ONCE
  uint32_t ref_count; // reference count 
  // chunk size = max_num_in_chnk * width 
  // START: Following for early deallocation of resources
  bool is_memo; uint32_t memo_len; 
  bool is_killable; uint16_t num_kill_ignore;
  bool is_early_freeable; uint16_t num_free_ignore; 
  // STOP : Following for early deallocation of resources

  qtype_t qtype; // WRITE-ONCE
  bool is_eov;   // true => no appends allowed
  bool is_persist;   // l2 should not be deleted on vector delete

  bool is_writable;   // false => no changes allowed
  bool is_err; // true => error in creating vector => all the normal checks will not apply.
  bool is_lma; // true => there exists a file that allows Linear Memory Access (lma) 

  int num_readers; // for lma 
  int num_writers; // for lma 
  char *X; // for lma 
  size_t nX; // for lma 
} vctr_meta_t;
typedef vctr_meta_t vctr_rs_hmap_val_t;
#endif //  __VCTR_RS_HMAP_VAL_TYPE_H
