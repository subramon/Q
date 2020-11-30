#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_chk.h"
#include "hmap_destroy.h"
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
  char keybuf[16];

  uint32_t occupancy = 0;
  uint32_t nitems = config.max_size * 0.75;
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  hmap.divinfo = 4294967556;
  hmap.hashkey = 1941628627;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    val_t val = iter+1;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      sprintf(keybuf, "%d", i); size_t len = strlen(keybuf);
      status = hmap_put(&hmap, keybuf, len, malloc_key, val, &dbg); 
      cBYE(status);
      if ( iter == 0 ) { 
        if ( hmap.nitems != (i+1) ) { go_BYE(-1); } 
      }
      else { 
        if ( hmap.nitems != occupancy ) { 
          hmap_pr(&hmap);
          go_BYE(-1); }
      }
      status = hmap_chk(&hmap); 
      cBYE(status); 
    }
    if ( iter == 0 ) { 
      occupancy = hmap.nitems;
    }
    printf("Iter = %d, Probes = %" PRIu64 "\n", iter, (long)dbg.num_probes); 
  }
  printf("occupancy = %d \n", hmap.nitems);
  printf("size      = %d \n", hmap.size);
  hmap_destroy(&hmap);
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  hmap_destroy(&hmap);
  return status;
}
