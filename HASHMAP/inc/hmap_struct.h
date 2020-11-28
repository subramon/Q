#ifndef __HMAP_STRUCT_H
#define __HMAP_STRUCT_H

typedef int64_t val_t;
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
  uint32_t minsize;
  uint32_t maxsize;
} hmap_t;

#endif
