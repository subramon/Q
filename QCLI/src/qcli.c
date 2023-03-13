#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <curl/curl.h>
#include "q_incs.h"
#include "rconnect.h"
#include "setup_curl.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  char *write_buffer = NULL; 
  uint32_t sz_write_buffer = 65536; //  moev to configs TODO P3 
  if ( argc != 3 ) { go_BYE(-1); } 
  const char * const server = argv[1];
  int port = atoi(argv[2]);
  int snd_timeout_sec = 10; // move to configs TODO P3
  int rcv_timeout_sec = 10; // move to configs TODO P3
  int timeout_ms = 1000 * 1000;   // move to configs TODO P3
  // TODO P1 fix timeout after debugging is complete 
  int sock = -1;
  const char ** const in_hdrs = NULL;
  int num_in_hdrs = 0;
  const char * const url = "Lua"; 
  CURL *ch = NULL;
  struct curl_slist *curl_hdrs = NULL;

  // Check that server is listening on the port 
  /*
  status = rconnect(server, port, snd_timeout_sec, rcv_timeout_sec, &sock);
  cBYE(status);
  if ( sock < 0 ) { go_BYE(-1); } 
  if ( sock >= 0 ) { close(sock); sock = -1; } 
  */
  // allocate buffer to record server response
  write_buffer = malloc(sz_write_buffer);
  return_if_malloc_failed(write_buffer); 

  for ( ; ; ) {
    char *cptr = readline("Q ");
    if ( cptr == NULL ) { break; } 
    fprintf(stdout, "%s\n", cptr);
    // open connection to server 
    memset(write_buffer, 0, sz_write_buffer);
    status = setup_curl(write_buffer, in_hdrs, 0, 
        server, port, url, timeout_ms, &ch, &curl_hdrs); 
    cBYE(status); 
    // call server 
    status = post_Q(ch, cptr); 
    // print output
    fprintf(stdout, "%s\n", write_buffer); 
    // close connection, free resources
    if ( ch != NULL ) { curl_easy_cleanup(ch); ch = NULL; } 
    if ( curl_hdrs != NULL ) {
      curl_slist_free_all(curl_hdrs); curl_hdrs = NULL;
    }
    free(cptr); 
  }
BYE:
  rl_clear_history(); // to avoid Valgrind reachable complaints
  // however, above doesn't help much 
  free_if_non_null(write_buffer); 
  if ( ch != NULL ) { curl_easy_cleanup(ch); ch = NULL; } 
  if ( curl_hdrs != NULL ) {
    curl_slist_free_all(curl_hdrs); curl_hdrs = NULL;
  }
  if ( sock >= 0 ) { close(sock); } 
  return  status;
}
