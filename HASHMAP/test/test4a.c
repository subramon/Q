// Similar to test4 but using mput instead 
#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_aux.h"
#include "hmap_chk.h"
#include "hmap_del.h"
#include "hmap_destroy.h"
#include "hmap_get.h"
#include "hmap_mput.h"

#include "val_struct_4.h"
#include "get_time_usec.h"

int num_frees; int num_mallocs; int num_updates;
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  num_frees = num_mallocs = num_updates = 0; 
  int N = 2048 * 2048; // number of insertions performed 
  uint32_t num_items      = 2048;
  val_t *chk_agg = NULL;
  uint16_t *lens = NULL;
  void **keys = NULL;
  void **vals = NULL;

  if ( argc != 1 ) { go_BYE(-1); }
  hmap_t hmap; memset(&hmap, 0, sizeof(hmap_t));
  dbg_t dbg; memset(&dbg, 0, sizeof(dbg_t));
  hmap_multi_t M; memset(&M, 0, sizeof(hmap_multi_t));
  bool reset_called = false;

  lens = malloc(N * sizeof(uint16_t));
  return_if_malloc_failed(lens);

  keys = malloc(N * sizeof(void *));
  return_if_malloc_failed(keys);

  vals = malloc(N * sizeof(void *));
  return_if_malloc_failed(vals);

  srandom(get_time_usec());
  srand48(random());
  for ( int i = 0; i < N; i++ ) { 
    lens[i] = sizeof(int);

    keys[i] = malloc(sizeof(int));
    return_if_malloc_failed(keys[i]);
    *((int *)keys[i]) = (int)(random() % num_items);

    vals[i] = malloc(sizeof(in_val_t));
    return_if_malloc_failed(vals[i]);
    *((in_val_t *)vals[i]) = drand48(); 
     
  }

  chk_agg = malloc(num_items * sizeof(val_t));
  return_if_malloc_failed(chk_agg);
  memset(chk_agg, 0,  (num_items * sizeof(val_t)));
  for ( uint32_t i = 0; i < num_items;  i++ ) { 
    chk_agg[i].minval = FLT_MAX;
    chk_agg[i].maxval = -1 * FLT_MAX;
  }

  hmap_config_t config; memset(&config, 0, sizeof(hmap_config_t));
  config.min_size = 2 * num_items;
  config.max_size = 4 * num_items;
  status = hmap_instantiate(&hmap, &config); cBYE(status);

  //-----------------------------
  multi_init(&M, 2048);
  //-----------------------------
  for ( int i = 0; i < N; i++ ) {
    //-- START: independent calculation of aggregation
    int key = *((int *)keys[i]);
    in_val_t val = *((in_val_t *)vals[i]);
    if ( chk_agg[key].minval > val ) { chk_agg[key].minval = val; }
    if ( chk_agg[key].maxval < val ) { chk_agg[key].maxval = val; }
    chk_agg[key].sumval += val;
    chk_agg[key].cnt++;
    //-- STOP : independent calculation of aggregation
  }
  status = hmap_mput(&hmap, &M, keys, N, lens, vals); cBYE(status);
  status = hmap_chk(&hmap, reset_called); cBYE(status); 
  printf("occupancy = %d \n", hmap.nitems);
  printf("size      = %d \n", hmap.size);
  // status = hmap_pr(&hmap); cBYE(status);

  // now confirm that every item has the aggregated value that it should
  for ( uint32_t i = 0; i < num_items; i++ ) {
    int key = i;
    uint32_t where_found; bool is_found;
    val_t *ptr_chk_val = NULL;
    status = hmap_get(&hmap, &key, sizeof(int), (void **)&ptr_chk_val, 
        &is_found, &where_found, &dbg); 
    cBYE(status);
    //-- START: Check against indepdent calculation 
    if ( !is_found ) { go_BYE(-1); }
    if ( where_found >= hmap.size ) { go_BYE(-1); }
    if ( ptr_chk_val[0].cnt != chk_agg[key].cnt ) { 
      go_BYE(-1); }
    if ( ptr_chk_val[0].minval != chk_agg[key].minval ) { go_BYE(-1); }
    if ( ptr_chk_val[0].maxval != chk_agg[key].maxval ) { 
      go_BYE(-1); }
    if ( ptr_chk_val[0].sumval != chk_agg[key].sumval ) { go_BYE(-1); }
    //-- START: Check against indepdent calculation 
    if ( ptr_chk_val == NULL ) { go_BYE(-1); }
  }
  hmap_destroy(&hmap);
  fprintf(stdout, "Test %s completed successfully\n", argv[0]);
BYE:
  free_if_non_null(chk_agg);
  free_if_non_null(lens);
  if ( keys != NULL ) { 
    for ( int i = 0; i < N; i++ ) {
      free_if_non_null(keys[i]);
    }
  }
  free_if_non_null(keys);

  if ( vals != NULL ) { 
    for ( int i = 0; i < N; i++ ) {
      free_if_non_null(vals[i]);
    }
  }
  free_if_non_null(keys);
  multi_free(&M);

  hmap_destroy(&hmap);
  return status;
}
