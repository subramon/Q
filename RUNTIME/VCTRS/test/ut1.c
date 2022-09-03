#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "rs_hmap_config.h"
#include "vctr_new_uqid.h" 
#include "vctr_add.h" 
#include "vctr_is.h" 
#include "vctr_del.h" 
#include "vctr_cnt.h" 
#include "vctr_name.h" 

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
  bool b; uint32_t where; int l_vctr_cnt, l_chnk_cnt; char *name = NULL;
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
  uint32_t uqid; status = vctr_add1(F4, &uqid); cBYE(status);
  if ( uqid != 1 ) { go_BYE(-1); }
  //----------------------------------
  status = vctr_is(uqid, &b, &where); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  l_vctr_cnt = vctr_cnt(); 
  if ( l_vctr_cnt != 1 ) { go_BYE(-1); }
  l_chnk_cnt = chnk_cnt(); 
  if ( l_chnk_cnt != 1 ) { go_BYE(-1); }
  // check empty name  -----------------------------
  name = vctr_get_name(uqid); 
  if ( name == NULL ) { go_BYE(-1); }
  if ( *name != '\0' ) { go_BYE(-1); }
  // set name  -----------------------------
  status = vctr_set_name("test name", uqid);  cBYE(status);
  // check good name  -----------------------------
  name = vctr_get_name(uqid); 
  if ( name == NULL ) { go_BYE(-1); }
  if ( strcmp(name, "test name") != 0 ) { go_BYE(-1); }
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

  fprintf(stderr, "Successfully completed %s \n", argv[0]);
BYE:
  g_vctr_hmap.destroy(&g_vctr_hmap);
  g_chnk_hmap.destroy(&g_chnk_hmap);
  return status;
}
