#include <malloc.h>
#include <string.h>
#include <signal.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h>
#include "q_macros.h"
#include "q_types.h"
#include "mmap.h"
#include "auxil.h"
#include "q_process_req.h"
#include "extract_api_args.h"
#include "get_body.h"
#include "get_req_type.h"
#include "halt_server.h"
#include "mk_state.h"
#include "q_handler.h"
#include "q_server_struct.h"
// #include <event.h>
#include <evhttp.h>
#include <event2/http.h>
#include <event2/buffer.h>
#include <event2/keyvalq_struct.h>

int 
main(
    int argc, 
    char **argv
    )
{
  int status = 0;
  q_server_t *q_server = NULL;

  struct evhttp *httpd = NULL;
  struct event_base *base = NULL;
  signal(SIGINT, halt_server);
  //----------------------------------
  if ( argc != 1 ) { go_BYE(-1); }
  //----------------------------------
  q_server = malloc(1 * sizeof(q_server_t));
  memset(q_server, 0,  (1 * sizeof(q_server_t)));
  status = mk_state(&q_server); cBYE(status);
  //----------------------------------
  base = event_base_new();
  httpd = evhttp_new(base);
  evhttp_set_max_headers_size(httpd, MAX_HEADERS_SIZE);
  evhttp_set_max_body_size(httpd, MAX_LEN_BODY);
  status = evhttp_bind_socket(httpd, "0.0.0.0", q_server->port); 
  if ( status < 0 ) { 
    fprintf(stderr, "Port %d busy \n", q_server->port); go_BYE(-1);
  }
  q_server->base = base;
  evhttp_set_gencb(httpd, q_handler, q_server);
  event_base_dispatch(base);    
  evhttp_free(httpd);
  event_base_free(base);
BYE:
  if ( q_server != NULL ) { 
    free_if_non_null(q_server->body);
    free_if_non_null(q_server->rslt);
    free_if_non_null(q_server->qc_flags);
    free_if_non_null(q_server->q_data_dir);
  }
  free_if_non_null(q_server);
  return status;
}
