#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_chk.h"
#include "hmap_del.h"
#include "hmap_destroy.h"
#include "hmap_get.h"
#include "hmap_put.h"

#include "hmap_custom_types.h"

int
main(
    void
    )
{
  int status = 0;
  int num_iterations = 4; 
  uint32_t nitems = 1024;
  srandom(2097593); 
  hmap_key_t key; memset(&key, 0, sizeof(hmap_key_t));

  hmap_t hmap; memset(&hmap, 0, sizeof(hmap_t));
  dbg_t dbg; memset(&dbg, 0, sizeof(dbg_t));

  hmap_config_t config; memset(&config, 0, sizeof(hmap_config_t));
  config.min_size = 32 ; 
  config.max_size = 0;

  uint32_t occupancy = 0;
  status = hmap_instantiate(&hmap, &config); cBYE(status);

  hmap_val_t    *val    = NULL;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      char keybuf[16];
      hmap_in_val_t in_val = 10 + i;

      memset(&key, 0, sizeof(hmap_key_t));
      memset(keybuf, 0, 16); sprintf(keybuf, "K_%d", i); 
      key.str_val = strdup(keybuf);
      key.str_len = strlen(keybuf);

      status = hmap_put(&hmap, &key, &in_val, &dbg); cBYE(status);
      // check for existence
      status = hmap_get(&hmap, &key, NULL, &is_found, &where_found, &dbg); 
      cBYE(status);
      if ( !is_found ) { 
        printf("Iter %d, i = %d \n", iter, i);
        go_BYE(-1); }

      // get the value 

      status = hmap_get(&hmap, &key, (void **)&val, 
          &is_found, &where_found, &dbg); 
      cBYE(status);
      // Do not free val. You have a pointer to it.
      if ( !is_found ) { go_BYE(-1); }
      if ( val->min_val != in_val ) { go_BYE(-1); }
      if ( val->max_val != in_val ) { go_BYE(-1); }
      if ( val->sum_val != (iter+1)*in_val ) { go_BYE(-1); }
      if ( val->cnt     != iter+1 ) { go_BYE(-1); }
      free_if_non_null(val); 

      if ( iter == 0 ) { 
        if ( hmap.nitems != (i+1) ) { go_BYE(-1); } 
      }
      else { 
        if ( hmap.nitems != occupancy ) { 
          go_BYE(-1); 
        }
      }
      free_if_non_null(key.str_val);
    }
    if ( iter == 0 ) { 
      occupancy = hmap.nitems;
    }
    printf("Iter = %d, Probes = %" PRIu64 "\n",iter, dbg.num_probes); 
    // TODO P0 status = hmap_chk(&hmap); cBYE(status); 
  }
  uint32_t n = hmap.nitems;
  printf("occupancy = %d \n", hmap.nitems);
  printf("size      = %d \n", hmap.size);
  // now delete every item (more than once)
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    hmap_val_t *ptr_agg_val = NULL;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      char keybuf[16];

      memset(&key, 0, sizeof(hmap_key_t));
      memset(keybuf, 0, 16); sprintf(keybuf, "K_%d", i); 
      key.str_val = strdup(keybuf);
      key.str_len = strlen(keybuf);

      status = hmap_del(&hmap, &key, &is_found, &dbg); cBYE(status);

      if ( iter == 0 ) { if ( !is_found ) { go_BYE(-1); } } 
      if ( iter  > 0 ) { if (  is_found ) { go_BYE(-1); } } 

      status = hmap_get(&hmap, &key, (void **)&ptr_agg_val, 
          &is_found, &where_found, &dbg); 
      cBYE(status);
      if ( is_found ) { go_BYE(-1); }
      if ( ptr_agg_val != NULL ) { go_BYE(-1); }

      if ( iter == 0 ) { if ( hmap.nitems != (n - i - 1) ) { go_BYE(-1); } }
      if ( iter  > 0 ) { if ( hmap.nitems != 0 ) { go_BYE(-1); }  }
      free_if_non_null(key.str_val);
    }
    status = hmap_chk(&hmap); cBYE(status); 
  }
  status = hmap_chk(&hmap); cBYE(status); 
  hmap_destroy(&hmap);
  //printf("num_frees = %d \n", num_frees);
  //printf("num_mallocs = %d \n", num_mallocs);

  // this test is a bunch of random inserts and deletes 
  // with checks thrown in every so often
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  int n1 = 100000;
  int n3 = 100;
  int keyidx = 0; 
  int keyrange = 4096;
  for ( int i = 0; i < n1; i++ ) { 
    char keybuf[16];
    bool is_found;
    hmap_in_val_t in_val = i+1;

    memset(keybuf, 0, 16); sprintf(keybuf, "K_%d", keyidx++); 
    if ( keyidx == keyrange ) { keyidx = 0; }
    key.str_val = strdup(keybuf);
    key.str_len = strlen(keybuf);

    uint32_t where_found;
    status = hmap_get(&hmap, &key, (void **)&val, &is_found, &where_found, &dbg); 
    free_if_non_null(val);
    status = hmap_del(&hmap, &key, &is_found, &dbg); cBYE(status);
    // We favor deleting over putting 
    if ( ( random() & 0x11 ) == 0 ) { 
      status = hmap_put(&hmap, &key, &in_val, &dbg); 
    }
    else {
      status = hmap_del(&hmap, &key, &is_found, &dbg); 
    }
    cBYE(status);
    if ( ( i % n3 ) == 0 ) {
      status = hmap_chk(&hmap); cBYE(status); 
      printf("size = %4u, %6d out of %d \n", hmap.nitems, i, n1);
    }
    free_if_non_null(key.str_val);
  }

  fprintf(stderr, "Unit test succeeded\n");
BYE:
  free_if_non_null(key.str_val);
  hmap_destroy(&hmap);
  return status;
}
