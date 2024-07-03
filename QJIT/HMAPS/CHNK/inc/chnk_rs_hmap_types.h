#ifndef __CHNK_RS_HMAP_TYPES_H
#define __CHNK_RS_HMAP_TYPES_H
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <inttypes.h>
#include "qtypes.h"
typedef struct _chnk_rs_hmap_key_t {
  uint32_t vctr_uqid;
  uint32_t chnk_idx;
} chnk_rs_hmap_key_t;

typedef struct _chnk_rs_hmap_val_t {
  uint16_t num_readers;
  uint16_t num_writers;
  uint32_t num_elements;
  //-----
  qtype_t qtype; // backward reference for debugging 
  bool     l2_exists;
  // Sometimes we know that a vector is not needed before chunk n
  // In that case, we do NOT delete the chunk but we delete its resources
  // and mark was_early_freed = true;
  // Cannot save a vector if any of its chunks have was_early_freed == true
  bool was_early_freed; 
  int num_lives_left; // if is_early_freeable in vector, then this is 
  // initialized to num_lives_free
  uint32_t size; // we do not expect a chunk to exceed 4G, a vector might
  //-----
  char *l1_mem;
  uint64_t touch_time; // most recent time when chunk was accessed
} chnk_rs_hmap_val_t;
#endif //  __CHNK_RS_HMAP_TYPES_H

/*
 * L1 refers to RAM
 * L2 refers to local machine file system
 * L3 refers to off machine storage. Currently, this is assumed to be a file but
 * it could be an S3 bucket or something else.
 * */
