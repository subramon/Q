#include "evhttp.h"
#ifndef __WEB_STRUCT_H 
#define __WEB_STRUCT_H 

#define MAX_LEN_FILE_NAME 63
// This is used when we want to return something more complex than
// just text (which is returned in opbuf and/or errbuf)
typedef struct _web_response_t {
  char *file_name;
  // example of a header is Content-Type: image/foo.png
  // example of a header is Content-Type: application/json; charset=UTF-8
  // above is default header 
  char **header_key; // [num_headers][...]
  char **header_val; // [num_headers][...]
  int num_headers; 
  bool is_set; // default false
  bool is_err; // default false
} web_response_t;

typedef struct _web_info_t { 
  struct event_base *base;
  bool is_out_of_band;
  int port;
} web_info_t;

#endif //  __WEB_STRUCT_H 
/* TODO 
    char buf[256]; int blen = sizeof(buf); memset(buf, 0, blen);
    char *X = NULL; size_t nX = 0;
    snprintf(buf, blen-1, "image/%s", img_info.suffix); 
    evhttp_add_header(evhttp_request_get_output_headers(req),
      "Content-Type", buf);

    status = rs_mmap(img_info.file_name, &X, &nX, 0); 
    if ( status < 0 ) { WHEREAMI; evbuffer_free(opbuf); return; }
    memset(buf, 0, blen); snprintf(buf, blen-1, "%u", nX);
    */
