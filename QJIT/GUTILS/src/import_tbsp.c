#include "q_incs.h"
#include "qjit_consts.h"
#include "isdir.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_unfreeze.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_unfreeze.h"

#include "import_tbsp.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

extern char *g_meta_dir_root;
extern char **g_data_dir_root;
extern char **g_tbsp_name;

int
import_tbsp(
    const char * const tbsp_name, // logical name 
    const char * const in_q_meta_dir_root,
    const char * const in_q_data_dir_root,
    int *ptr_tbsp
    )
{
  int status = 0;
  char * q_meta_dir_root = NULL;
  char * q_data_dir_root = NULL;
  // Make realpath so thatall names are comparable 

  if ( tbsp_name == NULL ) { go_BYE(-1); } 
  //----------------------------
  if ( in_q_meta_dir_root == NULL ) { go_BYE(-1); } 
  if ( !isdir(in_q_meta_dir_root) ) { 
    fprintf(stderr, "Missing meta dir %s \n", in_q_meta_dir_root);
    go_BYE(-1);
  } 
  q_meta_dir_root = realpath(in_q_meta_dir_root, NULL);
  
  if ( in_q_data_dir_root == NULL ) { go_BYE(-1); } 
  if ( !isdir(in_q_data_dir_root) ) { 
    fprintf(stderr, "Missing data dir %s \n", in_q_data_dir_root);
    go_BYE(-1); 
  } 
  q_data_dir_root = realpath(in_q_data_dir_root, NULL);

  // check that imported tablespace does not clash with default 
  if ( strcmp(q_meta_dir_root, g_meta_dir_root) == 0 )  { go_BYE(-1); }
  // You cannot un-import a tablespace. TODO P4 Relax this assumption
  // However, you can re-import a tablespace. Hence, the "pre_existing"
  // Find a spot to put this in
  bool pre_existing = false; 
  int tbsp = -1;
  // cannot import default tablespace 
  if ( strcmp(q_data_dir_root, g_data_dir_root[0]) == 0 )  { go_BYE(-1); }
  // Note that we start search from 1, not 0 
  // first see if this tablespace exists 
  for ( int i = 1; i <  Q_MAX_NUM_TABLESPACES; i++ ) {
    if ( ( g_data_dir_root[i] != NULL ) && 
         ( strcmp(q_data_dir_root, g_data_dir_root[i]) == 0 ) ) { 
      tbsp = i; pre_existing = true; break; 
    }
  }
  // if this tablespace does not exist, find a spot for it 
  if ( tbsp < 0 ) {
    for ( int i = 1; i <  Q_MAX_NUM_TABLESPACES; i++ ) {
      if ( g_data_dir_root[i] == NULL ) {
        tbsp = i; break; 
      }
    }
  }
  //-----------------------------------------
  if ( tbsp <= 0 ) { go_BYE(-1); } // no space
  // check no duplication of tablespace logical name 
  for ( int i = 0; i <  Q_MAX_NUM_TABLESPACES; i++ ) {
    if ( g_tbsp_name[i] == NULL ) { continue; } 
    for ( int j = i+1; j <  Q_MAX_NUM_TABLESPACES; j++ ) {
      if ( g_tbsp_name[j] == NULL ) { continue; } 
      if ( strcmp(g_tbsp_name[i], g_tbsp_name[j]) == 0 ) { 
        go_BYE(-1);
      }
    }
  }
  if ( pre_existing ) { 
    if ( g_vctr_hmap[tbsp].bkts == NULL ) { go_BYE(-1); } 
    g_vctr_hmap[tbsp].destroy(&g_vctr_hmap[tbsp]);
    g_chnk_hmap[tbsp].destroy(&g_chnk_hmap[tbsp]);
    free_if_non_null(g_data_dir_root[tbsp]);
    free_if_non_null(g_tbsp_name[tbsp]);
  }
  //-- Put it in an empty  spot
  g_data_dir_root[tbsp] = strdup(q_data_dir_root);
  g_tbsp_name[tbsp]     = strdup(tbsp_name);
  //-------------------------------
  printf(">>>>>>>>>>>> IMPORTING TABLESPACE ============\n");
  status = vctr_rs_hmap_unfreeze(&g_vctr_hmap[tbsp], 
        q_meta_dir_root,
        "_vctr_meta.csv", "_vctr_bkts.bin", "_vctr_full.bin");
  cBYE(status);
  status = chnk_rs_hmap_unfreeze(&g_chnk_hmap[tbsp], 
        q_meta_dir_root,
        "_chnk_meta.csv", "_chnk_bkts.bin", "_chnk_full.bin");
  cBYE(status);
  // For importer, we need to reset some of the counters that were
  // valid for the creator
  vctr_rs_hmap_t H = g_vctr_hmap[tbsp];
  vctr_rs_hmap_bkt_t *B = H.bkts;
  bool *in_use = H.bkt_full; 
  for ( uint32_t i = 0; i < H.size; i++ ) { 
    if ( in_use[i] == false ) { continue; } 
    B[i].val.ref_count = 0;
    B[i].val.num_readers = 0;
    B[i].val.num_writers = 0;
    B[i].val.is_writable = false;  
    if ( B[i].val.is_eov == false ) { go_BYE(-1); } 
  }
  // TODO P2 Anything else to reset above???
  //-----------------------------------
  // Note that since we cannot add to an imported tablespace,
  // we do not set g_vctr_uqid 
  *ptr_tbsp = tbsp;
BYE:
  free_if_non_null(q_meta_dir_root);
  free_if_non_null(q_data_dir_root);
  return status;
}
