#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "vctr_consts.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "rs_hmap_config.h"
#include "vctr_new_uqid.h" 
#include "vctr_add.h" 
#include "vctr_del.h" 
#include "vctr_cnt.h" 
#include "vctr_put_chunk.h" 
#include "vctr_num_elements.h"
#include "vctr_num_chunks.h"
#include "vctr_is_eov.h"

#include "chnk_cnt.h" 

vctr_rs_hmap_t g_vctr_hmap;
uint32_t g_vctr_uqid;

chnk_rs_hmap_t g_chnk_hmap;
uint32_t g_chnk_uqid;

int 
main(
    int argc,
    char **argv
    )
{
  int status;
  bool b; int l_vctr_cnt, l_chnk_cnt; 
  // Initialize global variables
  g_vctr_uqid = 0; 
  memset(&g_vctr_hmap, 0, sizeof(vctr_rs_hmap_t));

  g_chnk_uqid = 0; 
  memset(&g_chnk_hmap, 0, sizeof(chnk_rs_hmap_t));
  //-----------------------
  if ( argc != 1 ) { go_BYE(-1); }
  //-------------------------------------------------------
  rs_hmap_config_t HC1; memset(&HC1, 0, sizeof(rs_hmap_config_t));
  HC1.min_size = 8;
  HC1.max_size = 0;
  HC1.so_file = strdup("libhmap_vctr.so"); 

  status = vctr_rs_hmap_instantiate(&g_vctr_hmap, &HC1); cBYE(status);
  status = g_vctr_hmap.bkt_chk(g_vctr_hmap.bkts, g_vctr_hmap.size);
  cBYE(status);
  if ( HC1.so_file != NULL ) { go_BYE(-1); } 
  //-------------------------------------------------------
  rs_hmap_config_t HC2; memset(&HC2, 0, sizeof(rs_hmap_config_t));
  HC2.min_size = 8;
  HC2.max_size = 0;
  HC2.so_file = strdup("libhmap_chnk.so"); 

  status = chnk_rs_hmap_instantiate(&g_chnk_hmap, &HC2); cBYE(status);
  status = g_chnk_hmap.bkt_chk(g_chnk_hmap.bkts, g_chnk_hmap.size);
  cBYE(status);
  if ( HC2.so_file != NULL ) { go_BYE(-1); } 
  //----------------------------------
  uint32_t vctr_chnk_size = 32; // for easy testing 
  uint32_t uqid; status = vctr_add1(F4, vctr_chnk_size, &uqid); 
  cBYE(status);
  uint32_t num_chunks = 4;
  float *X = NULL;
  for ( uint32_t i = 0; i < num_chunks; i++ ) {
    X = malloc(vctr_chnk_size * sizeof(float));
    for ( uint32_t j = 0; j < vctr_chnk_size; j++ ) { 
      X[j] = i*100 + j;
    }
    status = vctr_put_chunk(uqid, (char **)&X, true, vctr_chnk_size);
    cBYE(status);
    if ( X != NULL ) { go_BYE(-1); }
    uint32_t num_elements, l_num_chunks;
    status = vctr_num_elements(uqid, &num_elements); cBYE(status);
    status = vctr_num_chunks(uqid, &l_num_chunks); cBYE(status);
    if ( l_num_chunks != (i+1) ) { go_BYE(-1); }
    if ( num_elements != (i+1)*vctr_chnk_size ) { go_BYE(-1); }
  }
  // vector should NOT be eov 
  status = vctr_is_eov(uqid, &b); cBYE(status);
  if ( b ) { go_BYE(-1); }
  // now for last chunk (smaller than a full chunk)
  X = malloc(vctr_chnk_size * sizeof(float));
  for ( uint32_t j = 0; j < vctr_chnk_size; j++ ) { 
    X[j] = (num_chunks)*100 + j;
  }
  status = vctr_put_chunk(uqid, (char **)&X, true, vctr_chnk_size-1);
  cBYE(status);
  if ( X != NULL ) { go_BYE(-1); }
  uint32_t num_elements, l_num_chunks;
  status = vctr_num_elements(uqid, &num_elements); cBYE(status);
  status = vctr_num_chunks(uqid, &l_num_chunks); cBYE(status);
  if ( l_num_chunks != (num_chunks+1) ) { go_BYE(-1); }
  if ( num_elements != (((num_chunks+1)*vctr_chnk_size)-1) ) { go_BYE(-1); }
  // vector should be eov 
  status = vctr_is_eov(uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  //-- cannot put stuff after vector is eov 
  fprintf(stdout, ">>> Deliberate error\n");
  X = malloc(vctr_chnk_size * sizeof(float));
  status = vctr_put_chunk(uqid, (char **)&X, true, 1);
  if ( status == 0 ) { go_BYE(-1); }
  if ( X == NULL ) { go_BYE(-1); }
  fprintf(stdout, "<<< Deliberate error\n");
  //-- delete -----------------
  status = vctr_del(uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(); 
  if ( l_vctr_cnt != 0 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  //----------------------------------
  fprintf(stderr, "Successfully completed %s \n", argv[0]);
BYE:
  g_vctr_hmap.destroy(&g_vctr_hmap);
  g_chnk_hmap.destroy(&g_chnk_hmap);
  return status;
}
