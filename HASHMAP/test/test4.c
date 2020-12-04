#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_instantiate.h"
#include "hmap_chk.h"
#include "hmap_del.h"
#include "hmap_destroy.h"
#include "hmap_get.h"
#include "hmap_put.h"
#include "val_struct_4.h"

int num_frees; int num_mallocs;
int
main(
    void
    )
{
  int status = 0;
  num_frees = num_mallocs = 0; 
  int num_iterations = 1024 * 1024;
  int num_items      = 1024;
  agg_val_t *chk_agg = NULL;

  hmap_t hmap; memset(&hmap, 0, sizeof(hmap_t));
  dbg_t dbg; memset(&dbg, 0, sizeof(dbg_t));
  hmap_config_t config; memset(&config, 0, sizeof(hmap_config_t));
  config.min_size = 32;
  config.max_size = 8*config.min_size;
  bool malloc_key = true;
  bool reset_called = false;

  agg_val_t *chk_agg = NULL;
  chk_agg = malloc(num_items * sizeof(agg_val_t));
  return_if_malloc_failed(chk_agg);
  memset(chk_agg, 0,  (num_items * sizeof(agg_val_t)));
  status = hmap_instantiate(&hmap, &config); cBYE(status);

  srand48(random());
  for ( int iter = 0; iter < num_iterations; iter++ ) {
    int key = (int)(random() % num_items);
    in_val_t val = drand48(); 
    //-- START: independent calculation of aggregation
    if ( chk_agg[key].minval > val ) { chk_agg[key].minval = val; }
    if ( chk_agg[key].minval < val ) { chk_agg[key].maxval = val; }
    chk_agg[key].sumval = val;
    chk_agg[key].cnt++;
    //-- STOP : independent calculation of aggregation
    status = hmap_put(&hmap, &key, sizeof(int), malloc_key, &val, &dbg); 
    cBYE(status);
  }
  status = hmap_chk(&hmap, reset_called); cBYE(status); 
  printf("Iter = %d, Probes = %" PRIu64 "\n",iter,(long)dbg.num_probes); 
  printf("occupancy = %d \n", hmap.nitems);
  printf("size      = %d \n", hmap.size);

  // now confirm that every item has the aggregated value that it should
  for ( uint32_t i = 0; i < nitems; i++ ) {
    int key = i;
    val_t *ptr_chk_val = NULL;
    status = hmap_get(&hmap, &key, sizeof(int), (void **)&ptr_chk_val, 
          &is_found, &where_found, &dbg); 
    cBYE(status);
    //-- START: Check against indepdent calculation 
    if ( !is_found ) { go_BYE(-1); }
    if ( ptr_chk_val[0].cnt != chk_agg[key].cnt ) { go_BYE(-1); }
    if ( ptr_chk_val[0].minval != chk_agg[key].minval ) { go_BYE(-1); }
    if ( ptr_chk_val[0].maxval != chk_agg[key].maxval ) { go_BYE(-1); }
    if ( ptr_chk_val[0].sumval != chk_agg[key].sumval ) { go_BYE(-1); }
    //-- START: Check against indepdent calculation 
    if ( ptr_chk_val == NULL ) { go_BYE(-1); }
  }
  hmap_destroy(&hmap);
BYE:
  hmap_destroy(&hmap);
  return status;
}
