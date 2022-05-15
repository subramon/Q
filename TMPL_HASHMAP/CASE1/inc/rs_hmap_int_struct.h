#ifndef __RS_HMAP_INT_STRUCT_H
#define __RS_HMAP_INT_STRUCT_H

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>
#include "rs_hmap_int_types.h" 

typedef struct _rs_hmap_kv_t { 
  rs_hmap_key_t key;
  rs_hmap_val_t val;
} rs_hmap_kv_t;

typedef bool (*key_cmp_fn_t )(const void * const , const void * const );
typedef int (*val_update_fn_t )(void *, const void * const);

// Configs set internally
typedef struct _rs_hmap_int_config_t { 

  key_cmp_fn_t key_cmp_fn; // function to compare 2 keys
  val_update_fn_t val_update_fn; // function to update value 

} rs_hmap_int_config_t; 

typedef struct _bkt_t { 
  rs_hmap_key_t key; 
  uint16_t psl; // probe sequence length 
  rs_hmap_val_t val;    // value that is aggregated, NOT input value
} bkt_t;

#endif // __RS_HMAP_INT_STRUCT_H
