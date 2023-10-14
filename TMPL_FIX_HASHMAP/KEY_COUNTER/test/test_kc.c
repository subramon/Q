#include "rs_hmap_common.h" // From TMPL_FIX_HASHMAP/inc/ 
#include "rs_hmap_struct.h" // custom code 
#include "_rs_hmap_instantiate.h" // custom code 

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
  for ( uint32_t j = 0; j < niters; j++ ) {
    for ( uint32_t i = 0; i < nitems; i++ ) { 
      foo_rs_hmap_val_t val, chk_val; 
      memset(&val, 0, sizeof(val));
      foo_rs_hmap_key_t key;
      memset(&key, 0, sizeof(key));
      key.key1 = i+1;
      sprintf(key.key2, "string_%d", i+1);
      bool is_found; uint32_t where_found;
      status = H.get(&H, &key, &chk_val, &is_found, &where_found);
      cBYE(status);
      if ( j > 0 ) { 
        if ( !is_found ) { go_BYE(-1); }
      }
      else {
        if ( is_found ) { go_BYE(-1); }
      }
      val.guid  = H.nitems + 1; 
      val.count = 1;
      status = H.put(&H, &key, &val); cBYE(status);
      status = H.get(&H, &key, &chk_val, &is_found, &where_found);
      cBYE(status);
      if ( !is_found ) { go_BYE(-1); }
      if ( chk_val.count != (j+1) ) { go_BYE(-1); }
      if ( chk_val.guid  != (i+1) ) { go_BYE(-1); }
    }
  }
  // We now do a series of inserts but using pointers 
  // Malloc space for data 
  widths = malloc(n_cols * sizeof(uint32_t));
  widths[0] = sizeof(foo_rs_hmap_val_t.key1);
  widths[1] = sizeof(foo_rs_hmap_val_t.key2);

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
    status = foo_put(&H, data, widths, nitems); cBYE(status); 
    // TODO Need to check that all items that were put are okay
  }
  if ( H.nitems != 2*nitems ) { go_BYE(-1); }
  //-----------------------------------------------------------
  H.destroy(&H); 
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  if ( data != NULL ) { 
    for ( uint32_t i = 0; i < n_cols;; i++ ) {
      free_if_non_null(data[i]);
    }
    free_if_non_null(data);
  }
  free_if_non_null(widths);

  if ( status == 0 ) { printf("Success on %s \n", argv[0]); }
  free_if_non_null(HC.so_file);
  return status;
}
