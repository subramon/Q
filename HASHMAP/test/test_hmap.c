#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_destroy.h"
#include "hmap_put.h"
#include "hmap_nitems.h"

int
main(
    void
    )
{
  int status = 0;
  hmap_t hmap;
  dbg_t dbg; memset(&dbg, 0, sizeof(dbg_t));
  config_t config; memset(&config, 0, sizeof(config_t));
  config.min_size = 8;
  config.max_size = 8*8;
  bool steal = false;
  char keybuf[16];

  uint32_t occupancy = 0;
  uint32_t nitems = config.max_size * 0.75;
  status = hmap_instantiate(&hmap, &config); cBYE(status);
  for ( int iter = 0; iter < 10; iter++ ) { 
    printf("Iter = %d \n", iter); 
    val_t val = iter+1;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      sprintf(keybuf, "%d", i); size_t len = strlen(keybuf);
      status = hmap_put(&hmap, keybuf, len, steal, val, &dbg); cBYE(status);
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
  }
  printf("occupancy = %d \n", hmap.nitems);
  printf("size      = %d \n", hmap.size);
  hmap_destroy(&hmap);
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  return status;
}
