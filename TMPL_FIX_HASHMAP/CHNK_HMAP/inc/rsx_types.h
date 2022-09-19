#ifndef __CHNK_TYPES_TYPES_H
#define __CHNK_TYPES_TYPES_H
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <inttypes.h>
#include "qtypes.h"
typedef struct _chnk_rs_hmap_key_t {
  uint32_t vctr_uqid;
  uint32_t chnk_idx;
} chnk_rs_hmap_key_t;

#define MAX_LEN_CHNK_FILE_NAME 63 

typedef struct _chnk_rs_hmap_val_t {
  uint16_t num_readers;
  uint16_t num_writers;
  uint32_t num_elements;
  //-----
  qtype_t qtype; // backward reference for debugging 
  bool     l2_exists; ;
  uint32_t size; // we do not expect a chunk to exceed 4G, a vector might
  //-----
  // Details on converting l2_mem_id to filename elsewhere
  // Much more to put in here
  char *l1_mem;
} chnk_rs_hmap_val_t;
#endif //  __CHNK_TYPES_TYPES_H

/*
 * L1 refers to RAM
 * L2 refers to local machine file system
 * L3 refers to off machine storage. Currently, this is assumed to be a file but
 * it could be an S3 bucket or something else.
 * */
