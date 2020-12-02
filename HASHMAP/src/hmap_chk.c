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
hmap_pr(
    hmap_t *ptr_hmap
    )
{
  int status = 0;
  bkt_t *bkts = ptr_hmap->bkts;
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( bkts[i].key != NULL ) {
      printf("%d,%s,%d\n", i, (char *)bkts[i].key, bkts[i].len);
    }
  }
  printf("==================\n");
BYE:
  return status;
}
//-----------------------------------------------------
int
hmap_chk(
    hmap_t *ptr_hmap,
    bool reset_called
    )
{
  int status = 0;
  chk_t *hashes = NULL;
  // status = hmap_pr(ptr_hmap); cBYE(status);
  // check that number of items is correct
  uint32_t chk_nitems = 0;
  bkt_t *bkts = ptr_hmap->bkts;
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( bkts[i].key != NULL ) {
      chk_nitems++;
    }
  }
  if ( ptr_hmap->nitems != chk_nitems ) { go_BYE(-1); }
  // check that each key is unique 
  hashes = malloc(chk_nitems * sizeof(chk_t));
  return_if_malloc_failed(hashes);
  memset(hashes, 0, chk_nitems * sizeof(chk_t));
  uint32_t hash_cnt = 0;
  uint64_t seed = RDTSC() ^ random();
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( bkts[i].key != NULL ) {
      hashes[hash_cnt].hash = spooky_hash64(bkts[i].key, bkts[i].len, seed);
      hashes[hash_cnt].idx = i;
      hash_cnt++;
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
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( bkts[i].key != NULL ) {
      if ( bkts[i].len == 0 ) { go_BYE(-1); }
      if ( bkts[i].hash == 0 ) { go_BYE(-1); }
      if ( bkts[i].val == NULL ) { go_BYE(-1); }
    }
    else {
      if ( bkts[i].val != NULL ) { go_BYE(-1); }
      if ( bkts[i].len != 0 ) { go_BYE(-1); }
      if ( bkts[i].hash != 0 ) { 
        go_BYE(-1); }
      if ( !reset_called ) { 
        if ( bkts[i].cnt != 0 ) { go_BYE(-1); }
      }
    }
    // TODO: What about psl?
  }
  //-- make sure no holes between initial probe_loc and current position
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( bkts[i].key == NULL ) { continue; }
    void *val; bool is_found; uint32_t where_found; 
    void *key    = bkts[i].key;
    uint16_t len = bkts[i].len;
    status = hmap_get(ptr_hmap, key, len, &val, &is_found, 
        &where_found, NULL);
    cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
    if ( ( is_found ) && ( val == NULL ) ) { go_BYE(-1); }
    if ( ( !is_found ) && ( val != NULL ) ) { go_BYE(-1); }
    uint32_t hash = set_hash(key, len, ptr_hmap, NULL);
    uint32_t probe_loc = set_probe_loc(hash, ptr_hmap, NULL);
    if ( probe_loc == i ) { 
      // this key was placed with no searching 
      continue;
    }
    uint32_t start_from = i;
    for ( uint32_t num_searches = 0 ; ; num_searches++ ) { 
      if ( num_searches == ptr_hmap->size ) { go_BYE(-1); }
      if ( bkts[start_from].key == NULL ) { 
        go_BYE(-1); }
      if ( start_from == 0 ) { 
        start_from = ptr_hmap->size - 1;
      }
      else {
        start_from--;
      }
      if ( start_from == probe_loc ) { break; }
    }
  }
BYE:
  free_if_non_null(hashes);
  return status;
}
