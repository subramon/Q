#ifndef __HMAP_STRUCT_H
#define __HMAP_STRUCT_H

typedef struct _config_t { 
  uint32_t min_size;
  uint32_t max_size;
  uint64_t max_growth_step;
} config_t; 

typedef struct _dbg_t { 
  uint32_t hash;
  uint32_t probe_loc;
  uint64_t num_probes;
} dbg_t; 

typedef uint64_t val_t;
typedef struct _bkt_t { 
  void    *key; // keys
  uint64_t hash; // hash of key
  uint16_t len; // length of key
  uint16_t psl; // probe sequence length 
  uint32_t cnt; // count number of times key was inserted
  val_t val;   
} bkt_t;

typedef struct _hmap_t {
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  bkt_t  *bkts;  
  uint64_t hashkey;
  uint32_t min_size;
  uint32_t max_size;
  uint32_t max_growth_step;
} hmap_t;

#endif
