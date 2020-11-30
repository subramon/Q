#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "hmap_struct.h"
#include "rdtsc.h"
#include "spooky_struct.h"
#include "spooky_hash.h"
#include "hmap_chk.h"

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
    hmap_t *ptr_hmap
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
    }
    else {
      if ( bkts[i].len != 0 ) { go_BYE(-1); }
      if ( bkts[i].hash != 0 ) { go_BYE(-1); }
    }
    // TODO: What about psl?
    // TODO: What about cnt?
  }

BYE:
  free_if_non_null(hashes);
  return status;
}
