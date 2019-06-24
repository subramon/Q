#ifndef _Q_RHASHMAP_STRUCT___KV__
#define _Q_RHASHMAP_STRUCT___KV__
#include <stdint.h>

typedef struct {
  __KEYTYPE__  key; 
  __VALTYPE__ val;
  uint32_t hash;
  uint16_t psl;
} q_rh_bucket___KV___t;

typedef struct {
  uint32_t size;
  uint32_t nitems;
  uint32_t flags;
  uint64_t divinfo;
  q_rh_bucket___KV___t *buckets;
  uint64_t hashkey;
  uint32_t minsize;
} q_rhashmap___KV___t;

#endif
