#include <pthread.h>
#include "q_incs.h"
#include "q_macros.h"
#include "rmtree.h"
#include "isfile.h"
#include "get_cli_arg.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"
#include "vctr_rs_hmap_unfreeze.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"
#include "chnk_rs_hmap_unfreeze.h"

#include "web_struct.h"

#include "webserver.h"
#undef MAIN_PGM
#include "qjit_globals.h"
#include "init_globals.h"

int
init_globals(
    int argc,
    char **argv,
    int *ptr_mod_argc,
    char ***ptr_mod_argv
    )
{
  int status = 0;
  int mod_argc = 0;
  char **mod_argv = NULL;
  char *config_file = NULL;
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
  g_mem_used    = 0;
  g_dsk_used    = 0;

  //------------------------
  memset(&g_web_info,         0, sizeof(web_info_t));
  memset(&g_out_of_band_info, 0, sizeof(web_info_t));

  memset(&g_vctr_hmap_config, 0, sizeof(rs_hmap_config_t));
  memset(&g_chnk_hmap_config, 0, sizeof(rs_hmap_config_t));

  //------------------------
  // START: Some default values  to be over-ridden by read_configs
  g_restore_session = false;
  //-----------------------
  g_is_webserver   = false;
  g_is_out_of_band = false;
  //-----------------------
  g_mem_allowed = 4 * 1024 * (uint64_t)1048576 ; // in Bytes
  g_dsk_allowed = 32 * 1024 * (uint64_t)1048576 ; // in Bytes

  g_is_webserver   = false;
  g_is_out_of_band = false; 

  g_web_info.port         = 0; 
  g_out_of_band_info.port = 0; 

  g_vctr_hmap_config.min_size = 32;
  g_vctr_hmap_config.max_size = 0;

  g_chnk_hmap_config.min_size = 32;
  g_chnk_hmap_config.max_size = 0;

  g_q_config = NULL; 
  // STOP: Some default values  to be over-ridden by read_configs
  // Now see if we any over-rides from command-line need to be processed
  if ( argc > 1 ) {
    int where_found;
    status = get_cli_arg(argc, argv, "--config", &config_file, &where_found);
    cBYE(status);
    if ( config_file != NULL ) { // we found --config in the args 
      g_q_config = realpath(config_file, NULL);
      if ( g_q_config == NULL ) { go_BYE(-1); }
      if ( ptr_mod_argv != NULL ) { 
        // When luajit.c is the caller, we need modified configs
        // Else, we don't. By sending a NULL pointer as ptr_mod_argv
        // we can distinguish between the 2 call types.
        mod_argc = argc - 2; if ( mod_argc == 0 ) { go_BYE(-1); }
        /* Note the +1 This is super-important because of 
         * the following where he doesn't seem to be using argn
         static int collectargs(char **argv, int *flags)
         int i;
         for (i = 1; argv[i] != NULL; i++) 
         */
        mod_argv = malloc(mod_argc+1 * sizeof(char *));
        memset(mod_argv, 0,  (mod_argc+1 * sizeof(char *))); 
        int j = 0;
        for (  int i = 0; i < where_found; ) { 
          if ( j >= mod_argc ) { go_BYE(-1); }
          mod_argv[j++] = strdup(argv[i++]);
        }
        for (  int i = where_found+2; i < argc; ) { 
          if ( j >= mod_argc ) { go_BYE(-1); }
          mod_argv[j++] = strdup(argv[i++]);
        }
        *ptr_mod_argc = mod_argc;
        *ptr_mod_argv = mod_argv;
      }
    }
  }
BYE:
  free_if_non_null(config_file);
  return status;
}
