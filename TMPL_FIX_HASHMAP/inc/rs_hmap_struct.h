#ifndef __RS_HMAP_STRUCT_H
#define __RS_HMAP_STRUCT_H

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>
#include "rsx_types.h"

typedef int(* key_ordr_fn_t)(
    const void *in1, 
    const void *in2
    );
typedef int (* row_dmp_fn_t)(
    void *ptr_hmap, 
    const char * const file_name, 
    void  **ptr_K,
    uint32_t *ptr_nK
    );

typedef int (* del_fn_t)(
    void *ptr_hmap, 
    const void * const in_ptr_key, 
    void * in_ptr_val,
    bool *ptr_is_found
    );
typedef int (* put_fn_t)(
    void *ptr_hmap, 
    const void * const key, 
    const void * const val
    );
typedef int (* get_fn_t)(
    void *ptr_hmap, 
    const void * const in_ptr_key, 
    void *in_ptr_val,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    );
typedef int (* chk_fn_t)(
    void *ptr_hmap
    );
typedef void (* destroy_fn_t)(
    void *ptr_hmap
    );
typedef bool (*key_cmp_fn_t )(
    const void * const , 
    const void * const 
    );
typedef int (*val_update_fn_t )(
    void *, 
    const void * const
    );
typedef int (*bkt_chk_fn_t )(
    const void * const, 
    int n
    );

#include "rs_hmap_config.h"

typedef struct _rs_hmap_kv_t { 
  rs_hmap_key_t key;
  rs_hmap_val_t val;
} rs_hmap_kv_t;

typedef struct _rs_hmap_bkt_t { 
  rs_hmap_key_t key; 
  uint16_t psl; // probe sequence length 
  rs_hmap_val_t val;    // value that is aggregated, NOT input value
} rs_hmap_bkt_t;

typedef struct _rs_hmap_t {
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  rs_hmap_bkt_t  *bkts;  
  bool *bkt_full; 
  uint64_t hashkey;
  rs_hmap_config_t config; // extrernal config 
  put_fn_t put;
  get_fn_t get;
  del_fn_t del;
  chk_fn_t chk;
  row_dmp_fn_t row_dmp;
  key_ordr_fn_t key_ordr;
  destroy_fn_t destroy;
  key_cmp_fn_t key_cmp; // function to compare 2 keys
  val_update_fn_t val_update; // function to update value 
  bkt_chk_fn_t bkt_chk; /* function to perform logical 
                              consistency checks on contents of bucket */
} rs_hmap_t;

#endif // __RS_HMAP_STRUCT_H
