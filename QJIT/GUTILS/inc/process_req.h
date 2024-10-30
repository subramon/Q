#include "web_struct.h"
#include "get_req_type.h"
extern int
process_req(
    int req_type,
    const char *const api,
    const char *args,
    const char *body,
    web_info_t *W,
    char *outbuf, // [sz_outbuf] 
    size_t sz_outbuf,
    char *errbuf, // [sz_errbuf] 
    size_t sz_errbuf,
    web_response_t *ptr_web_response
    );
