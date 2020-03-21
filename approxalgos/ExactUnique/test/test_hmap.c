#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_destroy.h"
#include "hmap_put.h"

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
  status = hmap_instantiate(&hmap, minsize, maxsize); cBYE(status);
  for ( uint32_t i = 0; i < (maxsize *  0.75); i++ ) {
    status = hmap_put(&hmap, i, 0); cBYE(status);
    if ( hmap.nitems != (i+1) ) { go_BYE(-1); }
  }
  printf("occupancy = %d \n", hmap.nitems);
  hmap_destroy(&hmap);
BYE:
  return status;
}
