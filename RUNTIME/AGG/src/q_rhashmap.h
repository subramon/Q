/*
 * Copyright (c) 2017 Mindaugas Rasiukevicius <rmind at noxt eu>
 * All rights reserved.
 *
 * Use is subject to license terms, as specified in the LICENSE file.
 */

#ifndef _Q_RHASHMAP___KV__
#define _Q_RHASHMAP___KV__

#define Q_RHM_SET  1
#define Q_RHM_INCR 2

#include <assert.h>
#include <inttypes.h>
#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "q_macros.h"

typedef struct {
  __KEYTYPE__  key; 
  __VALTYPE__ val;
  uint64_t hash: 32;
  uint64_t psl: 16;
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

extern q_rhashmap___KV___t *
q_rhashmap_create___KV__(
    size_t initial_size
    );
extern void
q_rhashmap_destroy___KV__(
    q_rhashmap___KV___t *
    );

extern int
q_rhashmap_get___KV__(
    q_rhashmap___KV___t *, 
    __KEYTYPE__ key,
    __VALTYPE__ *ptr_val,
    bool *ptr_is_found
    );
extern int
q_rhashmap_put___KV__(
    q_rhashmap___KV___t *, 
    __KEYTYPE__ key,
    __VALTYPE__ val,
    int update_type,
    __VALTYPE__ *ptr_oldval
    );
extern int
q_rhashmap_del___KV__(
    q_rhashmap___KV___t *, 
    __KEYTYPE__ key,
    __VALTYPE__ *ptr_oldval,
    bool *ptr_is_found
    );

#endif
