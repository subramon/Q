#include <pthread.h>
#include <evhttp.h>
#include "event2/http.h"
#include "q_incs.h"
#include "web_struct.h"
#include "rs_mmap.h"
#include "get_req_type.h"
#include "extract_api_args.h"
#include "process_req.h"
#include "rs_mmap.h"
#include "handler.h"
extern int g_halt;
void
handler(
    struct evhttp_request *req,
    void *arg
    )
{
  int status = 0;
  char *decoded_uri = NULL;
  char  api[MAX_LEN_API+1];
  char args[MAX_LEN_ARGS+1];
  char outbuf[MAX_LEN_OUTPUT+1];
  char errbuf[MAX_LEN_ERROR+1];
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
  img_info_t img_info; memset(&img_info, 0, sizeof(img_info_t));
  // If master calls halt, get out 
  if ( g_halt == 1 ) { event_base_loopbreak(base); }
  //--------------------------------------
  status = extract_api_args(decoded_uri, api, MAX_LEN_API, args, MAX_LEN_ARGS);
  cBYE(status);
  req_type_t rtype = get_req_type(api);
  if ( rtype  == Undefined ) { go_BYE(-1); }
  char *body = NULL; // Not used just yet 
  // status = get_body(req_type, req, g_body, MAX_LEN_BODY, &g_sz_body);
  // cBYE(status);
  // printf("decoded_uri = %s \n", decoded_uri);
  status = process_req(rtype, api, args, body, web_info,
      outbuf, MAX_LEN_OUTPUT, errbuf, MAX_LEN_ERROR, &img_info);
  cBYE(status);
  if ( strcmp(api, "Halt") == 0 ) {
    // TODO: P4 Need to get loopbreak to wait for these 3 statements
    // evbuffer_add_printf(opbuf, "%s\n", g_rslt);
    // evhttp_send_reply(req, HTTP_OK, "OK", opbuf);
    // evbuffer_free(opbuf);
    free_if_non_null(decoded_uri);
    event_base_loopbreak(base);
  }
BYE:
  // Handle special case when an image needs to be returned
  if ( ( status == 0 ) && ( img_info.is_set ) ) {
    char buf[256]; int blen = sizeof(buf); memset(buf, 0, blen);
    char *X = NULL; size_t nX = 0;
    snprintf(buf, blen-1, "image/%s", img_info.suffix); 
    evhttp_add_header(evhttp_request_get_output_headers(req),
      "Content-Type", buf);

    status = rs_mmap(img_info.file_name, &X, &nX, 0); 
    if ( status < 0 ) { WHEREAMI; evbuffer_free(opbuf); return; }
    memset(buf, 0, blen); snprintf(buf, blen-1, "%u", nX);

    evhttp_add_header(evhttp_request_get_output_headers(req),
      "Content-Length", buf); 
    // TODO P2 Make sure this is not vulnerable to buffer overflow 
    evbuffer_add(opbuf, X, nX); 
    evhttp_send_reply(req, HTTP_OK, "OK", opbuf);
    evbuffer_free(opbuf);
    remove(img_info.file_name); 
    free_if_non_null(decoded_uri);
    return;
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
  evbuffer_free(opbuf);
  free_if_non_null(decoded_uri);
}
