#ifndef __HMAP_STRUCT_H
#define __HMAP_STRUCT_H
#include <stdint.h>

// START: TO BE PROVIDED BY CUSTOM .so file 
typedef int (*inval_update_fn_t)(
    void * dst,
    const void * const src
    );
typedef int (*val_update_fn_t)(
    void * dst,
    const void * const src
    );
typedef bool (*key_chk_fn_t)(
    const void * const x
    );
typedef bool (*inval_chk_fn_t)(
    const void * const x
    );
typedef bool (*val_chk_fn_t)(
    const void * const x
    );
typedef int (*key_free_fn_t)(
    void *x
    );
typedef int (*val_free_fn_t)(
    void *x
    );
typedef void * (*inval_copy_fn_t)(
    const  void * const src
    );
typedef void * (*val_copy_fn_t)(
    const  void * const src
    );
typedef int (*key_hash_fn_t)(
    const void * const key,
    char **ptr_str_to_hash,
    uint16_t *ptr_len_to_hash,
    bool *ptr_free_to_hash
    );
typedef void * (*key_copy_fn_t)(
    const void * const key
    );
typedef uint16_t (*key_len_fn_t)(
    const void * const key
    );
typedef bool (*key_cmp_fn_t)(
    const void * const ptr_key1,
    const void * const ptr_key2
    );
// STOP: TO BE PROVIDED BY CUSTOM .so file 

typedef struct _hmap_config_t { 
  uint32_t min_size;
  uint32_t max_size;
  uint64_t max_growth_step;
  float low_water_mark;
  float high_water_mark;
  char *so_file; // for custom .so file 
} hmap_config_t; 

typedef struct _dbg_t { 
  uint32_t hash;
  uint32_t probe_loc;
  uint64_t num_probes;
} dbg_t; 

typedef struct _bkt_t { 
  void    *key; // keys
  uint64_t hash; // hash of key
  uint16_t psl; // probe sequence length 
  void * val;    // value that is aggregated, NOT input value
} bkt_t;

typedef struct _hmap_t {
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  bkt_t  *bkts;  
  uint64_t hashkey;
  hmap_config_t config;
  void *so_handle;  // for dlopen() custom .so file 
  //-- START: function pointers to be loaded from custom .so
  inval_update_fn_t inval_update;
  val_update_fn_t val_update;
  key_chk_fn_t key_chk;
  inval_chk_fn_t inval_chk;
  val_chk_fn_t val_chk;
  key_free_fn_t key_free;
  val_free_fn_t val_free;
  inval_copy_fn_t inval_copy;
  val_copy_fn_t val_copy;
  key_hash_fn_t key_hash;
  key_copy_fn_t key_copy;
  key_len_fn_t key_len;
  key_cmp_fn_t key_cmp;
  //-- STOP : function pointers to be loaded from custom .so
} hmap_t;

#endif
