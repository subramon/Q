#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_instantiate.h"
#include "rs_hmap_chk.h"
#include "rs_hmap_destroy.h"
#include "rs_hmap_del.h"
#include "rs_hmap_get.h"
#include "rs_hmap_put.h"
#include "rs_hmap_merge.h"

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
  // However, value should double 
  for ( uint32_t i = 0; i < nitems; i++ ) {
    rs_hmap_key_t key = (i*2) + 1 ; 
    rs_hmap_val_t chk_val = 2*i;
    rs_hmap_val_t val = 0; uint32_t where_found; bool is_found;
    status = H2.get(&H2, &key, &val, &is_found, &where_found);
    if ( !is_found ) { go_BYE(-1); }
    if ( val != chk_val ) { go_BYE(-1); }
  }
  // add H2 to H1, nitems should double
  status = rs_hmap_merge(&H1, &H2); cBYE(status);
  if ( H1.nitems != 2*nitems ) { go_BYE(-1); }
  // check that value of H1 items is unchanged 
  for ( uint32_t i = 0; i < nitems; i++ ) {
    rs_hmap_key_t key = i*2;
    rs_hmap_val_t chk_val = i;
    rs_hmap_val_t val = 0; uint32_t where_found; bool is_found;
    status = H1.get(&H1, &key, &val, &is_found, &where_found);
    if ( !is_found ) { go_BYE(-1); }
    if ( val != chk_val ) { go_BYE(-1); }
  }
BYE:
  H1.destroy(&H1);
  H2.destroy(&H2);
  return status;
}
