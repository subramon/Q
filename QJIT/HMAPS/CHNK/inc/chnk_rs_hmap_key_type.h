#ifndef __CHNK_RS_HMAP_KEY_TYPE_H
#define __CHNK_RS_HMAP_KEY_TYPE_H
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <inttypes.h>
#include "qtypes.h"
typedef struct _chnk_rs_hmap_key_t {
  uint32_t vctr_uqid;
  uint32_t chnk_idx;
} chnk_rs_hmap_key_t;

#endif //  __CHNK_RS_HMAP_KEY_TYPE_H
