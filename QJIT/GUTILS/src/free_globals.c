#include <pthread.h>
#include "q_incs.h"
#include "q_macros.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "web_struct.h"
#include "mem_mgr_struct.h"

#include "webserver.h"
#include "mem_mgr.h"
#undef MAIN_PGM
#include "qjit_globals.h"
#include "free_globals.h"
int
free_globals(
    void
    )
{
  int status = 0;
  if ( g_mutex_created ) { 
    pthread_cond_destroy(&g_mem_cond);
    pthread_mutex_destroy(&g_mem_mutex);
  }
  g_vctr_uqid = 0; // nothing to free
  if ( g_vctr_hmap == NULL ) {
    for ( int i = 0; i <  Q_MAX_NUM_TABLESPACES; i++ ) { 
      if ( g_vctr_hmap[i].bkts != NULL ) {
        if ( i > 0 ) { printf("Destroying imported tablespace %d \n", i); }
        g_vctr_hmap[i].destroy(&g_vctr_hmap[i]);
      }
    }
  }
  //---------------------------------
  if ( g_chnk_hmap == NULL ) {
    for ( int i = 0; i <  Q_MAX_NUM_TABLESPACES; i++ ) { 
      if ( g_chnk_hmap[i].bkts != NULL ) {
        if ( i > 0 ) { printf("Destroying imported tablespace %d \n", i); }
        g_chnk_hmap[i].destroy(&g_chnk_hmap[i]);
      }
    }
  }
  if ( g_data_dir_root != NULL ) { 
    for ( int i = 0; i <  Q_MAX_NUM_TABLESPACES; i++ ) { 
      free_if_non_null(g_data_dir_root[i]);
    }
  }
  free_if_non_null(g_meta_dir_root);
  if ( g_tbsp_name != NULL ) { 
    for ( int i = 0; i <  Q_MAX_NUM_TABLESPACES; i++ ) { 
      free_if_non_null(g_tbsp_name[i]);
    }
  }
  free_if_non_null(g_data_dir_root);
  free_if_non_null(g_tbsp_name);

BYE:
  return status;
}
