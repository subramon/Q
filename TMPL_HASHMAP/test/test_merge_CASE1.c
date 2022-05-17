#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_instantiate.h"
#include "rs_hmap_chk.h"
#include "rs_hmap_destroy.h"
#include "rs_hmap_del.h"
#include "rs_hmap_get.h"
#include "rs_hmap_put.h"
#include "rs_hmap_merge.h"
#include "rs_hmap_int_types.h" // CUSTOM where key and val are defined 
#include "rs_hmap_int_struct.h" // CUSTOM where key and val are defined 

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  rs_hmap_t H1; memset(&H1, 0, sizeof(rs_hmap_t));
  rs_hmap_t H2; memset(&H2, 0, sizeof(rs_hmap_t));
  rs_hmap_config_t HC; memset(&HC, 0, sizeof(rs_hmap_config_t));
  //---------------------------
  if ( argc != 1  ) { go_BYE(-1); }
  HC.min_size = 32;
  HC.max_size = 0;
  HC.so_file = strdup("libhmap_CASE1.so"); 
  status = rs_hmap_instantiate(&H1, &HC); cBYE(status);
  HC.so_file = strdup("libhmap_CASE1.so"); 
  status = rs_hmap_instantiate(&H2, &HC); cBYE(status);
  //-----------------------------------------------------------
  uint32_t nitems = 1048576;
    // put a bunch of even numbers 
  for ( uint32_t i = 0; i < nitems; i++ ) {
    rs_hmap_key_t key = i*2; 
    rs_hmap_val_t val = i;
    status = H1.put(&H1, &key, &val); cBYE(status);
  }
  if ( H1.nitems != nitems ) { go_BYE(-1); }
  // put a bunch of odd numbers 
  for ( uint32_t i = 0; i < nitems; i++ ) {
    rs_hmap_key_t key = (i*2) + 1 ; 
    rs_hmap_val_t val = i;
    status = H2.put(&H2, &key, &val); cBYE(status);
  }
  if ( H2.nitems != nitems ) { go_BYE(-1); }
  fprintf(stderr, "Unit test %s succeeded\n", argv[0]);
  // add H2 to itself, should be no change in nitems 
  status = rs_hmap_merge(&H2, &H2); cBYE(status);
  if ( H2.nitems != nitems ) { go_BYE(-1); }
  // add H2 to H1, nitems should double
  status = rs_hmap_merge(&H1, &H2); cBYE(status);
  if ( H1.nitems != 2*nitems ) { go_BYE(-1); }
BYE:
  H1.destroy(&H1);
  return status;
}
