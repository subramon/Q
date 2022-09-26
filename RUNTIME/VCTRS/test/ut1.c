#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
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

vctr_rs_hmap_t g_vctr_hmap;
uint32_t g_vctr_uqid;

chnk_rs_hmap_t g_chnk_hmap;
uint32_t g_chnk_uqid;

uint64_t g_mem_used;
uint64_t g_mem_allowed;
uint64_t g_dsk_used;
uint64_t g_dsk_allowed;
// For libcgutils not to complain
bool g_mutex_created;
pthread_cond_t  g_mem_cond;
pthread_mutex_t g_mem_mutex;
int g_L_status;
int g_halt;
int g_webserver_interested;
char *g_data_dir_root;
char *g_meta_dir_root;

int 
main(
    int argc,
    char **argv
    )
{
  int status;
  bool b; uint32_t where; int l_vctr_cnt, l_chnk_cnt; char *name = NULL;
  // Initialize global variables
  g_vctr_uqid = 0; 
  memset(&g_vctr_hmap, 0, sizeof(vctr_rs_hmap_t));

  g_chnk_uqid = 0; 
  memset(&g_chnk_hmap, 0, sizeof(chnk_rs_hmap_t));

  g_mem_used = 0;
  g_mem_allowed = (uint64_t)1048576 * (uint64_t)(1024 * 4);
  g_dsk_used = 0;
  g_dsk_allowed = (uint64_t)1048576 * (uint64_t)(1024 * 32);
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
  uint32_t uqid; status = vctr_add1(F4, 0, vctr_chnk_size, -1, &uqid); 
  cBYE(status);
  if ( uqid != 1 ) { go_BYE(-1); }
  //----------------------------------
  status = vctr_is(uqid, &b, &where); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(); 
  if ( l_vctr_cnt != 1 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  // check empty name  -----------------------------
  name = vctr_get_name(uqid); 
  if ( name == NULL ) { go_BYE(-1); }
  if ( *name != '\0' ) { go_BYE(-1); }
  // set name  -----------------------------
  status = vctr_set_name(uqid, "test name");  cBYE(status);
  // check good name  -----------------------------
  name = vctr_get_name(uqid); 
  if ( name == NULL ) { go_BYE(-1); }
  if ( strcmp(name, "test name") != 0 ) { go_BYE(-1); }
  // add a few elements to the vector
  for ( uint32_t i = 0; i < 2*vctr_chnk_size+1; i++ ) { 
    float f4 = i+1;
    status = vctr_putn(uqid, (char *)&f4, 1); cBYE(status);
    uint64_t num_elements; uint32_t num_chunks;
    status = vctr_num_elements(uqid, &num_elements); cBYE(status);
    if ( num_elements != (i+1) ) { go_BYE(-1); }
    status = vctr_num_chunks(uqid, &num_chunks); cBYE(status);
    if ( num_chunks != ((i / vctr_chnk_size)+1) ) { 
      go_BYE(-1); 
    }
  }
  status = g_vctr_hmap.freeze(&g_vctr_hmap,
      "/tmp/", "_meta.csv", "_bkts.bin","_full.bin");
  cBYE(status);
  //-- bogus delete -----------------
  status = vctr_del(123445, &b); cBYE(status);
  if ( b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(); 
  if ( l_vctr_cnt != 1 ) { go_BYE(-1); }
  //-- good delete -----------------
  status = vctr_del(uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(); 
  if ( l_vctr_cnt != 0 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  //----------------------------------

  // Test putting of Scalars
  vctr_chnk_size = 32; // for easy testing 
  status = vctr_add1(I4, 0, vctr_chnk_size, -1, &uqid); 
  cBYE(status);
  if ( uqid != 2 ) { go_BYE(-1); }
  SCLR_REC_TYPE sclr; memset(&sclr, 0, sizeof(SCLR_REC_TYPE));
  sclr.qtype = I4;
  sclr.val.i4 = 1; 
  for ( uint32_t i = 0; i < vctr_chnk_size*2+ 3; i++ ) { 
    status = vctr_put1(uqid, &sclr); 
    // check that what you put is what you get 
    SCLR_REC_TYPE chk_sclr; memset(&chk_sclr, 0, sizeof(SCLR_REC_TYPE));
    status = vctr_get1(uqid, i, &chk_sclr); 
    if ( memcmp(&sclr, &chk_sclr, sizeof(SCLR_REC_TYPE)) != 0 ) {
      go_BYE(-1);
    }
    sclr.val.i4++;
  }
  //----------------------------------
  status = vctr_del(uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(); 
  if ( l_vctr_cnt != 0 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(); 
  if ( l_chnk_cnt != 0 ) { go_BYE(-1); }
  //----------------------------------

  if ( g_mem_used != 0 ) { go_BYE(-1); }
  fprintf(stderr, "Successfully completed %s \n", argv[0]);
BYE:
  g_vctr_hmap.destroy(&g_vctr_hmap);
  g_chnk_hmap.destroy(&g_chnk_hmap);
  return status;
}
