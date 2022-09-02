#ifndef __RS_CONFIG_H
#define __RS_CONFIG_H

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
  char *so_file;
  void *so_handle; 
} rs_hmap_config_t; 

#endif // __RS_CONFIG_H
