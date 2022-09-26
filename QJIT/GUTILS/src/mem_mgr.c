#include "q_incs.h"
#include <evhttp.h>
#include <pthread.h>
#include "mem_mgr_struct.h"
#include "mem_mgr.h"

// START globals
extern int g_halt;
extern pthread_cond_t  g_mem_cond;
extern pthread_mutex_t g_mem_mutex;
// STOP  globals
_Noreturn void *
mem_mgr(
    void *arg
    )
{
  int status = 0;
  mem_mgr_info_t *mem_mgr_info = NULL;
  if ( arg == NULL ) { go_BYE(-1); }
  mem_mgr_info = (mem_mgr_info_t *)arg;
  int dummy = mem_mgr_info->dummy; 
  if ( dummy != 123456789 ) { go_BYE(-1); } 
  fprintf(stdout, "Memory Manager starting\n");

  for ( ; ; ) { 
    pthread_mutex_lock(&g_mem_mutex);
    int itmp; __atomic_load(&g_halt, &itmp, 1); 
    if ( itmp == 1 ) { 
      pthread_mutex_unlock(&g_mem_mutex);
      goto BYE; 
    }
    printf("Memory Manager waiting\n");
    pthread_cond_wait(&g_mem_cond, &g_mem_mutex);
    printf("Memory Manager working\n");
    pthread_mutex_unlock(&g_mem_mutex);
  }
BYE:
  if ( mem_mgr_info != NULL ) { 
    mem_mgr_info->status = status;
  }
  fprintf(stdout, "Memory Manager terminating\n");
  pthread_exit(NULL);
}
