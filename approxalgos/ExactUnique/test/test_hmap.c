#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_destroy.h"
#include "hmap_put.h"
#include "hmap_nitems.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int minsize = 1024;
  int maxsize = 8192;
  hmap_t hmap;
  int occupancy = 0;
  int nitems = maxsize * 0.75;
  status = hmap_instantiate(&hmap, minsize, maxsize); cBYE(status);
  for ( int iter = 0; iter < 10; iter++ ) { 
    for ( int i = 0; i < nitems; i++ ) {
      status = hmap_put(&hmap, i, 0); cBYE(status);
      if ( iter == 0 ) { 
        uint32_t chk; bool chk_is_approx;
        status = hmap_nitems(&hmap, &chk, &chk_is_approx); cBYE(status);
        if ( chk != (i+1) ) { go_BYE(-1); }
        if ( chk_is_approx ) { go_BYE(-1) ;} 
      }
      else { 
        if ( hmap.nitems != occupancy ) { go_BYE(-1); }
      }
    }
    if ( iter == 0 ) { 
      occupancy = hmap.nitems;
    }
    printf("iter = %d \n", iter);
  }
  printf("occupancy = %d \n", hmap.nitems);
  printf("maxsize = %d \n", maxsize);
  hmap_destroy(&hmap);
BYE:
  return status;
}
