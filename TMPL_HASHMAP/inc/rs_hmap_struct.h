#ifndef __RS_HMAP_STRUCT_H
#define __RS_HMAP_STRUCT_H

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>

// Configs set externally
typedef struct _rs_hmap_config_t { 
  uint32_t min_size;
  uint32_t max_size;
  uint64_t max_growth_step;
  float low_water_mark;
  float high_water_mark;
  char *so_name;
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
} rs_hmap_t;

#endif // __RS_HMAP_STRUCT_H
