#ifndef __RS_HMAP_STRUCT_H
#define __RS_HMAP_STRUCT_H

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>

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
// Configs set externally
typedef struct _rs_hmap_config_t { 
  uint32_t min_size;
  uint32_t max_size;
  uint64_t max_growth_step;
  float low_water_mark;
  float high_water_mark;
  char *so_file;
  void *so_handle; 
} rs_hmap_config_t; 

typedef struct _rs_hmap_t {
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  void  *bkts;  
  bool *bkt_full; 
  uint64_t hashkey;
  rs_hmap_config_t config; // extrernal config 
  void * int_config; // internal config 
  put_fn_t put;
  get_fn_t get;
  del_fn_t del;
  chk_fn_t chk;
  destroy_fn_t destroy;
} rs_hmap_t;

#endif // __RS_HMAP_STRUCT_H
