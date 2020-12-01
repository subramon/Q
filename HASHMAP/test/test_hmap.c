#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_chk.h"
#include "hmap_del.h"
#include "hmap_destroy.h"
#include "hmap_get.h"
#include "hmap_nitems.h"
#include "hmap_put.h"

int
main(
    void
    )
{
  int status = 0;
  int num_iterations = 3; 
  hmap_t hmap; memset(&hmap, 0, sizeof(hmap_t));
  dbg_t dbg; memset(&dbg, 0, sizeof(dbg_t));
  config_t config; memset(&config, 0, sizeof(config_t));
  config.min_size = 32;
  config.max_size = 8*config.min_size;
  bool malloc_key = true;
  bool reset_called = false;
  char keybuf[16];

  uint32_t occupancy = 0;
  uint32_t nitems = config.max_size * 0.75;
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  hmap.divinfo = 4294967556;
  hmap.hashkey = 1941628627;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    val_t chk_val;
    val_t val = iter+1;
    bool is_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      sprintf(keybuf, "%d", i); size_t len = strlen(keybuf);
      status = hmap_put(&hmap, keybuf, len, malloc_key, val, &dbg); 
      cBYE(status);
      status = hmap_get(&hmap, keybuf, len, &chk_val, &is_found, &dbg); 
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
      if ( chk_val != val ) { go_BYE(-1); }
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
    printf("Iter = %d, Probes = %" PRIu64 "\n",iter,(long)dbg.num_probes); 
    status = hmap_chk(&hmap, reset_called); cBYE(status); 
  }
  uint32_t n = hmap.nitems;
  printf("occupancy = %d \n", hmap.nitems);
  printf("size      = %d \n", hmap.size);
  fprintf(stderr, "Unit test succeeded\n");
  // now delete every item (more than once)
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    val_t chk_val;
    val_t val = num_iterations;
    bool is_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      sprintf(keybuf, "%d", i); size_t len = strlen(keybuf);
      status = hmap_del(&hmap, keybuf, len, &chk_val, &is_found, &dbg); 
      cBYE(status);

      if ( iter == 0 ) { if ( !is_found ) { go_BYE(-1); } } 
      if ( iter  > 0 ) { if (  is_found ) { go_BYE(-1); } } 

      status = hmap_get(&hmap, keybuf, len, &chk_val, &is_found, &dbg); 
      cBYE(status);
      if ( is_found ) { go_BYE(-1); }
      if ( iter == 0 ) { if ( chk_val != val ) { go_BYE(-1); } }

      if ( iter == 0 ) { if ( hmap.nitems != (n - i - 1) ) { go_BYE(-1); } }
      if ( iter  > 0 ) { if ( hmap.nitems != 0 ) { go_BYE(-1); }  }
    }
    status = hmap_chk(&hmap, reset_called); cBYE(status); 
  }
BYE:
  hmap_destroy(&hmap);
  return status;
}
