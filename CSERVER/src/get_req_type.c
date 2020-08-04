#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "q_types.h"
#include "auxil.h"
#include "get_req_type.h"
Q_REQ_TYPE
get_req_type(
    const char *api
    )
{
  if (strcasecmp(api, "DoString") == 0) {
    return DoString;
  }
  else if (strcasecmp(api, "DoFile") == 0) {
    return DoFile;
  }
  else if (strcasecmp(api, "Diagnostics") == 0) {
    return Diagnostics;
  }
  else if (strcasecmp(api, "Halt") == 0) {
    return Halt;
  }
  else if (strcasecmp(api, "Ignore") == 0) {
    return Ignore;
  }
  else if (strcasecmp(api, "Restart") == 0) {
    return Restart;
  }
  else if ( strcasecmp(api, "favicon.ico") == 0 ) { 
    return Ignore;
  }
  else {
    fprintf(stderr,  "Unknown API = %s \n", api);
    return Undefined;
  }
  return Undefined;
}
