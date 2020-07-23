#include <malloc.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
// #include <event.h>
#include <evhttp.h>
#include <event2/http.h>
#include <event2/buffer.h>
#include <event2/keyvalq_struct.h>

#include "q_types.h"
#include "q_macros.h"

#include "mmap.h"
#include "auxil.h"
#include "q_process_req.h"
#include "extract_api_args.h"
#include "get_body.h"
#include "get_req_type.h"
#include "q_server_struct.h"

#include "q_handler.h"

#define MAX_HEADERS_SIZE 2048-1
#define MAX_LEN_BODY     65536-1
#define MAX_LEN_API_NAME 32-1
#define MAX_LEN_ARGS     128-1

void 
q_handler(
    struct evhttp_request *req, 
    void *arg
    )
{
  int status = 0;
  int n_body = 0;
  char out_file[64]; char err_file[64];
  char *X = NULL; size_t nX = 0; char *alt_X = NULL;
  Q_REQ_TYPE req_type = Undefined;
  uint64_t t_start = RDTSC();

  q_server_t *ptr_sinfo = (q_server_t *)arg;
  char *body = ptr_sinfo->body;
  char *rslt = ptr_sinfo->rslt;
  int sz_body = ptr_sinfo->sz_body;
  int sz_rslt = ptr_sinfo->sz_rslt;

  struct event_base *base = (struct event_base *)arg;
  char api[MAX_LEN_API_NAME+1]; 
  char args[MAX_LEN_ARGS+1];

  struct evbuffer *opbuf = NULL;
  opbuf = evbuffer_new();
  if ( opbuf == NULL) { go_BYE(-1); }
  const char *uri = evhttp_request_uri(req);

  memset(rslt, 0, sz_rslt);
  memset(body, 0, sz_body);
  //--------------------------------------
  status = extract_api_args(uri, api, MAX_LEN_API_NAME, 
      args, MAX_LEN_ARGS);
  req_type = get_req_type(api); 
  if ( req_type == Undefined ) { go_BYE(-1); }
  status = get_body(req_type, req, body, sz_body-1, &n_body);
  cBYE(status);
  // START: Send back stdout or stderr
  sprintf(out_file, "/tmp/_out_%llu.txt", (unsigned long long)t_start);
  sprintf(err_file, "/tmp/_err_%llu.txt", (unsigned long long)t_start);
  stdout = fopen(out_file, "w");
  stderr = fopen(err_file, "w");
  /* test redirection 
  Q.print_csv(Q.mk_col({1,2,3}, "I4"))
  */
  // STOP: Send back stdout or stderr
  status = q_process_req(req_type, api, args, ptr_sinfo); 
  cBYE(status);
  //--------------------------------------
  if ( strcmp(api, "Halt") == 0 ) {
    event_base_loopbreak(base);
  }
BYE:
  evhttp_add_header(evhttp_request_get_output_headers(req), 
      "Content-Type", "text/plain; charset=UTF-8");
  // START: Send back stdout or stderr
  fflush(stdout); fflush(stderr);
  char *ret_file = NULL;
  int code = 0;
  char ret_type[8]; // TODO P4 improve name 
  if ( status < 0 ) { 
    ret_file = err_file;
    code = HTTP_BADREQUEST;
    strcpy(ret_type, "ERROR");
  }
  else {
    ret_file = out_file;
    code = HTTP_OK;
    strcpy(ret_type, "OK");
  }
  status = rs_mmap(ret_file, &X, &nX, 0); 
  
  if ( ( status < 0 ) || ( X == NULL ) || ( nX == 0 ) ) {
    evbuffer_add_printf(opbuf, "%s\n","");
  }
  else {
    alt_X = malloc(nX+1);
    alt_X[nX] = '\0';
    memset(alt_X, 0, nX+1);
    memcpy(alt_X, X, nX);
    evbuffer_add_printf(opbuf, "%s\n", alt_X);
    free_if_non_null(alt_X); 
  }
  evhttp_send_reply(req, code, ret_type, opbuf);
  evbuffer_free(opbuf);
  if ( ( X != NULL ) && ( nX != 0 ) ) { munmap(X, nX); }
  fclose(stdout);
  fclose(stderr);
  unlink(out_file);
  unlink(err_file);
  // STOP: Send back stdout or stderr
}
