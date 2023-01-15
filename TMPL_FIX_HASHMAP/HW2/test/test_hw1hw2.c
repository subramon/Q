#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
// This tests if 2 hashmaps can co-exist sfely 
#include "hw2_rs_hmap_struct.h"
#include "hw2_rs_hmap_instantiate.h"

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
  hw2_rs_hmap_t *H2 = NULL;
  hw_rs_hmap_t  *H1 = NULL;
  //---------------------------
  rs_hmap_config_t HC; memset(&HC, 0, sizeof(rs_hmap_config_t));
  if ( argc != 1 ) { go_BYE(-1); }
  HC.min_size = 32;
  HC.max_size = 0;
  HC.so_file = strdup("libhmap_hw2.so"); 
  H2 = hw2_rs_hmap_instantiate(&HC); if ( H2 == NULL ) { go_BYE(-1); }
  H1 = hw_rs_hmap_instantiate(&HC); if ( H1 == NULL ) { go_BYE(-1); }
  //-----------------------------------------------------------
  hw2_rs_hmap_val_t sum_val;
  memset(&sum_val, 0, sizeof(hw2_rs_hmap_val_t));
  uint32_t nitems = 1048576;
  for ( int iter = 0; iter < num_iterations; iter++ ) {
    printf("Put Iter = %d \n", iter);
    hw2_rs_hmap_val_t val;
    memset(&val, 0, sizeof(hw2_rs_hmap_val_t));
    val.i8 = iter+1;
    sprintf(val.str, "[%" PRIu64 "]", val.i8);
    sum_val.i8 += val.i8;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      hw2_rs_hmap_key_t key;
      memset(&key, 0, sizeof(hw2_rs_hmap_key_t));
      key.f4 = (i+1)*10; 
      hw2_rs_hmap_val_t chk_val; 
      memset(&chk_val, 0, sizeof(hw2_rs_hmap_val_t));
      status = H2->put(H2, &key, &val); cBYE(status);
      if ( iter == 0 ) { 
        if ( H2->nitems != (i+1) ) { go_BYE(-1); } 
      }
      else { 
        if ( H2->nitems != nitems ) { go_BYE(-1); }
      }
      status = H2->get(H2, &key, &chk_val, &is_found, &where_found);
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
      if ( chk_val.i8 != sum_val.i8 ) { 
        go_BYE(-1); }
      if ( ( H2->nitems <= 10000 ) && ( ( i % 1000 ) == 0 )  ) {
        // This is an expensive check 
        status = H2->chk(H2); cBYE(status); 
      }
    }
  }
  //--------------------------------------------------
  // REPEATING INSERTS FOR HW1
  hw_rs_hmap_val_t hw1_sum_val;
#ifdef TODO 
  hw_rs_hmap_val_t hw1_sum_val = 0;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    printf("Put Iter = %d \n", iter);
    hw_rs_hmap_val_t hw1_val = iter+1;
    hw1_sum_val += hw1_val;
    bool is_found; uint32_t where_found;
    for ( uint32_t i = 0; i < nitems; i++ ) {
      hw_rs_hmap_key_t hw1_key = (i+1)*10; 
      hw_rs_hmap_val_t hw1_chk_val; 
      status = H1->put(H1, &hw1_key, &hw1_val); cBYE(status);
      status = H1->get(H1, &hw1_key, &hw1_chk_val, &is_found, &where_found);
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
      if ( hw1_chk_val != hw1_sum_val ) { go_BYE(-1); }
      if ( iter == 0 ) { 
        if ( H1->nitems != (i+1) ) { go_BYE(-1); } 
      }
      else { 
        if ( H1->nitems != nitems ) { go_BYE(-1); }
      }
    }
    if ( H1->nitems < 4096 ) { 
      // This is an expensive check 
      status = H1->chk(H1); cBYE(status); 
    }
  }
#endif
  //--------------------------------------------------
  // The following works only for this particular Key/Val updates
  uint32_t chk_n1 = 0, chk_n2 = 0;
  for ( uint32_t i = 0; i < H2->size; i++ ) { 
    hw2_rs_hmap_bkt_t *bkts = H2->bkts;
    bool *bkt_full = H2->bkt_full;
    if ( bkts[i].key.f4 != 0 ) { chk_n1++; }
    if ( bkts[i].val.i8 != 0 ) { chk_n2++; }
    if ( bkt_full[i] ) { 
      if ( bkts[i].key.f4 == 0 ) { 
        go_BYE(-1); }
      if ( bkts[i].val.i8 == 0 ) { go_BYE(-1); }
    }
    else {
      if ( bkts[i].key.f4 != 0 ) { go_BYE(-1); }
      if ( bkts[i].val.i8 != 0 ) { go_BYE(-1); }
    }
  }
  if ( chk_n1 != H2->nitems ) { go_BYE(-1); }
  if ( chk_n2 != H2->nitems ) { go_BYE(-1); }
  //--------------------------------------------------
  // Now delete the items one by one 
  // All items have the same value: let us determine what it is 
  // sum_val is the value for all keys 
  sum_val.i8 = 0;
  for ( int iter = 0; iter < num_iterations; iter++ ) { 
    sum_val.i8 += iter+1;
  }
  uint32_t chk_nitems = nitems; 
  printf("Del Iter 1 \n");
  for ( uint32_t i = 0; i < nitems; i++ ) {
    bool is_found;
    hw2_rs_hmap_key_t key;
    key.f4 = (i+1)*10; 
    hw2_rs_hmap_val_t chk_val; 
    status = H2->del(H2, &key, &chk_val, &is_found); cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
    if ( chk_val.i8 != sum_val.i8 ) { go_BYE(-1); }
    chk_nitems--; 
    if ( H2->nitems != chk_nitems ) { go_BYE(-1); } 
    if ( H2->nitems < 4096 ) { 
      // This is an expensive check 
      status = H2->chk(H2); cBYE(status); 
    }
    // delete again just for kicks 
    memset(&chk_val, 0, sizeof(rs_hmap_val_t)); 
    status = H2->del(H2, &key, &chk_val, &is_found); cBYE(status);
    if ( is_found ) { go_BYE(-1); }
    if ( chk_val.i8 != 0 ) { go_BYE(-1); }
  }
  if ( H2->nitems != 0 ) { go_BYE(-1); } 
  // Now delete items again. Should have no impact 
  printf("Del Iter 2 \n");
  for ( uint32_t i = 0; i < nitems; i++ ) {
    bool is_found;
    hw2_rs_hmap_key_t key;
    memset(&key, 0, sizeof(hw2_rs_hmap_key_t));
    key.f4 = (i+1)*10; 
    hw2_rs_hmap_val_t chk_val; 
    memset(&chk_val, 0, sizeof(rs_hmap_val_t)); 
    status = H2->del(H2, &key, &chk_val, &is_found); cBYE(status);
    if ( is_found ) { go_BYE(-1); }
    if ( chk_val.i8 != 0 ) { go_BYE(-1); }
    if ( H2->nitems != 0 ) { go_BYE(-1); } 
  }
  //--------------------------------------------------

  printf("hmap occupancy = %d \n", H2->nitems);
  printf("hmap size      = %d \n", H2->size);
  //printf("num_frees = %d \n", num_frees);
  //printf("num_mallocs = %d \n", num_mallocs);
  H2->destroy(H2); 
  H1->destroy(H1); 
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  if ( status == 0 ) { printf("Success on %s \n", argv[0]); }
  free_if_non_null(HC.so_file);
  free_if_non_null(H1);
  free_if_non_null(H2);
  return status;
}
