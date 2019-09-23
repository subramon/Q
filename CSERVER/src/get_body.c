#include "q_incs.h"
#include "auxil.h"
#include "get_body.h"

int 
get_body(
    Q_REQ_TYPE req_type,
    struct evhttp_request *req,
    char *body, // [n_body+1]
    int n_body,
    int *ptr_sz_body
    )
{
  int status = 0;
  struct evbuffer *inbuf = NULL;

  *ptr_sz_body = 0;
  memset(body, '\0', n_body+1);
  inbuf = evhttp_request_get_input_buffer(req);
  if ( evbuffer_get_length(inbuf) > 0 ) {
    *ptr_sz_body = evbuffer_remove(inbuf, body, n_body);
    if ( *ptr_sz_body > n_body ) { 
      fprintf(stderr, "Post body is larger than maximum allowed size");
      go_BYE(-1);
    }
  }
  /* In this code, we do not verify contents of body */
BYE:
  return status;
}
