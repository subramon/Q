#ifndef __CHNK_RS_HMAP_VAL_TYPE_H
#define __CHNK_RS_HMAP_VAL_TYPE_H
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <inttypes.h>
#include "qtypes.h"

typedef struct _chnk_rs_hmap_val_t {
  uint16_t num_readers;
  uint16_t num_writers;
  uint32_t num_elements;
  //-----
  qtype_t qtype; // backward reference for debugging 
  bool     l2_exists;
  uint16_t num_free_ignore; // settable only if vector is_early_freeable 
  uint32_t size; // we do not expect a chunk to exceed 4G, a vector might
  //-----
  char *l1_mem;
  uint64_t touch_time; // most recent time when chunk was accessed
} chnk_rs_hmap_val_t;
#endif //  __CHNK_RS_HMAP_VAL_TYPE_H

/*
 * L1 refers to RAM
 * L2 refers to local machine file system
 * L3 refers to off machine storage. Currently, this is assumed to be a file but
 * it could be an S3 bucket or something else.
 * */
