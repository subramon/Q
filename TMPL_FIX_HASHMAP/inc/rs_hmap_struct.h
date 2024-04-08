#ifndef __${tmpl}_RS_HMAP_STRUCT_H
#define __${tmpl}_RS_HMAP_STRUCT_H

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <dlfcn.h>
#include "rsx_types.h"
#include "rs_hmap_config.h"
#include "rs_hmap_fn_ptrs.h"

typedef struct _${tmpl}_rs_hmap_kv_t { 
  ${tmpl}_rs_hmap_key_t key;
  ${tmpl}_rs_hmap_val_t val;
} ${tmpl}_rs_hmap_kv_t;

typedef struct _${tmpl}_rs_hmap_bkt_t { 
  ${tmpl}_rs_hmap_key_t key; 
  uint16_t psl; // probe sequence length 
  ${tmpl}_rs_hmap_val_t val;    // value that is aggregated, NOT input value
} ${tmpl}_rs_hmap_bkt_t;


typedef struct _${tmpl}_rs_hmap_t {
  double start_check_val; 
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  ${tmpl}_rs_hmap_bkt_t  *bkts;  
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
  resize_fn_t resize;
  insert_fn_t insert;
  row_dmp_fn_t row_dmp;

  bkt_chk_fn_t bkt_chk; /* function to perform logical 
                              consistency checks on contents of bucket */
  key_cmp_fn_t key_cmp; // function to compare 2 keys
  key_ordr_fn_t key_ordr;
  pr_key_fn_t pr_key;
  pr_val_fn_t pr_val;
  set_hash_fn_t set_hash; 
  val_update_fn_t val_update; // function to update value 

  double stop_check_val; 
} ${tmpl}_rs_hmap_t;

#endif // __${tmpl}_RS_HMAP_STRUCT_H
