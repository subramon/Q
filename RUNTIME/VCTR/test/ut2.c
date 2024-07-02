#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "qjit_consts.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "rmtree.h"
#include "isdir.h"
#include "get_file_size.h"
#include "l2_file_name.h"
#include "isfile.h"

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
#include "vctr_make_mem.h"
#include "vctr_drop_mem.h"
#include "vctr_print.h"

#include "aux_cmem.h" 
#include "chnk_cnt.h" 

#include "init_globals.h" 
#include "init_session.h" 
#include "free_globals.h" 

#define MAIN_PGM
#include "qjit_globals.h"

extern void * webserver(void *arg);
void * webserver(void *arg) { return arg; }  //Just for testing 

extern void * mem_mgr(void *arg);
void * mem_mgr(void *arg) { return arg; }  //Just for testing 

int 
main(
    int argc,
    char **argv
    )
{
  int status;
  int tbsp = 0; bool b; int l_vctr_cnt, l_chnk_cnt; char * buf = NULL;

  if ( argc != 1 ) { go_BYE(-1); }
  //-------------------------------------------------------
  status = init_globals(); cBYE(status); 
  // START: Fake configs. we do not read_configs()
  char *q_root = getenv("Q_ROOT");
  if ( q_root == NULL ) { go_BYE(-1); } 
  int len = strlen(q_root) + strlen("/meta/") + 16;
  buf = malloc(len);
  sprintf(buf, "%s/meta", q_root); 
  strcpy(g_meta_dir_root, buf); 
  sprintf(buf, "%s/data", q_root); 
  g_data_dir_root[0] = strdup(buf); 
  // STOP: Fake configs 

  status = init_session(); cBYE(status); 
  //----------------------------------
  uint32_t max_num_in_chunk = 32; // for easy testing 
  qtype_t qtype = F4;
  uint32_t uqid; status = vctr_add1(qtype, 0, max_num_in_chunk, -1,
      0, 0, &uqid); 
  cBYE(status);
  uint32_t num_chunks = 4;
  CMEM_REC_TYPE cmem; 
  uint32_t width;
  status = vctr_width(tbsp, uqid, &width); cBYE(status);
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
    status = vctr_put_chunk(tbsp, uqid, &cmem, max_num_in_chunk);
    cBYE(status);
    status = cmem_free(&cmem); cBYE(status); // no more need for cmem

    // some basic tests on vector 
    uint64_t num_elements; uint32_t l_num_chunks;
    status = vctr_num_elements(tbsp, uqid, &num_elements); cBYE(status);
    status = vctr_num_chunks(tbsp, uqid, &l_num_chunks); cBYE(status);
    if ( l_num_chunks != (i+1) ) { go_BYE(-1); }
    if ( num_elements != (i+1)*max_num_in_chunk ) { go_BYE(-1); }

    // some tests on the chunk just created
    CMEM_REC_TYPE chk_cmem; uint32_t chk_n; 
    bool yes_vec_no_chunk;
    status = vctr_get_chunk(tbsp, uqid, i, &chk_cmem, &chk_n, 
     &yes_vec_no_chunk);
    cBYE(status);
    if ( chk_cmem.qtype != qtype ) { go_BYE(-1); }
    if ( chk_cmem.size  != vctr_chnk_size ) { go_BYE(-1); }
    for ( uint32_t j = 0; j < max_num_in_chunk; j++ ) { 
      if ( ((float *)chk_cmem.data)[j] != (i*100 + j) ) { go_BYE(-1); } 
    }
    cmem_free(&chk_cmem);
    status = vctr_unget_chunk(tbsp, uqid, i); cBYE(status);
  }
  // vector should NOT be eov 
  status = vctr_is_eov(tbsp, uqid, &b); cBYE(status);
  if ( b ) { go_BYE(-1); }
  // now for last chunk (smaller than a full chunk)
  memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
  status = cmem_malloc(&cmem, vctr_chnk_size, qtype, NULL); cBYE(status);
  for ( uint32_t j = 0; j < max_num_in_chunk; j++ ) { 
    ((float *)cmem.data)[j] = (num_chunks)*100 + j;
  }
  cmem.is_stealable = true;
  //--------------------------------------------------
  status = vctr_put_chunk(tbsp, uqid, &cmem, max_num_in_chunk-1);
  cBYE(status);
  // if cmem was stealable, should not be any longer 
  if ( !cmem.is_foreign ) { go_BYE(-1); }
  if ( cmem.is_stealable ) { go_BYE(-1); }
  status = cmem_free(&cmem); cBYE(status);
  //--------------------------------------------------
  // basic checks on Vector
  uint64_t num_elements; uint32_t l_num_chunks;
  status = vctr_num_elements(tbsp, uqid, &num_elements); cBYE(status);
  status = vctr_num_chunks(tbsp, uqid, &l_num_chunks); cBYE(status);
  if ( l_num_chunks != (num_chunks+1) ) { go_BYE(-1); }
  if ( num_elements != (((num_chunks+1)*max_num_in_chunk)-1) ) { go_BYE(-1); }
  // vector should be eov 
  status = vctr_is_eov(tbsp, uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  //-- cannot put stuff after vector is eov 
  memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
  fprintf(stdout, ">>> Deliberate error\n");
  status = vctr_put_chunk(tbsp, uqid, &cmem, 1);
  fprintf(stdout, "<<< Deliberate error\n");
  if ( status == 0 ) { go_BYE(-1); }
  if ( cmem.is_foreign ) { go_BYE(-1); }
  if ( cmem.is_stealable ) { go_BYE(-1); }
  status = cmem_free(&cmem); cBYE(status);
  // flush to disk 
  strcpy(g_data_dir_root[tbsp], "/tmp/_ut2_data"); 
  printf(">>> START Acceptable error\n");
  status = rmtree(g_data_dir_root[tbsp]); 
  printf(">>> STOP  Acceptable error\n");
  status = mkdir(g_data_dir_root[tbsp], 0744);
  if ( g_dsk_used != 0 ) { go_BYE(-1); } 
  status = vctr_make_mem(tbsp, uqid, 2); cBYE(status);
  // TODO NEED TO TEST status = vctr_l1_to_l2(tbsp, uqid, 0); cBYE(status);
  if ( g_dsk_used == 0 ) { go_BYE(-1); } 
  uint64_t bak_mem_used = g_mem_used;
  uint64_t bak_dsk_used = g_dsk_used;
  // Check that there are 5 files for each chunk 
  // Also that there are sizes are correct 
  for ( uint32_t chnk_idx = 0; chnk_idx < l_num_chunks; chnk_idx++ ) { 
    char *l2_file = l2_file_name(tbsp, uqid, chnk_idx); 
    if ( !isfile(l2_file) ) { go_BYE(-1); } 
    uint64_t sz = get_file_size(l2_file);
    if ( sz != max_num_in_chunk * sizeof(float) ) { go_BYE(-1); }
    free_if_non_null(l2_file);
  }
  // now delete l2 backup 
  status = vctr_drop_mem(tbsp, uqid, 2); cBYE(status);
  // Now check that there are no files 
  if ( g_dsk_used != 0 ) { go_BYE(-1); } 
  for ( uint32_t chnk_idx = 0; chnk_idx < l_num_chunks; chnk_idx++ ) { 
    char *l2_file = l2_file_name(tbsp, uqid, chnk_idx); 
    if ( isfile(l2_file) ) { go_BYE(-1); } 
    free_if_non_null(l2_file);
  }
  // make the backups again
  status = vctr_make_mem(tbsp, uqid, 2); cBYE(status);
  if ( g_dsk_used != bak_dsk_used ) { go_BYE(-1); } 
  // now delete the l1 portion
  status = vctr_drop_mem(tbsp, uqid, 1); cBYE(status);
  // Now check that no RAM is in use 
  if ( g_mem_used != 0 ) { go_BYE(-1); } 
  // Now print the vector (this should cause stuff to be retsored to l1 
  status = vctr_print(tbsp, uqid, 0, "/tmp/_xxxx", "", 0, num_elements);
  cBYE(status);
  // l1 memory should be back as was before 
  if ( g_mem_used != bak_mem_used ) { go_BYE(-1); } 

  //-- delete -----------------
  status = vctr_del(tbsp, uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(tbsp); 
  if ( l_vctr_cnt != 0 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(tbsp); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  //----------------------------------
  if ( g_mem_used != 0 ) { go_BYE(-1); }
  if ( g_dsk_used != 0 ) { go_BYE(-1); }
  fprintf(stderr, "Successfully completed %s \n", argv[0]); 
  // cleanup
  status = rmtree(g_data_dir_root[tbsp]); 
BYE:
  status = free_globals(); if ( status < 0 ) { WHEREAMI; } 
  free_if_non_null(buf);
  return status;
}
