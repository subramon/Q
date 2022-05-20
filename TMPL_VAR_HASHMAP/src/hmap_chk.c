#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "hmap_struct.h"
#include "rdtsc.h"
#include "spooky_struct.h"
#include "spooky_hash.h"
#include "hmap_aux.h"
#include "hmap_chk.h"
#include "hmap_get.h"

typedef struct _chk_t { 
  uint32_t idx;
  uint64_t hash;
} chk_t; 
//-----------------------------------------------------
int
hmap_chk(
    hmap_t *H
    )
{
  int status = 0;
  void *val = NULL;
  chk_t *hashes = NULL;
  // status = hmap_pr(H); cBYE(status);
  // check that number of items is correct
  uint32_t chk_nitems = 0;
  bkt_t *bkts = H->bkts;
  for ( uint32_t i = 0; i < H->size; i++ ) { 
    if ( bkts[i].key != NULL ) {
      chk_nitems++;
    }
  }
  if ( H->nitems != chk_nitems ) { go_BYE(-1); }
  // check that each key is unique 
  hashes = malloc(chk_nitems * sizeof(chk_t));
  return_if_malloc_failed(hashes);
  memset(hashes, 0, chk_nitems * sizeof(chk_t));
  uint32_t hash_cnt = 0;
  uint64_t seed = RDTSC() ^ random();
  for ( uint32_t i = 0; i < H->size; i++ ) { 
    void * key = bkts[i].key;
    if ( key != NULL ) {
      uint16_t len_to_hash; char *str_to_hash = NULL; bool free_to_hash;
      status = H->key_hash(key, &str_to_hash, &len_to_hash, &free_to_hash); 
      hashes[hash_cnt].hash = spooky_hash64(str_to_hash, len_to_hash, seed);
      hashes[hash_cnt].idx = i;
      hash_cnt++;
      if ( free_to_hash ) { free(str_to_hash); str_to_hash = NULL; }
    }
  }
  if ( hash_cnt != chk_nitems ) { go_BYE(-1); }
  for ( uint32_t i = 0; i < chk_nitems; i++ ) { 
    if ( hashes[i].hash == 0 ) { go_BYE(-1); }
    for ( uint32_t j = i+1; j < chk_nitems; j++ ) { 
      if ( hashes[i].hash == hashes[j].hash ) { 
        fprintf(stderr, "Positions %lu and %lu have same hash \n",
            (unsigned long)hashes[i].idx, (unsigned long)hashes[j].idx);
        go_BYE(-1);
      }
    }
  }
  //-----------------------
  //-- check that each record is internally consistent 
  for ( uint32_t i = 0; i < H->size; i++ ) { 
    if ( bkts[i].key != NULL ) {
      uint16_t len_i = H->key_len(bkts[i].key);
      if ( len_i == 0 ) { go_BYE(-1); }
      if ( bkts[i].hash == 0 ) { go_BYE(-1); }
      if ( bkts[i].val == NULL ) { go_BYE(-1); }
    }
    else {
      if ( bkts[i].val != NULL ) { go_BYE(-1); }
      if ( bkts[i].hash != 0 ) { go_BYE(-1); }
    }
    // TODO: What about psl?
  }
  //-- make sure no holes between initial probe_loc and current position
  for ( uint32_t i = 0; i < H->size; i++ ) { 
    if ( bkts[i].key == NULL ) { continue; }
    val = NULL; bool is_found; uint32_t where_found; 
    void *key    = bkts[i].key;
    status = hmap_get(H, key, &val, &is_found, 
        &where_found, NULL);
    cBYE(status);
    if ( !H->key_chk(key) ) { go_BYE(-1); }
    if ( !H->val_chk(val) ) { go_BYE(-1); }
    if ( !is_found ) { go_BYE(-1); }
    if ( ( is_found ) && ( val == NULL ) ) { go_BYE(-1); }
    if ( ( !is_found ) && ( val != NULL ) ) { go_BYE(-1); }
    free_if_non_null(val); 


    uint16_t len_to_hash; char *str_to_hash = NULL; bool free_to_hash;
    status = H->key_hash(key, &str_to_hash, &len_to_hash, &free_to_hash); 
    register uint32_t hash = set_hash(str_to_hash, len_to_hash, 
        H, NULL); 
    if ( free_to_hash ) { free(str_to_hash); str_to_hash = NULL; }

    uint32_t probe_loc = set_probe_loc(hash, H, NULL);
    if ( probe_loc == i ) { 
      // this key was placed with no searching 
      continue;
    }
    uint32_t search_idx = probe_loc;
    for ( uint32_t num_searches = 0 ; ; num_searches++ ) { 
      if ( search_idx == H->size ) { search_idx = 0; }
      if ( search_idx == where_found ) { break; }
      if ( num_searches == H->size ) { go_BYE(-1); }
      if ( bkts[search_idx].key == NULL ) { 
        go_BYE(-1); 
      }
      search_idx++; 
    }
    free_if_non_null(val);
  }
BYE:
  free_if_non_null(hashes);
  free_if_non_null(val);
  return status;
}
