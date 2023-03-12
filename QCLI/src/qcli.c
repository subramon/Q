#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "q_incs.h"
#include "rconnect.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  if ( argc != 3 ) { go_BYE(-1); } 
  const char * const server = argv[1];
  int port = atoi(argv[2]);
  int snd_timeout_sec = 10; // move to configs TODO P3
  int rcv_timeout_sec = 10; // move to configs TODO P3
  int sock = -1;

  status = rconnect(server, port, snd_timeout_sec, rcv_timeout_sec, &sock);
  cBYE(status);
  if ( sock < 0 ) { go_BYE(-1); } 

  for ( ; ; ) {
    char *cptr = readline("Q ");
    if ( cptr == NULL ) { break; } 
    fprintf(stdout, "%s\n", cptr);
    free(cptr); 
  }
BYE:
  if ( sock >= 0 ) { close(sock); } 
  return  status;
}
