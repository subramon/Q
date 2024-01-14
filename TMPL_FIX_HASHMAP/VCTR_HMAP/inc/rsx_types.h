#ifndef __RSX_TYPES_H
#define __RSX_TYPES_H
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <inttypes.h>
#include "qtypes.h"
typedef uint32_t vctr_rs_hmap_key_t; // a vector is identified by a number

#define MAX_LEN_VCTR_NAME 31 // for debugging 

typedef struct _vctr_meta_t {
  char name[MAX_LEN_VCTR_NAME+1];
  uint64_t num_elements;
  uint32_t num_chnks;
  uint32_t max_chnk_idx;
  // max_chnk_idx == num_chnks-1 except (possibly) when memo_len >= 1
  uint32_t max_num_in_chnk;
  uint32_t width;
  uint32_t ref_count; // reference count 
  // Note that chunk size = max_num_in_chnk * width 
  // START: Following for early deallocation of resources
  int memo_len; // -1 => memo all 
  int num_lives_kill; // useful to delete temporary vectors
  int num_lives_free; // useful to free chunks when we don;t know memo_len
  int num_early_freed; // number of chunks which *were* early freed
  bool is_early_freeable; 
  bool is_killable; 
  // STOP : Following for early deallocation of resources

  qtype_t qtype;
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
#endif //  __HMAP_INT_TYPES_H
