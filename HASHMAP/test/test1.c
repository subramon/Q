#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_chk.h"
#include "hmap_del.h"
#include "hmap_destroy.h"
#include "hmap_get.h"
#include "hmap_put.h"

#include "val_struct_1.h"
int num_frees; int num_mallocs;
int
main(
    void
    )
{
  int status = 0;
  // num_frees = num_mallocs = 0; 
  int num_iterations = 3; 
  hmap_t hmap; memset(&hmap, 0, sizeof(hmap_t));
  dbg_t dbg; memset(&dbg, 0, sizeof(dbg_t));
  hmap_config_t config; memset(&config, 0, sizeof(hmap_config_t));
  config.min_size = 32;
  config.max_size = 8*config.min_size;
  bool malloc_key = true;
  bool reset_called = false;
  char keybuf[16];

  uint32_t occupancy = 0;
  uint32_t nitems = config.max_size * 0.75;
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    agg_val_t *ptr_agg_val;
    val_t val = iter+1;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      memset(keybuf, 0, 16);
      sprintf(keybuf, "%d", i); size_t len = strlen(keybuf);
      status = hmap_put(&hmap, keybuf, len, malloc_key, &val, &dbg); 
      cBYE(status);
      status = hmap_get(&hmap, keybuf, len, (void **)&ptr_agg_val, 
          &is_found, &where_found, &dbg); 
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
      if ( *ptr_agg_val != val ) { go_BYE(-1); }
      if ( iter == 0 ) { 
        if ( hmap.nitems != (i+1) ) { go_BYE(-1); } 
      }
      else { 
        if ( hmap.nitems != occupancy ) { go_BYE(-1); }
      }
    }
    if ( iter == 0 ) { 
      occupancy = hmap.nitems;
    }
    printf("Iter = %d, Probes = %" PRIu64 "\n",iter, dbg.num_probes); 
    status = hmap_chk(&hmap, reset_called); cBYE(status); 
  }
  uint32_t n = hmap.nitems;
  printf("occupancy = %d \n", hmap.nitems);
  printf("size      = %d \n", hmap.size);
  // now delete every item (more than once)
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    val_t *ptr_agg_val;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      memset(keybuf, 0, 16);
      sprintf(keybuf, "%d", i); size_t len = strlen(keybuf);
      status = hmap_del(&hmap, keybuf, len, &is_found, &dbg); 
      cBYE(status);

      if ( iter == 0 ) { if ( !is_found ) { go_BYE(-1); } } 
      if ( iter  > 0 ) { if (  is_found ) { go_BYE(-1); } } 

      status = hmap_get(&hmap, keybuf, len, (void **)&ptr_agg_val, 
          &is_found, &where_found, &dbg); 
      cBYE(status);
      if ( is_found ) { go_BYE(-1); }
      if ( ptr_agg_val != NULL ) { go_BYE(-1); }

      if ( iter == 0 ) { if ( hmap.nitems != (n - i - 1) ) { go_BYE(-1); } }
      if ( iter  > 0 ) { if ( hmap.nitems != 0 ) { go_BYE(-1); }  }
    }
    status = hmap_chk(&hmap, reset_called); cBYE(status); 
  }
  hmap_destroy(&hmap);
  //printf("num_frees = %d \n", num_frees);
  //printf("num_mallocs = %d \n", num_mallocs);

  // this test is a bunch of random inserts and deletes 
  // with checks thrown in every so often
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  int n1 = 100000;
  int n2 = 100;
  int n3 = 100;
  for ( int i = 0; i < n1; i++ ) { 
    bool is_found;
    val_t val = 0; 
    memset(keybuf, 0, 16);
    sprintf(keybuf, "%d", (int)(random() % n2)); 
    size_t len = strlen(keybuf);
    if ( ( random() & 0x1 ) == 0 ) { 
      status = hmap_put(&hmap, keybuf, len, malloc_key, &val, &dbg); 
    }
    else {
      status = hmap_del(&hmap, keybuf, len, &is_found, &dbg); 
    }
    cBYE(status);
    if ( ( i % n3 ) == 0 ) {
      status = hmap_chk(&hmap, reset_called); cBYE(status); 
    }
  }


  fprintf(stderr, "Unit test succeeded\n");
BYE:
  hmap_destroy(&hmap);
  return status;
}
