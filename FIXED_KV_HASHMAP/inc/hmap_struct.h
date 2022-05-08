#ifndef __HMAP_STRUCT_H
#define __HMAP_STRUCT_H

#include <stdbool.h>
#include "custom_types.h" // CUSTOM 

typedef bool (*key_cmp_fn_t )(const void * const , const void * const );
typedef int (*val_update_fn_t )(void *, const void * const);

typedef struct _hmap_config_t { 
  uint32_t min_size;
  uint32_t max_size;
  uint64_t max_growth_step;
  float low_water_mark;
  float high_water_mark;
  key_cmp_fn_t key_cmp_fn; // function to compare 2 keys
  val_update_fn_t val_update_fn; // function to update value 
} hmap_config_t; 

typedef struct _bkt_t { 
  hmap_key_t key; 
  uint16_t psl; // probe sequence length 
  hmap_val_t val;    // value that is aggregated, NOT input value
} bkt_t;

typedef struct _hmap_t {
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  bkt_t  *bkts;  
  bool *bkt_full; 
  uint64_t hashkey;
  hmap_config_t config;
} hmap_t;

#endif
