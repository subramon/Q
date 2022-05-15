#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_instantiate.h"
#include "rs_hmap_chk.h"
#include "rs_hmap_destroy.h"
#include "rs_hmap_del.h"
#include "rs_hmap_get.h"
#include "rs_hmap_put.h"
#include "rs_hmap_int_types.h" // CUSTOM where key and val are defined 

int
main(
    void
    )
{
  int status = 0;
  // num_frees = num_mallocs = 0; 
  int num_iterations = 8; 
  rs_hmap_t hmap; memset(&hmap, 0, sizeof(rs_hmap_t));
  //---------------------------
  rs_hmap_config_t C; memset(&C, 0, sizeof(rs_hmap_config_t));
  C.min_size = 32;
  C.max_size = 0;
  status = rs_hmap_instantiate(&hmap, &C, "libhmap_case1"); 
  cBYE(status);
#ifdef XXXX 
  //-----------------------------------------------------------
  rs_hmap_val_t sum_val = 0;
  uint32_t nitems = 1048576;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    rs_hmap_val_t val = iter+1;
    sum_val += val;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      rs_hmap_key_t key = (i+1)*10; 
      rs_hmap_val_t chk_val; 
      status = hmap_put(&hmap, &key, &val); cBYE(status);
      status = hmap_get(&hmap, &key, &chk_val, &is_found, &where_found);
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
      if ( chk_val != sum_val ) { go_BYE(-1); }
      if ( iter == 0 ) { 
        if ( hmap.nitems != (i+1) ) { go_BYE(-1); } 
      }
      else { 
        if ( hmap.nitems != nitems ) { go_BYE(-1); }
      }
    }
    if ( hmap.nitems < 65536 ) { 
      // This is an expensive check 
      status = hmap_chk(&hmap); cBYE(status); 
    }
  }
  // The following works only for this particular Key/Val updates
  uint32_t chk_n1 = 0, chk_n2 = 0;
  for ( uint32_t i = 0; i < hmap.size; i++ ) { 
    if ( hmap.bkts[i].key != 0 ) { chk_n1++; }
    if ( hmap.bkts[i].val != 0 ) { chk_n2++; }
    if ( hmap.bkt_full[i] ) { 
      if ( hmap.bkts[i].key == 0 ) { 
        go_BYE(-1); }
      if ( hmap.bkts[i].val == 0 ) { go_BYE(-1); }
    }
    else {
      if ( hmap.bkts[i].key != 0 ) { go_BYE(-1); }
      if ( hmap.bkts[i].val != 0 ) { go_BYE(-1); }
    }
  }
  if ( chk_n1 != hmap.nitems ) { go_BYE(-1); }
  if ( chk_n2 != hmap.nitems ) { go_BYE(-1); }

  // Now delete the items one by one 
  // All items have the same value: let us determine what it is 
  // sum_val is the value for all keys 
  sum_val = 0;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    rs_hmap_val_t val = iter+1;
    sum_val += val;
  }
  uint32_t chk_nitems = nitems; 
  for ( uint32_t i = 0; i < nitems; i++ ) {
    bool is_found;
    rs_hmap_key_t key = (i+1)*10; 
    // printf("%d deleteting %lu \n", i, key);
    rs_hmap_val_t chk_val; 
    status = hmap_del(&hmap, &key, &chk_val, &is_found); cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
    if ( chk_val != sum_val ) { go_BYE(-1); }
    chk_nitems--; 
    if ( hmap.nitems != chk_nitems ) { go_BYE(-1); } 
    if ( hmap.nitems < 65536 ) { 
      // This is an expensive check 
      status = hmap_chk(&hmap); cBYE(status); 
    }
    // delete again just for kicks 
    status = hmap_del(&hmap, &key, &chk_val, &is_found); cBYE(status);
    if ( is_found ) { go_BYE(-1); }
    if ( chk_val != 0 ) { go_BYE(-1); }
  }
  if ( hmap.nitems != 0 ) { go_BYE(-1); } 
  // Now delete items again. Should have no impact 
  for ( uint32_t i = 0; i < nitems; i++ ) {
    bool is_found;
    rs_hmap_key_t key = (i+1)*10; 
    rs_hmap_val_t chk_val; 
    status = hmap_del(&hmap, &key, &chk_val, &is_found); cBYE(status);
    if ( is_found ) { go_BYE(-1); }
    if ( hmap.nitems != 0 ) { go_BYE(-1); } 
  }
  //--------------------------------------------------

  printf("hmap occupancy = %d \n", hmap.nitems);
  printf("hmap size      = %d \n", hmap.size);
  hmap_destroy(&hmap);
  //printf("num_frees = %d \n", num_frees);
  //printf("num_mallocs = %d \n", num_mallocs);

#endif
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  rs_hmap_destroy(&hmap);
  return status;
}
