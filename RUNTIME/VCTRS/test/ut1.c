#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "sclr_struct.h"
#include "vctr_consts.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "rs_hmap_config.h"
#include "vctr_add.h" 
#include "vctr_is.h" 
#include "vctr_del.h" 
#include "vctr_cnt.h" 
#include "vctr_name.h" 
#include "vctr_put1.h" 
#include "vctr_get1.h" 
#include "vctr_putn.h" 
#include "vctr_num_elements.h"
#include "vctr_num_chunks.h"
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
  char *buf = NULL; int tbsp = 0;
  bool b; uint32_t where; int l_vctr_cnt, l_chnk_cnt; char *name = NULL;

  if ( argc != 1 ) { go_BYE(-1); }

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
  uint32_t vctr_chnk_size = 32; // for easy testing 
  uint32_t uqid; status = vctr_add1(F4, 0, vctr_chnk_size, -1, 0, 0, &uqid); 
  cBYE(status);
  if ( uqid != 1 ) { go_BYE(-1); }
  //----------------------------------
  status = vctr_is(tbsp, uqid, &b, &where); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(tbsp); 
  if ( l_vctr_cnt != 1 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(tbsp); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  // check empty name  -----------------------------
  name = vctr_get_name(tbsp, uqid); 
  if ( name == NULL ) { go_BYE(-1); }
  if ( *name != '\0' ) { go_BYE(-1); }
  // set name  -----------------------------
  status = vctr_set_name(tbsp, uqid, "test name");  cBYE(status);
  // check good name  -----------------------------
  name = vctr_get_name(tbsp, uqid); 
  if ( name == NULL ) { go_BYE(-1); }
  if ( strcmp(name, "test name") != 0 ) { go_BYE(-1); }
  // add a few elements to the vector
  for ( uint32_t i = 0; i < 2*vctr_chnk_size+1; i++ ) { 
    float f4 = i+1;
    status = vctr_putn(tbsp, uqid, (char *)&f4, 1); cBYE(status);
    uint64_t num_elements; uint32_t num_chunks;
    status = vctr_num_elements(tbsp, uqid, &num_elements); cBYE(status);
    if ( num_elements != (i+1) ) { go_BYE(-1); }
    status = vctr_num_chunks(tbsp, uqid, &num_chunks); cBYE(status);
    if ( num_chunks != ((i / vctr_chnk_size)+1) ) { 
      go_BYE(-1); 
    }
  }
  status = g_vctr_hmap[0].freeze(&g_vctr_hmap[0],
      "/tmp/", "_meta.csv", "_bkts.bin","_full.bin");
  cBYE(status);
  //-- bogus delete -----------------
  status = vctr_del(0, 123445, &b); cBYE(status);
  if ( b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(tbsp); 
  if ( l_vctr_cnt != 1 ) { go_BYE(-1); }
  //-- good delete -----------------
  status = vctr_del(0, uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(tbsp); 
  if ( l_vctr_cnt != 0 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(tbsp); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  //----------------------------------

  // Test putting of Scalars
  vctr_chnk_size = 32; // for easy testing 
  status = vctr_add1(I4, 0, vctr_chnk_size, -1, 0, 0, &uqid); 
  cBYE(status);
  if ( uqid != 2 ) { go_BYE(-1); }
  SCLR_REC_TYPE sclr; memset(&sclr, 0, sizeof(SCLR_REC_TYPE));
  sclr.qtype = I4;
  sclr.val.i4 = 1; 
  for ( uint32_t i = 0; i < vctr_chnk_size*2+ 3; i++ ) { 
    status = vctr_put1(tbsp, uqid, &sclr); 
    // check that what you put is what you get 
    SCLR_REC_TYPE chk_sclr; memset(&chk_sclr, 0, sizeof(SCLR_REC_TYPE));
    status = vctr_get1(tbsp, uqid, i, &chk_sclr); 
    if ( memcmp(&sclr, &chk_sclr, sizeof(SCLR_REC_TYPE)) != 0 ) {
      go_BYE(-1);
    }
    sclr.val.i4++;
  }
  //----------------------------------
  status = vctr_del(0, uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(tbsp); 
  if ( l_vctr_cnt != 0 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(tbsp); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  //----------------------------------

  if ( g_mem_used != 0 ) { go_BYE(-1); }
  fprintf(stderr, "Successfully completed %s \n", argv[0]);
BYE:
  status = free_globals(); if ( status < 0 ) { WHEREAMI; } 
  free_if_non_null(buf); 
  return status;
}
