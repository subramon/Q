#include "rs_hmap_common.h" // From TMPL_FIX_HASHMAP/inc/ 
#include "rs_hmap_struct.h" // custom code 
#include "_rs_hmap_instantiate.h" // custom code 
#include "foo_rsx_kc_put.h"
#include "foo_rsx_kc_cum_count.h"
#include "foo_rsx_kc_make_permutation.h"

int
fn_sortUI8_asc(const void *p1, const void *p2)
{
  const uint64_t  *u1 = (const uint64_t *)p1;
  const uint64_t  *u2 = (const uint64_t *)p2;
  uint64_t v1 = *u1;
  uint64_t v2 = *u2;
  if ( v1 < v2 ) { 
    return -1;
  }
  else {
    return 1;
  }
}
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  uint32_t n_cols = 2; // HARD CODED from foo/inc/rsx_types.h
  uint32_t *widths = NULL; 
  void **data = NULL; 
  uint64_t *permutation = NULL;
  // num_frees = num_mallocs = 0; 
  foo_rs_hmap_t H; memset(&H, 0, sizeof(H));
  //---------------------------
  rs_hmap_config_t HC; memset(&HC, 0, sizeof(rs_hmap_config_t));
  if ( argc != 1 ) { go_BYE(-1); }
  HC.min_size = 32;
  HC.max_size = 0;
  HC.so_file = strdup("../libkcfoo.so"); 
  status = foo_rs_hmap_instantiate(&H, &HC); cBYE(status);
  //-----------------------------------------------------------
  uint32_t niters = 8;
  uint32_t nitems = 4096;
  uint32_t n_puts = 0;
  // We now do a series of inserts but using pointers 
  // Malloc space for data 
  foo_rs_hmap_key_t key;
  widths = malloc(n_cols * sizeof(uint32_t));
  widths[0] = sizeof(key.key1);
  widths[1] = sizeof(key.key2);

  data = malloc(n_cols * sizeof(void *));
  data[0] = malloc(widths[0] * nitems);
  data[1] = malloc(widths[1] * nitems);

  memset(data[0], 0, (widths[0] * nitems));
  memset(data[1], 0, (widths[1] * nitems));

  // Create some synthetic data 
  for ( uint32_t i = 0; i < nitems; i++ ) { 
    ((uint32_t *)data[0])[i] = nitems+i+1; 
    char *cptr = data[1] + (i*widths[1]); 
    sprintf(cptr, "string_%d", nitems+i+1);
  }

  for ( uint32_t j = 0; j < niters; j++ ) {
    printf("Putting %u items for %u th time \n", nitems, j);
    status = foo_rsx_kc_put(&H, data, widths, nitems); cBYE(status); 
    n_puts += nitems;
  }
  if ( H.nitems != nitems ) { go_BYE(-1); }
  // check that all items that were put in are okay
  for ( uint32_t i = 0; i < nitems; i++ ) {
    foo_rs_hmap_val_t val, chk_val; 
    memset(&val, 0, sizeof(val));
    foo_rs_hmap_key_t key;
    memset(&key, 0, sizeof(key));
    key.key1 = nitems+i+1;
    sprintf(key.key2, "string_%d", nitems+i+1);
    bool is_found; uint32_t where_found;
    status = H.get(&H, &key, &chk_val, &is_found, &where_found);
    cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
  }
  //-----------------------------------------------------------
  uint64_t sum;
  status = foo_rsx_kc_cum_count(&H, &sum); cBYE(status); 
  if ( sum != H.nitems * niters ) { go_BYE(-1); }
  if ( sum != n_puts ) { go_BYE(-1); } 
  //-----------------------------------------------------------
  // Create permutation for items 
  permutation = malloc(n_puts * sizeof(uint64_t));
  for ( uint32_t k = 0; k < n_puts; k++ ) { 
    permutation[k] = UINT_MAX;
  }
  uint32_t save_n_puts = n_puts;
  for ( int k = 0; n_puts > 0; k++ ) { 
    uint32_t chunk_size;
    if ( n_puts > nitems ) {
      chunk_size = nitems;
    }
    else {
      chunk_size = n_puts;
    }
    status = foo_rsx_kc_make_permutation(&H, data, widths, chunk_size,
        permutation + k*chunk_size);
    cBYE(status);
    n_puts -= chunk_size;
  }
  n_puts = save_n_puts;
  uint32_t tmp = 0;
  for ( uint32_t k = 0; k < n_puts; k++ ) { 
    // if ( permutation[k] == UINT_MAX ) { go_BYE(-1); }
    if ( permutation[k] == UINT_MAX ) { tmp++; }
  }
  printf("tmp = %u \n", tmp);
  // Some checks after permutations created
  qsort(permutation, n_puts, sizeof(uint64_t), fn_sortUI8_asc);
  for ( uint32_t i = 0; i < n_puts; i++ ) { 
    if ( permutation[i] != i ) { go_BYE(-1); }
  }
  for ( uint32_t i = 0; i < H.size; i++ ) { 
    if ( H.bkt_full[i] == false ) { continue; }
    if ( H.bkts[i].val.count != H.bkts[i].val.run_count ) { 
      go_BYE(-1); }
  }
  //------------- cleanup
  H.destroy(&H); 
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  if ( data != NULL ) { 
    for ( uint32_t i = 0; i < n_cols; i++ ) {
      free_if_non_null(data[i]);
    }
    free_if_non_null(data);
  }
  free_if_non_null(widths);
  free_if_non_null(permutation);
  if ( status == 0 ) { printf("Success on %s \n", argv[0]); }
  free_if_non_null(HC.so_file);
  return status;
}
