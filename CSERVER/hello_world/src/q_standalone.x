#include "q_incs.h"
#include "q_globals.h"
#include "init.h"
#include "auxil.h"
#include "setup.h"

int 
main(
    int argc, 
    char **argv
    )
{
  // signal(SIGINT, halt_server); TODO 
  int status = 0;

  zero_globals();
  //----------------------------------
  if ( argc != 2 ) { go_BYE(-1); }
  status = setup(); cBYE(status);
  pthread_mutex_init(&g_mutex, NULL);	
  pthread_cond_init(&g_condc, NULL);
  pthread_cond_init(&g_condp, NULL);
  status = pthread_create(&g_con, NULL, &post_from_log_q, NULL);
  if ( status != 0 ) { go_BYE(-1); }
  status = execute(argv[1]); 
  pthread_cond_signal(&g_condc);	/* wake up consumer */
  fprintf(stderr, "Waiting for consumer to finish \n");
  pthread_join(g_con, NULL);
  fprintf(stderr, "Consumer finished \n");
  pthread_mutex_destroy(&g_mutex);
  pthread_cond_destroy(&g_condc);
  pthread_cond_destroy(&g_condp);
BYE:
  free_globals();
  return status;
}
