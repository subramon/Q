#include "q_incs.h"
#include "event2/http.h"
#include "event2/buffer.h"
#include "get_body.h"

int 
get_body(
    struct evhttp_request *req,
    char **ptr_body 
    )
{
  int status = 0;
  struct evbuffer *inbuf = NULL;
  char *body       = *ptr_body;
  uint32_t n_body  = 0;

  inbuf = evhttp_request_get_input_buffer(req);
  n_body = evbuffer_get_length(inbuf);
  if ( n_body > 0 ) {
    body = malloc(n_body+1); 
    memset(body, 0, n_body+1);
    int  n = evbuffer_remove(inbuf, body, n_body);
    if ( n < 0 ) { go_BYE(-1); }
    if ( n != (int)n_body ) { go_BYE(-1); }
    *ptr_body    = body;
  }
BYE:
  return status;
}
