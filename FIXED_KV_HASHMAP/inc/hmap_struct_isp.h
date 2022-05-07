#ifndef __HMAP_STRUCT_H
#define __HMAP_STRUCT_H

// hmap_multi_t is used to avoid recomputing stuff in hmap_mput
typedef struct _hmap_multi_t { 
  int num_procs; 
  int num_at_once; 
  uint32 *idxs;   // [num_at_once ]
  uint32 *hashes; // [num_at_once ]
  uint32 *locs;   // [num_at_once ]
  int8 *tids;   // [num_at_once ]
  bool *exists;   // [num_at_once ]
  bool *set; // [num_at_once ] // TODO For debugging, delete later
  uint16 *m_key_len; // [num_at_once ] 
  void **m_key; // [num_at_once] 
} hmap_multi_t;

typedef struct _hmap_config_t { 
  uint32 min_size;
  uint32 max_size;
  uint64 max_growth_step;
  float low_water_mark;
  float high_water_mark;
} hmap_config_t; 

typedef struct _dbg_t { 
  uint32 hash;
  uint32 probe_loc;
  uint64 num_probes;
} dbg_t; 

typedef struct _bkt_t { 
  void    *key; // keys
  uint64 hash; // hash of key
  uint16 len; // length of key
  uint16 psl; // probe sequence length 
  void * val;    // value that is aggregated, NOT input value
} bkt_t;

typedef struct _hmap_t {
  uint32 size;
  uint32 nitems;
  uint64 divinfo;
  bkt_t  *bkts;  
  uint64 hashkey;
  hmap_config_t config;
} hmap_t;

#endif
