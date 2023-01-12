#ifndef __RS_HMAP_STRUCT_H
#define __RS_HMAP_STRUCT_H

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <dlfcn.h>
#include "rsx_types.h"
#include "rs_hmap_config.h"

typedef int (* chk_fn_t)(
    void *ptr_hmap
    );
typedef int (* del_fn_t)(
    void *ptr_hmap, 
    const void * const in_ptr_key, 
    void * in_ptr_val,
    bool *ptr_is_found
    );
typedef void (* destroy_fn_t)(
    void *ptr_hmap
    );
typedef int (* get_fn_t)(
    void *ptr_hmap, 
    const void * const in_ptr_key, 
    void *in_ptr_val,
    bool *ptr_is_found,
    uint32_t *ptr_where_found
    );
typedef int (* freeze_fn_t)(
    void *ptr_hmap, 
    const char * const dir,
    const char * const meta_file_name,
    const char * const bkts_file_name,
    const char * const full_file_name
    );
typedef int (* merge_fn_t)(
    void *ptr_dst_hmap, 
    const void * const ptr_src_hmap
    );
typedef int (* pr_fn_t)(
    void *ptr_hmap, 
    FILE *fp
    );
typedef int (* put_fn_t)(
    void *ptr_hmap, 
    const void * const key, 
    const void * const val
    );
typedef int (* row_dmp_fn_t)(
    void *ptr_hmap, 
    const char * const file_name, 
    void  **ptr_K,
    uint32_t *ptr_nK
    );
// Following need custom implementations
typedef int (*bkt_chk_fn_t )(
    const void * const, 
    int n
    );
typedef bool (*key_cmp_fn_t )(
    const void * const , 
    const void * const 
    );
typedef int(* key_ordr_fn_t)(
    const void *in1, 
    const void *in2
    );
typedef int(* pr_key_fn_t)(
    void *bkts,
    uint32_t idx,
    FILE *fp
    );
typedef int(* pr_val_fn_t)(
    void *bkts,
    uint32_t idx,
    FILE *fp
    );
typedef int (*val_update_fn_t )(
    void *, 
    const void * const
    );


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
  double start_check_val; 
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  rs_hmap_bkt_t  *bkts;  
  bool *bkt_full; 
  uint64_t hashkey;
  rs_hmap_config_t config; // extrernal config 

  chk_fn_t chk;
  del_fn_t del;
  destroy_fn_t destroy;
  get_fn_t get;
  freeze_fn_t freeze;
  merge_fn_t merge;
  pr_fn_t pr;
  put_fn_t put;
  row_dmp_fn_t row_dmp;

  bkt_chk_fn_t bkt_chk; /* function to perform logical 
                              consistency checks on contents of bucket */
  key_cmp_fn_t key_cmp; // function to compare 2 keys
  key_ordr_fn_t key_ordr;
  pr_key_fn_t pr_key;
  pr_val_fn_t pr_val;
  val_update_fn_t val_update; // function to update value 

  double stop_check_val; 
} rs_hmap_t;

#endif // __RS_HMAP_STRUCT_H
