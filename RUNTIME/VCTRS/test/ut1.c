#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "vctr_new_uqid.h" 
#include "vctr_add.h" 
#include "vctr_is.h" 
#include "vctr_del.h" 
#include "vctr_cnt.h" 
#include "vctr_name.h" 

#include "mk_vctr_hmap.h" 
#include "mk_chnk_hmap.h" 

#include "destroy_vctr_hmap.h" 
#include "destroy_chnk_hmap.h" 

void * g_vctr_hmap;
void * g_chnk_hmap;
uint32_t g_vctr_uqid;
uint32_t g_chnk_uqid;

int 
main(
    int argc,
    char **argv
    )
{
  int status;
  bool b; uint32_t where; int cnt; char *name = NULL;
  // Initialize global variables
  g_vctr_uqid = 0; 
  g_chnk_uqid = 0; 
  g_vctr_hmap = NULL;
  g_chnk_hmap = NULL;
  //-----------------------
  if ( argc != 1 ) { go_BYE(-1); }
  //-----------------------
  g_vctr_hmap = mk_vctr_hmap(); if ( g_vctr_hmap == NULL ) { go_BYE(-1); }
  g_chnk_hmap = mk_chnk_hmap(); if ( g_chnk_hmap == NULL ) { go_BYE(-1); }
  //----------------------------------
  uint32_t uqid; status = vctr_add1(F4, &uqid); cBYE(status);
  if ( uqid != 1 ) { go_BYE(-1); }
  //----------------------------------
  status = vctr_is(uqid, &b, &where); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  cnt = vctr_cnt(); 
  if ( cnt != 1 ) { go_BYE(-1); }
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
  cnt = vctr_cnt(); 
  if ( cnt != 1 ) { go_BYE(-1); }
  //-- good delete -----------------
  status = vctr_del(uqid, &b); cBYE(status);
  if ( !b ) { go_BYE(-1); }
  cnt = vctr_cnt(); 
  if ( cnt != 0 ) { go_BYE(-1); }
  //----------------------------------

  fprintf(stderr, "Successfully completed %s \n", argv[0]);
BYE:
  destroy_vctr_hmap(g_vctr_hmap); 
  destroy_chnk_hmap(g_chnk_hmap); 
  return status;
}
