#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_chk.h"
#include "hmap_del.h"
#include "hmap_destroy.h"
#include "hmap_mput.h"
#include "hmap_put.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  hmap_t hmap; memset(&hmap, 0, sizeof(hmap_t));
  dbg_t dbg; memset(&dbg, 0, sizeof(dbg_t));
  hmap_config_t config; memset(&config, 0, sizeof(hmap_config_t));
  hmap_multi_t M; memset(&M, 0, sizeof(hmap_multi_t));

  int max_key_len = 8;

  char **keys = NULL;
  val_t *vals = NULL;
  uint16_t *lens = NULL;

  uint32_t n1 = 1000; // batch for mput
  uint32_t n2 = 100; // num_iterations; 
  uint32_t n3 = 2 * n1 * log(n1); // range of keys 

  config.min_size = n3 / HIGH_WATER_MARK;
  config.max_size = 2*config.min_size;
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  //-----------------------------
  M.num_at_once = n1 / 4; 
  int n = M.num_at_once;
  M.idxs = malloc(n * sizeof(uint32_t));
  M.hashes = malloc(n * sizeof(uint32_t));
  M.locs = malloc(n * sizeof(uint32_t));
  M.tids = malloc(n * sizeof(uint8_t));
  M.exists = malloc(n * sizeof(bool));
  //-----------------------------

  keys = malloc(n1 * sizeof(char *));
  return_if_malloc_failed(keys); 
  for ( uint32_t i = 0; i < n1; i++ ) {
    keys[i] = malloc(max_key_len * sizeof(char));
    return_if_malloc_failed(keys[i]); 
  }
  //--------------------------------------
  lens = malloc(n1 * sizeof(uint16_t));
  return_if_malloc_failed(lens); 
  //--------------------------------------
  vals = malloc(n1 * sizeof(val_t));
  return_if_malloc_failed(vals); 
  //--------------------------------------

  for ( uint32_t i = 0; i < n2; i++ ) {
    // set up a batch of keys 
    for ( uint32_t j = 0; j < n1; j++ ) {
      memset(keys[j], 0, max_key_len);
      sprintf(keys[j], "%d", (int)(random() % n3)); 
      lens[j] = strlen(keys[j]);
      vals[j] = (i*n1) + j;
    }
    // do an mput 
    status = hmap_mput(&hmap, &M, (void **)keys, n1, lens, vals); 
    cBYE(status);
    if ( hmap.nitems > n3 ) { go_BYE(-1); }
    status = hmap_chk(&hmap, false); cBYE(status);
  }
  hmap_destroy(&hmap);
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  if ( hmap.nitems != 0 ) { go_BYE(-1); }
  // Delete every batch of keys entered 
  for ( uint32_t i = 0; i < n2; i++ ) {
    // set up a batch of keys 
    for ( uint32_t j = 0; j < n1; j++ ) {
      memset(keys[j], 0, max_key_len);
      sprintf(keys[j], "%d", (int)(random() % n3)); 
      lens[j] = strlen(keys[j]);
      vals[j] = (i*n1) + j;
    }
    // do an mput 
    status = hmap_mput(&hmap, &M, (void **)keys, n1, lens, vals); 
    cBYE(status);
    if ( hmap.nitems > n3 ) { go_BYE(-1); }
    status = hmap_chk(&hmap, false); cBYE(status);
    // delete all of them 
    for ( uint32_t j = 0; j < n1; j++ ) {
      val_t chk_val;
      bool is_found;
      status = hmap_del(&hmap, keys[j], lens[j], &chk_val, &is_found, NULL);
      cBYE(status);
    }
    if ( hmap.nitems != 0 ) { go_BYE(-1); }
    status = hmap_chk(&hmap, false); cBYE(status);
  }
  fprintf(stdout, "Test %s completed successfully\n", argv[0]); 
BYE:
  free_if_non_null(M.idxs);
  free_if_non_null(M.hashes);
  free_if_non_null(M.locs);
  free_if_non_null(M.tids);
  free_if_non_null(M.exists); 
  if ( keys != NULL ) { 
    for ( uint32_t i = 0; i < n1; i++ ) {
      free_if_non_null(keys[i]); 
    }
  }
  free_if_non_null(keys); 
  free_if_non_null(lens);
  free_if_non_null(vals);
  hmap_destroy(&hmap);
}
