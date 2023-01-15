#include "rs_hmap_common.h"
#include "hw_rs_hmap_struct.h"
#include "hw_rs_hmap_instantiate.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  // num_frees = num_mallocs = 0; 
  int num_iterations = 8; 
  hw_rs_hmap_t H;
  //---------------------------
  rs_hmap_config_t HC; memset(&HC, 0, sizeof(rs_hmap_config_t));
  if ( argc != 1 ) { go_BYE(-1); }
  HC.min_size = 32;
  HC.max_size = 0;
  HC.so_file = strdup("libhmap_hw.so"); 
  status = hw_rs_hmap_instantiate(&H, &HC); cBYE(status);
  //-----------------------------------------------------------
  hw_rs_hmap_val_t sum_val = 0;
  uint32_t nitems = 1048576;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    printf("Put Iter = %d \n", iter);
    hw_rs_hmap_val_t val = iter+1;
    sum_val += val;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      hw_rs_hmap_key_t key = (i+1)*10; 
      hw_rs_hmap_val_t chk_val; 
      status = H.put(&H, &key, &val); cBYE(status);
      status = H.get(&H, &key, &chk_val, &is_found, &where_found);
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
      if ( chk_val != sum_val ) { go_BYE(-1); }
      if ( iter == 0 ) { 
        if ( H.nitems != (i+1) ) { go_BYE(-1); } 
      }
      else { 
        if ( H.nitems != nitems ) { go_BYE(-1); }
      }
    }
    if ( H.nitems < 4096 ) { 
      // This is an expensive check 
      status = H.chk(&H); cBYE(status); 
    }
  }
  //--------------------------------------------------
  // The following works only for this particular Key/Val updates
  uint32_t chk_n1 = 0, chk_n2 = 0;
  for ( uint32_t i = 0; i < H.size; i++ ) { 
    hw_rs_hmap_bkt_t *bkts = H.bkts;
    bool *bkt_full = H.bkt_full;
    if ( bkts[i].key != 0 ) { chk_n1++; }
    if ( bkts[i].val != 0 ) { chk_n2++; }
    if ( bkt_full[i] ) { 
      if ( bkts[i].key == 0 ) { 
        go_BYE(-1); }
      if ( bkts[i].val == 0 ) { go_BYE(-1); }
    }
    else {
      if ( bkts[i].key != 0 ) { go_BYE(-1); }
      if ( bkts[i].val != 0 ) { go_BYE(-1); }
    }
  }
  if ( chk_n1 != H.nitems ) { go_BYE(-1); }
  if ( chk_n2 != H.nitems ) { go_BYE(-1); }
  //--------------------------------------------------
  // Now delete the items one by one 
  // All items have the same value: let us determine what it is 
  // sum_val is the value for all keys 
  sum_val = 0;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    hw_rs_hmap_val_t val = iter+1;
    sum_val += val;
  }
  uint32_t chk_nitems = nitems; 
  printf("Del Iter 1 \n");
  for ( uint32_t i = 0; i < nitems; i++ ) {
    bool is_found;
    hw_rs_hmap_key_t key = (i+1)*10; 
    hw_rs_hmap_val_t chk_val; 
    status = H.del(&H, &key, &chk_val, &is_found); cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
    if ( chk_val != sum_val ) { go_BYE(-1); }
    chk_nitems--; 
    if ( H.nitems != chk_nitems ) { go_BYE(-1); } 
    if ( H.nitems < 4096 ) { 
      // This is an expensive check 
      status = H.chk(&H); cBYE(status); 
    }
    // delete again just for kicks 
    status = H.del(&H, &key, &chk_val, &is_found); cBYE(status);
    if ( is_found ) { go_BYE(-1); }
    if ( chk_val != 0 ) { go_BYE(-1); }
  }
  if ( H.nitems != 0 ) { go_BYE(-1); } 
  // Now delete items again. Should have no impact 
  printf("Del Iter 2 \n");
  for ( uint32_t i = 0; i < nitems; i++ ) {
    bool is_found;
    hw_rs_hmap_key_t key = (i+1)*10; 
    hw_rs_hmap_val_t chk_val; 
    status = H.del(&H, &key, &chk_val, &is_found); cBYE(status);
    if ( is_found ) { go_BYE(-1); }
    if ( H.nitems != 0 ) { go_BYE(-1); } 
  }
  //--------------------------------------------------

  printf("hmap occupancy = %d \n", H.nitems);
  printf("hmap size      = %d \n", H.size);
  //printf("num_frees = %d \n", num_frees);
  //printf("num_mallocs = %d \n", num_mallocs);
  H.destroy(&H); 
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  if ( status == 0 ) { printf("Success on %s \n", argv[0]); }
  free_if_non_null(HC.so_file);
  return status;
}
