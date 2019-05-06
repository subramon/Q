#include "q_incs.h"
#include <readline/readline.h>
#include <readline/history.h>
#include <curl/curl.h>

extern
int
request_server(
    CURL *ch,
    char * input,
    const char * url
    );


