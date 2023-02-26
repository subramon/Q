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

int
import_tbsp(
    const char * const in_q_meta_dir_root,
    const char * const in_q_data_dir_root,
    int *ptr_tbsp
    )
{
  int status = 0;
  char * q_meta_dir_root = NULL;
  char * q_data_dir_root = NULL;
  // Make realpath so thatall names are comparable 

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
  // Check that this q_root is a new one 
  for ( int i = 0; i <  Q_MAX_NUM_TABLESPACES; i++ ) { 
    if ( strcmp(q_data_dir_root, g_data_dir_root[i]) == 0 )  { go_BYE(-1); }
  }
  // Find a spot to put this in
  int tbsp = -1;
  for ( int i = 0; i <  Q_MAX_NUM_TABLESPACES; i++ ) {
    if ( g_data_dir_root[i][0] ==  '\0' ) { 
      tbsp = i; break; 
    }
  }
  if ( tbsp <= 0 ) { go_BYE(-1); } // no space
  //-- Put it in an empty  spot
  if ( strlen(in_q_data_dir_root) >= Q_MAX_LEN_DIR_NAME ) { go_BYE(-1); }
  strcpy(g_data_dir_root[tbsp], in_q_data_dir_root);
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
  //-----------------------------------
  // Note that since we cannot add to an imported tablespace,
  // we do not set g_vctr_uqid 
  *ptr_tbsp = tbsp;
BYE:
  free_if_non_null(q_meta_dir_root);
  free_if_non_null(q_data_dir_root);
  return status;
}
