#ifndef __HMAP_STRUCT_H
#define __HMAP_STRUCT_H

// START: TO BE PROVIDED BY CUSTOM .so file 
extern int
inval_update(
    void * dst,
    const void * const src
    );
extern int
val_update(
    void * dst,
    const void * const src
    );
extern bool
key_chk(
    const void * const x
    );
extern bool
inval_chk(
    const void * const x
    );
extern bool
val_chk(
    const void * const x
    );
extern int 
key_free(
    void *x
    );
extern int 
val_free(
    void *x
    );
extern void *
inval_copy(
    const  void * const src
    );
extern void *
val_copy(
    const  void * const src
    );
extern int 
key_hash(
    const void * const key,
    char **ptr_str_to_hash,
    uint16_t *ptr_len_to_hash,
    bool *ptr_free_to_hash
    );
extern void *
key_copy(
    const void * const key
    );
extern uint16_t 
key_len(
    const void * const key
    );
extern bool
key_cmp(
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
} hmap_t;

#endif
