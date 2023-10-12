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
  H.destroy(&H); 
  fprintf(stderr, "Unit test succeeded\n");
BYE:
  if ( status == 0 ) { printf("Success on %s \n", argv[0]); }
  free_if_non_null(HC.so_file);
  return status;
}
