#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rdtsc.h"
#include "hmap_common.h"
#include "hmap_struct.h"
#include "hmap_aux.h"
#include "fasthash.h"
#include "val_pr.h"

uint32_t
mk_hmap_key(
    void
    )
{
  uint64_t r1 = random() ^ RDTSC();
  uint64_t r2 = random() ^ RDTSC();
  return (uint32_t)( r1 | ( r2 << 32 )  );
}

uint32_t
set_hash(
    const void *const key,
    uint16_t len,
    hmap_t *ptr_hmap,
    dbg_t *ptr_dbg
    )
{
  uint32_t hash;
  if ( ( ptr_dbg == NULL ) || ( ptr_dbg->hash == 0 ) ) { 
    // hash = murmurhash3(key, len, ptr_hmap->hashkey);
    hash = fasthash32(key, len, ptr_hmap->hashkey);
  }
  else { 
    hash = ptr_dbg->hash;
  }
  return hash;
}
//----------------------------------------------
uint32_t
set_probe_loc(
    uint32_t hash,
    hmap_t *ptr_hmap,
    dbg_t *ptr_dbg
    )
{
  uint32_t probe_loc;
  register uint32_t size = ptr_hmap->size;
  uint64_t divinfo = ptr_hmap->divinfo;
  if ( ( ptr_dbg == NULL ) || ( ptr_dbg->probe_loc == 0 ) ) { 
    probe_loc = fast_rem32(hash, size, divinfo);
  }
  else {
    probe_loc = ptr_dbg->probe_loc;
  }
  return probe_loc;
}

int
hmap_pr(
    hmap_t *ptr_hmap
    )
{
  int status = 0;
  bkt_t *bkts = ptr_hmap->bkts;
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( bkts[i].key == NULL ) { continue; }
    status = key_pr(bkts[i].key, stdout); cBYE(status);
    status = val_pr(bkts[i].val, stdout); cBYE(status);
  }
BYE:
  return status;
}

void multi_free(
    hmap_multi_t *ptr_M
    )
{
  free_if_non_null(ptr_M->idxs);
  free_if_non_null(ptr_M->hashes);
  free_if_non_null(  ptr_M->locs);
  free_if_non_null(ptr_M->tids);
  free_if_non_null(ptr_M->exists);
  free_if_non_null(ptr_M->set);
  free_if_non_null(ptr_M->m_key_len);
  free_if_non_null(ptr_M->m_key);
}

int multi_init(
    hmap_multi_t *ptr_M,
    int n
    )
{
  int status = 0;
  if ( ptr_M == NULL ) { go_BYE(-1); }
  memset(ptr_M, 0, sizeof(hmap_multi_t));
  if ( n <= 0 ) { go_BYE(-1); }
  ptr_M->num_at_once = n;

  ptr_M->idxs = malloc(n * sizeof(uint32_t));
  return_if_malloc_failed(ptr_M->idxs);

  ptr_M->hashes = malloc(n * sizeof(uint32_t));
  return_if_malloc_failed(ptr_M->hashes);

  ptr_M->locs = malloc(n * sizeof(uint32_t));
  return_if_malloc_failed(  ptr_M->locs);
  
  ptr_M->tids = malloc(n * sizeof(int8_t));
  return_if_malloc_failed(ptr_M->tids);
  
  ptr_M->exists = malloc(n * sizeof(bool));
  return_if_malloc_failed(ptr_M->exists);

  ptr_M->set = malloc(n * sizeof(bool));
  return_if_malloc_failed(ptr_M->set);

  ptr_M->m_key_len = malloc(n * sizeof(uint16_t));
  return_if_malloc_failed(ptr_M->m_key_len);

  ptr_M->m_key = malloc(n * sizeof(void *));
  return_if_malloc_failed(ptr_M->m_key);
BYE:
  if ( status < 0 ) { if ( ptr_M != NULL ) { multi_free(ptr_M); } }
  return status;
}
uint32_t 
prime_geq(
    uint32_t n
    )
{
  if ( n <= 1 ) { return 1; }
  // start with odd number >= n
  uint32_t m;
  if ( n % 0x1 == 1 ) { m = n; } else { m = n + 1 ; }
  for ( ; ; m = m + 2 ) { 
    bool is_prime = true;
    for ( uint32_t k = 3;  k <= sqrt(m); k = k + 2 ) { 
      if ( ( m % k ) == 0 ) { 
        is_prime = false; 
        break;
      }
    }
    if ( is_prime ) { 
      return m;
    }
  }
}
