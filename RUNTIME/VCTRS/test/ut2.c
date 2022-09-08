#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "vctr_consts.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "cmem_struct.h"
#include "aux_cmem.h"
#include "rs_hmap_config.h"
#include "vctr_new_uqid.h" 
#include "vctr_add.h" 
#include "vctr_del.h" 
#include "vctr_cnt.h" 
#include "vctr_put_chunk.h" 
#include "vctr_get_chunk.h" 
#include "vctr_num_elements.h"
#include "vctr_num_chunks.h"
#include "vctr_width.h"
#include "vctr_is_eov.h"

#include "aux_cmem.h" 
#include "chnk_cnt.h" 

vctr_rs_hmap_t g_vctr_hmap;
uint32_t g_vctr_uqid;

chnk_rs_hmap_t g_chnk_hmap;
uint32_t g_chnk_uqid;

uint64_t g_mem_used;
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

  g_mem_used = 0;
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
  uint32_t max_num_in_chunk = 32; // for easy testing 
  qtype_t qtype = F4;
  uint32_t uqid; status = vctr_add1(qtype, 0, max_num_in_chunk, -1,&uqid); 
  cBYE(status);
  uint32_t num_chunks = 4;
  CMEM_REC_TYPE cmem; 
  uint32_t width;
  status = vctr_width(uqid, &width); cBYE(status);
  if ( width != sizeof(float) ) { go_BYE(-1); }
  uint32_t vctr_chnk_size = max_num_in_chunk * width;
  for ( uint32_t i = 0; i < num_chunks; i++ ) {
    // Initialize CMEM
    memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
    status = cmem_malloc(&cmem, vctr_chnk_size, qtype, NULL); 
    cBYE(status);
    for ( uint32_t j = 0; j < max_num_in_chunk; j++ ) { 
      ((float *)cmem.data)[j] = i*100 + j;
    }
    if ( ( i % 2 ) == 0 ) {
      cmem.is_stealable = true;
    }
    else {
      cmem.is_stealable = false;
    }
    //-------------------------
    status = vctr_put_chunk(uqid, &cmem, max_num_in_chunk);
    cBYE(status);
    status = cmem_free(&cmem); cBYE(status); // no more need for cmem

    // some basic tests on vector 
    uint64_t num_elements; uint32_t l_num_chunks;
    status = vctr_num_elements(uqid, &num_elements); cBYE(status);
    status = vctr_num_chunks(uqid, &l_num_chunks); cBYE(status);
    if ( l_num_chunks != (i+1) ) { go_BYE(-1); }
    if ( num_elements != (i+1)*max_num_in_chunk ) { go_BYE(-1); }

    // some tests on the chunk just created
    CMEM_REC_TYPE chk_cmem; uint32_t chk_n;
    status = vctr_get_chunk(uqid, i, &chk_cmem, &chk_n, NULL);
    if ( chk_cmem.qtype != qtype ) { go_BYE(-1); }
    if ( chk_cmem.size  != vctr_chnk_size ) { go_BYE(-1); }
    for ( uint32_t j = 0; j < max_num_in_chunk; j++ ) { 
      if ( ((float *)chk_cmem.data)[j] != (i*100 + j) ) { go_BYE(-1); } 
    }
    cmem_free(&chk_cmem);
  }
  // vector should NOT be eov 
  status = vctr_is_eov(uqid, &b); cBYE(status);
  if ( b ) { go_BYE(-1); }
  // now for last chunk (smaller than a full chunk)
  memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
  status = cmem_malloc(&cmem, vctr_chnk_size, qtype, NULL); cBYE(status);
  for ( uint32_t j = 0; j < max_num_in_chunk; j++ ) { 
    ((float *)cmem.data)[j] = (num_chunks)*100 + j;
  }
  cmem.is_stealable = true;
  //--------------------------------------------------
  status = vctr_put_chunk(uqid, &cmem, max_num_in_chunk-1);
  cBYE(status);
  // if cmem was stealable, should not be any longer 
  if ( !cmem.is_foreign ) { go_BYE(-1); }
  if ( cmem.is_stealable ) { go_BYE(-1); }
  status = cmem_free(&cmem); cBYE(status);
  //--------------------------------------------------
  // basic checks on Vector
  uint64_t num_elements; uint32_t l_num_chunks;
  status = vctr_num_elements(uqid, &num_elements); cBYE(status);
  status = vctr_num_chunks(uqid, &l_num_chunks); cBYE(status);
  if ( l_num_chunks != (num_chunks+1) ) { go_BYE(-1); }
  if ( num_elements != (((num_chunks+1)*max_num_in_chunk)-1) ) { go_BYE(-1); }
  // vector should be eov 
  status = vctr_is_eov(uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  //-- cannot put stuff after vector is eov 
  memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
  fprintf(stdout, ">>> Deliberate error\n");
  status = vctr_put_chunk(uqid, &cmem, 1);
  fprintf(stdout, "<<< Deliberate error\n");
  if ( status == 0 ) { go_BYE(-1); }
  if ( cmem.is_foreign ) { go_BYE(-1); }
  if ( cmem.is_stealable ) { go_BYE(-1); }
  status = cmem_free(&cmem); cBYE(status);
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
  if ( g_mem_used != 0 ) { go_BYE(-1); }
  return status;
}
