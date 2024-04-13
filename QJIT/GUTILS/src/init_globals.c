#include <pthread.h>
#include "q_incs.h"
#include "q_macros.h"
#include "rmtree.h"
#include "isfile.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"
#include "vctr_rs_hmap_unfreeze.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"
#include "chnk_rs_hmap_unfreeze.h"

#include "web_struct.h"
#include "mem_mgr_struct.h"

#include "webserver.h"
#include "mem_mgr.h"
#undef MAIN_PGM
#include "qjit_globals.h"
#include "init_globals.h"

int
init_globals(
    int argc,
    char **argv
    )
{
  int status = 0;
  // Initialize global variables
  g_mem_lock = 0;

  g_webserver_interested = 0; 
  g_master_interested = 1; 
  g_master_halt = 0; 
  g_L_status = 0;

  g_vctr_hmap     = NULL;
  g_vctr_uqid     = 0;
  g_chnk_hmap     = NULL;
  g_data_dir_root = NULL;
  g_meta_dir_root = NULL;
  g_tbsp_name     = NULL;

  int n = Q_MAX_NUM_TABLESPACES; 

  int sz = n * sizeof(vctr_rs_hmap_t);
  g_vctr_hmap = malloc(sz);
  g_chnk_hmap = malloc(n * sizeof(chnk_rs_hmap_t));

  g_data_dir_root = malloc(n * sizeof(char *));
  g_tbsp_name     = malloc(n * sizeof(char *));

  memset(g_vctr_hmap,     0, n * sizeof(vctr_rs_hmap_t));
  memset(g_chnk_hmap,     0, n * sizeof(chnk_rs_hmap_t));
  memset(g_data_dir_root, 0, n * sizeof(char *));
  memset(g_tbsp_name,     0, n * sizeof(char *));

  g_meta_dir_root = malloc(sizeof(char) * (Q_MAX_LEN_DIR_NAME+1));
  memset(g_meta_dir_root, 0, (sizeof(char) * (Q_MAX_LEN_DIR_NAME+1)));
  // IMPORTANT: We need only one meta_dir_root but we need 
  // multiple tbsp_name data_dir_root, one for each tablespace
  g_tbsp_name[0] = strdup("original writable tablespace");
  //------------------------
  g_mutex_created = false;

  g_mem_used    = 0;
  g_dsk_used    = 0;

  //------------------------
  memset(&g_web_info,         0, sizeof(web_info_t));
  memset(&g_out_of_band_info, 0, sizeof(web_info_t));
  memset(&g_mem_mgr_info,     0, sizeof(mem_mgr_info_t));

  memset(&g_vctr_hmap_config, 0, sizeof(rs_hmap_config_t));
  memset(&g_chnk_hmap_config, 0, sizeof(rs_hmap_config_t));

  //------------------------
  // START: Some default values  to be over-ridden by read_configs
  g_restore_session = false;
  //-----------------------
  g_is_webserver   = false;
  g_is_out_of_band = false;
  g_is_mem_mgr     = false;
  //-----------------------
  g_mem_allowed = 4 * 1024 * (uint64_t)1048576 ; // in Bytes
  g_dsk_allowed = 32 * 1024 * (uint64_t)1048576 ; // in Bytes

  g_is_webserver   = false;
  g_is_out_of_band = false; 
  g_is_mem_mgr     = false; 

  g_web_info.port         = 0; 
  g_out_of_band_info.port = 0; 

  g_vctr_hmap_config.min_size = 32;
  g_vctr_hmap_config.max_size = 0;

  g_chnk_hmap_config.min_size = 32;
  g_chnk_hmap_config.max_size = 0;

  g_q_config = NULL; 
  // STOP: Some default values  to be over-ridden by read_configs
  // Now see if we any over-rides from command-line need to be processed
  bool config_found = false; 
  for ( int i = 1; i < argc-1; i++ ) { 
    if ( strcmp(argv[i], "--config" ) == 0 ) { 
      if ( config_found ) { 
        fprintf(stderr, "Cannot specify config twice\n"); go_BYE(-1);
      }
      config_found = true;
      char *cptr = argv[i+1]; 
      if ( !isfile(cptr) ) {
        fprintf(stderr, "Argument to --config is not a file [%s]\n", cptr);
        go_BYE(-1);
      }
      g_q_config = realpath(cptr, NULL);
    }
  }
BYE:
  return status;
}
