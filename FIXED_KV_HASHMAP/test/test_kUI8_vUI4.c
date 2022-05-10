#include "hmap_common.h"
#include "hmap_struct.h"
#include "hmap_instantiate.h"
#include "hmap_chk.h"
#include "hmap_destroy.h"
#include "hmap_del.h"
#include "hmap_get.h"
#include "hmap_put.h"
#include "key_cmp.h"
#include "val_update.h"

int
main(
    void
    )
{
  int status = 0;
  // num_frees = num_mallocs = 0; 
  int num_iterations = 8; 
  hmap_t hmap; memset(&hmap, 0, sizeof(hmap_t));
  //---------------------------
  hmap.config.min_size = 32;
  hmap.config.max_size = 0;
  hmap.config.key_cmp_fn = key_cmp;
  hmap.config.val_update_fn = val_update;
  uint32_t nitems = 1048576;
  status = hmap_instantiate(&hmap); cBYE(status);
  //-----------------------------------------------------------
  hmap_val_t sum_val = 0;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    hmap_val_t val = iter+1;
    sum_val += val;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      hmap_key_t key = (i+1)*10; 
      hmap_val_t chk_val; 
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
    hmap_val_t val = iter+1;
    sum_val += val;
  }
  uint32_t chk_nitems = nitems; 
  for ( uint32_t i = 0; i < nitems; i++ ) {
    bool is_found;
    hmap_key_t key = (i+1)*10; 
    // printf("%d deleteting %lu \n", i, key);
    hmap_val_t chk_val; 
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
    hmap_key_t key = (i+1)*10; 
    hmap_val_t chk_val; 
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

  fprintf(stderr, "Unit test succeeded\n");
BYE:
  hmap_destroy(&hmap);
  return status;
}
