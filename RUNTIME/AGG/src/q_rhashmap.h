/*
 * Copyright (c) 2017 Mindaugas Rasiukevicius <rmind at noxt eu>
 * All rights reserved.
 *
 * Use is subject to license terms, as specified in the LICENSE file.
 */

#ifndef _Q_RHASHMAP___KV__
#define _Q_RHASHMAP___KV__

#define Q_RHM_SET 1
#define Q_RHM_ADD 2

#include <assert.h>
#include <inttypes.h>
#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>
#include "q_macros.h"

#include "_q_rhashmap_struct___KV__.h"
/*
#ifndef _Q_RHASHMAP_STRUCT___KV__
#define _Q_RHASHMAP_STRUCT___KV__

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
*/

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
extern int 
q_rhashmap_putn___KV__(
    q_rhashmap___KV___t *hmap,  // INPUT
    int update_type, // INPUT
    __KEYTYPE__ *keys, // INPUT [nkeys] 
    uint32_t *hashes, // INPUT [nkeys]
    uint32_t *locs, // INPUT [nkeys] -- starting point for probe
    uint8_t *tids, // INPUT [nkeys] -- thread who should work on it
    int nT,
    __VALTYPE__ *vals, // INPUT [nkeys] 
    uint32_t nkeys, // INPUT
    uint8_t *is_founds // OUTPUT [nkeys bits] TODO: Change from byte to bit 
    );
extern int 
q_rhashmap_getn___KV__(
    q_rhashmap___KV___t *hmap, // INPUT
    __KEYTYPE__ *keys, // INPUT: [nkeys] 
    uint32_t *hashes, // INPUT [nkeys]
    uint32_t *locs, // INPUT [nkeys] 
    __VALTYPE__ *vals, // OUTPUT [nkeys] 
    uint32_t nkeys // INPUT 
    // TODO P4 we won't do is_found for the first implementation
    );
#endif
