#ifndef __HMAP_TYPE_H
#define __HMAP_TYPE_H

typedef struct _bkt_t { 
  uint64_t key; // keys
  uint16_t psl; // probe sequence length 
  uint32_t cnt; // count number of times key was inserted
} bkt_t;

typedef struct _hmap_t {
  uint32_t size;
  uint32_t nitems;
  uint64_t divinfo;
  bkt_t  *bkts;  
  uint64_t hashkey;
  uint32_t minsize;
  uint32_t maxsize;
  bool is_approx; // default false. If we cannot fit an item because resize requires maxsize to be violated, then this becomes true 
} hmap_t;

#endif
