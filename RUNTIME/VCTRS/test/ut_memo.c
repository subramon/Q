#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "vctr_consts.h"
#include "qjit_consts.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "cmem_struct.h"
#include "aux_cmem.h"
#include "rs_hmap_config.h"
#include "vctr_add.h" 
#include "vctr_put_chunk.h" 
#include "vctr_get_chunk.h" 
#include "vctr_memo.h"
#include "vctr_width.h"
#include "vctr_num_chunks.h"

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
  char * buf = NULL;
  CMEM_REC_TYPE cmem; memset(&cmem, 0, sizeof(CMEM_REC_TYPE));

  if ( argc != 1 ) { go_BYE(-1); }
  //-------------------------------------------------------
  status = init_globals(0, NULL, 0, NULL); cBYE(status); 
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
  uint32_t num_chunks = 100; 
  uint32_t tbsp = 0; 
  uint32_t width;
  status = vctr_width(tbsp, uqid, &width);
  // can change our mind about memo len while vector is dormant
  for ( int i = 0; i < 10; i++ ) { 
    status = vctr_set_memo(tbsp, uqid, i); cBYE(status); 
  }
  // set memo len to what you want to test at 
  int memo_len = 2; 
  status = vctr_set_memo(tbsp, uqid, memo_len); cBYE(status); 
  for ( uint32_t i = 0; i < num_chunks; i++ ) {
    // Initialize CMEM
    uint32_t vctr_chnk_size = max_num_in_chunk * width;
    memset(&cmem, 0, sizeof(CMEM_REC_TYPE));
    status = cmem_malloc(&cmem, vctr_chnk_size, qtype, NULL); 
    cBYE(status);
    for ( uint32_t j = 0; j < max_num_in_chunk; j++ ) { 
      ((float *)cmem.data)[j] = i*100 + j;
    }
    cmem.is_stealable = true;
    //-------------------------
    // put chunk in vector 
    status = vctr_put_chunk(tbsp, uqid, &cmem, max_num_in_chunk);
    cBYE(status);
    status = cmem_free(&cmem); cBYE(status); // no more need for cmem
    // printf("chunk index, mem_used = %u, %u\n", i, g_mem_used);
    uint32_t l_num_chunks;
    status =  vctr_num_chunks(tbsp, uqid, &l_num_chunks); cBYE(status);
    if ( g_mem_used > (memo_len+1)*vctr_chnk_size ) { go_BYE(-1); }

    // we have created exactly one vector 
    if ( g_vctr_hmap[0].nitems != 1 ) { go_BYE(-1); } 
  }
  printf("Succesfully completed %s \n", argv[0]);
BYE:
  free_if_non_null(buf);
  status = free_globals();   if ( status < 0 ) { WHEREAMI; } 
  status = cmem_free(&cmem); if ( status < 0 ) { WHEREAMI; } 
  return status;
}
