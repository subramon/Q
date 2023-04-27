#include <pthread.h>
#include <evhttp.h>
#include "event2/http.h"
#include "q_incs.h"
#include "web_struct.h"
#include "get_req_type.h"
#include "extract_api_args.h"
#include "process_req.h"
#include "get_body.h"
#include "handler.h"
void
handler(
    struct evhttp_request *req,
    void *arg
    )
{
  int status = 0;
  char *decoded_uri = NULL;
  char  api[MAX_LEN_API+1];
  char args[MAX_LEN_ARGS+1]; memset(args, 0, MAX_LEN_ARGS+1);
  char outbuf[MAX_LEN_OUTPUT+1];
  char errbuf[MAX_LEN_ERROR+1];
  char *body = NULL; 
  memset(outbuf, '\0', MAX_LEN_OUTPUT+1); // TOOD P4 not needed
  memset(errbuf, '\0', MAX_LEN_ERROR+1); // TOOD P4 not needed
  struct evbuffer *opbuf = NULL;
  if ( arg == NULL ) { go_BYE(-1); } 
  web_info_t *web_info = (web_info_t *)arg;
  struct event_base *base = web_info->base;
  if ( base == NULL ) { go_BYE(-1); }
  opbuf = evbuffer_new();
  if ( opbuf == NULL) { go_BYE(-1); }
  const char *uri = evhttp_request_uri(req);
  decoded_uri = evhttp_decode_uri(uri);
  if ( decoded_uri == NULL ) { go_BYE(-1); }
  web_response_t web_response; 
  memset(&web_response, 0, sizeof(web_response_t));
  //--------------------------------------
  status = extract_api_args(decoded_uri, api, MAX_LEN_API, args, 
      MAX_LEN_ARGS);
  free_if_non_null(decoded_uri);
  cBYE(status);
  req_type_t rtype = get_req_type(api);
  if ( rtype  == Undefined ) { go_BYE(-1); }
  if ( strcmp(api, "Halt") == 0 ) {
    // TODO: P4 Need to get loopbreak to wait for these 3 statements
    // evbuffer_add_printf(opbuf, "%s\n", g_rslt);
    // evhttp_send_reply(req, HTTP_OK, "OK", opbuf);
    // evbuffer_free(opbuf);
    event_base_loopbreak(base);
  }
  status = get_body(req, &body); cBYE(status);

  status = process_req(rtype, api, args, body, web_info,
      outbuf, MAX_LEN_OUTPUT, errbuf, MAX_LEN_ERROR, &web_response);
  cBYE(status);
  // Handle case when something other than default is to be returned
  if ( web_response.is_set ) {
    if ( web_response.file_name == NULL ) { go_BYE(-1); } 
    // send the headers if any
    for ( int i = 0; i < web_response.num_headers; i++ ) { 
      evhttp_add_header(evhttp_request_get_output_headers(req),
          web_response.header_key[i], web_response.header_val[i]);
    }
    // open file for reading 
    int wfd = open(web_response.file_name, O_RDONLY); 
    if ( wfd < 0 ) { go_BYE(-1); } 
    // send data in file 
    status = evbuffer_add_file(opbuf, wfd, 0, -1); cBYE(status); 

    if ( web_response.is_err ) { 
      evhttp_send_reply(req, HTTP_BADREQUEST, "ERROR", opbuf);
    }
    else {
      evhttp_send_reply(req, HTTP_OK, "OK", opbuf);
    }
    close(wfd); 
    goto BYE; 
  }
  //------------------------------
  evhttp_add_header(evhttp_request_get_output_headers(req),
      "Content-Type", "application/json; charset=UTF-8");
  // Following  is to allow CAPI/PAPI interactions
  evhttp_add_header(evhttp_request_get_output_headers(req),
      "Access-Control-Allow-Origin", "*"); 
  if ( status == 0 ) { 
    evbuffer_add_printf(opbuf, "%s", outbuf); 
    evhttp_send_reply(req, HTTP_OK, "OK", opbuf);
  }
  else {
    evbuffer_add_printf(opbuf, "%s", errbuf); 
    evhttp_send_reply(req, HTTP_BADREQUEST, "ERROR", opbuf);
  }
BYE:
  if ( opbuf != NULL ) { evbuffer_free(opbuf); opbuf = NULL; }
  free_if_non_null(decoded_uri);
  // free resources in web response
  if ( web_response.file_name != NULL ) { 
    remove(web_response.file_name);
    free_if_non_null(web_response.file_name);
  }
  for ( int i = 0; i < web_response.num_headers; i++ ) { 
    free_if_non_null(web_response.header_key[i]);
    free_if_non_null(web_response.header_val[i]);
  }
  free_if_non_null(body); 
  free_if_non_null(web_response.header_key); 
  free_if_non_null(web_response.header_val); 
}
