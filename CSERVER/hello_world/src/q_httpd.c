#include <signal.h>
#include "q_incs.h"
#include "q_globals.h"

#include "init.h"
#include "mmap.h"
#include "auxil.h"
#include "q_process_req.h"
#include "extract_api_args.h"
#include "get_body.h"
#include "get_req_type.h"
#include "setup.h"
#include "halt_server.h"

// #include <event.h>
#include <evhttp.h>
#include <event2/http.h>
#include <event2/buffer.h>
#include <event2/keyvalq_struct.h>

// These two lines should be in globals but there is this 
// unnamed struct in maxmind that throws off a gcc warning

int g_l_global_variable;

char out_file[Q_MAX_LEN_FILE_NAME+1];
char err_file[Q_MAX_LEN_FILE_NAME+1];
FILE *stdout;
FILE *stderr;

extern void 
generic_handler(
    struct evhttp_request *req, 
    void *arg
    );

void 
generic_handler(
    struct evhttp_request *req, 
    void *arg
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0; char *alt_X = NULL;
  Q_REQ_TYPE req_type = Undefined;
  uint64_t t_start = RDTSC();
  struct event_base *base = (struct event_base *)arg;
  char api[Q_MAX_LEN_API_NAME+1]; 
  char args[Q_MAX_LEN_ARGS+1];
  struct evbuffer *opbuf = NULL;
  opbuf = evbuffer_new();
  if ( opbuf == NULL) { go_BYE(-1); }
  const char *uri = evhttp_request_uri(req);

  //--------------------------------------
  status = extract_api_args(uri, api, Q_MAX_LEN_API_NAME, 
      args, Q_MAX_LEN_ARGS);
  req_type = get_req_type(api); 
  if ( req_type == Undefined ) { go_BYE(-1); }
  status = get_body(req_type, req, g_body, Q_MAX_LEN_BODY, &g_sz_body); 
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
  status = q_process_req(req_type, api, args, g_body); cBYE(status);
  //--------------------------------------
  if ( strcmp(api, "Halt") == 0 ) {
    // TODO: P4 Need to get loopbreak to wait for these 3 statements
    // evbuffer_add_printf(opbuf, "%s\n", g_rslt);
    // evhttp_send_reply(req, HTTP_OK, "OK", opbuf);
    // evbuffer_free(opbuf);
    free_globals();
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
    // TODO: P4 is this null termination needed?
    alt_X = malloc(nX+1);
    alt_X[nX] = '\0';
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
  //--- Log time seen by clients
  if ( ( req_type == DoString ) || ( req_type == DoFile ) ) {
    uint64_t t_stop = RDTSC();
    if ( t_stop > t_start ) { 
      uint64_t t_delta = t_stop - t_start;
    }
  }
  free_if_non_null(alt_X); 
  //--------------------
}

int 
main(
    int argc, 
    char **argv
    )
{
  // signal(SIGINT, halt_server); TODO 
  int status = 0;
  struct evhttp *httpd;
  struct event_base *base;
  int port = 0;
  signal(SIGINT, halt_server);

  zero_globals();
  //----------------------------------
  if ( argc != 1 ) { go_BYE(-1); }
  status = setup(); cBYE(status);
  port = 8000; // TODO P4 Hard coded
  //----------------------------------
  base = event_base_new();
  httpd = evhttp_new(base);
  evhttp_set_max_headers_size(httpd, Q_MAX_HEADERS_SIZE);
  evhttp_set_max_body_size(httpd, Q_MAX_LEN_BODY);
  status = evhttp_bind_socket(httpd, "0.0.0.0", port); 
  if ( status < 0 ) { 
    fprintf(stderr, "Port %d busy \n", port); go_BYE(-1);
  }
  evhttp_set_gencb(httpd, generic_handler, base);
  event_base_dispatch(base);    
  evhttp_free(httpd);
  event_base_free(base);
BYE:
  free_globals();
  return status;
}
