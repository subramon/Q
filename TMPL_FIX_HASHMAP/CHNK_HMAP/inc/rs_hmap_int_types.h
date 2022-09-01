#ifndef __HMAP_INT_TYPES_H
#define __HMAP_INT_TYPES_H
#include <stdint.h>
#include "qtypes.h"
typedef uint32_t rs_hmap_key_t; // a chunk is identified by a number

#define MAX_LEN_CHNK_FILE_NAME 63 

typedef struct _chnk_meta_t {
  uint16_t num_readers;
  uint16_t num_writers;
  uint32_t vctr_uqid; // backward reference for debugging 
  uint32_t chnk_idx;  // backward reference for debugging 
  uint32_t num_elements;
  uint32_t size;
  qtype_t qtype; // backward reference for debugging 
  void *l1_mem;
  bool l2_dirty;
  bool l3_dirty;
  char l2_mem[MAX_LEN_CHNK_FILE_NAME+1];
  char l3_mem[MAX_LEN_CHNK_FILE_NAME+1];
  // Much more to put in here
} chnk_meta_t;
typedef chnk_meta_t rs_hmap_val_t;
#endif //  __HMAP_INT_TYPES_H

/*
 * L1 refers to RAM
 * L2 refers to local machine file system
 * L3 refers to off machine storage. Currently, this is assumed to be a file but
 * it could be an S3 bucket or something else.
 * */
