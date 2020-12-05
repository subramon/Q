#ifndef __HMAP_STRUCT_H
#define __HMAP_STRUCT_H

typedef struct _hmap_multi_t { 
  int num_procs; 
  int num_at_once; 
  uint32_t *idxs;   // [num_at_once ]
  uint32_t *hashes; // [num_at_once ]
  uint32_t *locs;   // [num_at_once ]
  int8_t *tids;   // [num_at_once ]
  bool *exists;   // [num_at_once ]
  bool *set; // [num_at_once ] // TODO For debugging, delete later
} hmap_multi_t;

typedef struct _hmap_config_t { 
  uint32_t min_size;
  uint32_t max_size;
  uint64_t max_growth_step;
  float low_water_mark;
  float high_water_mark;
} hmap_config_t; 

typedef struct _dbg_t { 
  uint32_t hash;
  uint32_t probe_loc;
  uint64_t num_probes;
} dbg_t; 

typedef struct _bkt_t { 
  void    *key; // keys
  uint64_t hash; // hash of key
  uint16_t len; // length of key
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
} hmap_t;

#endif
