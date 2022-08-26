#include "web_struct.h"
#include "handler.h"
extern int
process_req(
    req_type_t req_type,
    const char *const api,
    const char *args,
    const char *body,
    web_info_t *W,
    char *outbuf, // [sz_outbuf] 
    size_t sz_outbuf,
    char *errbuf, // [sz_errbuf] 
    size_t sz_errbuf,
    img_info_t *ptr_img_info
    );
