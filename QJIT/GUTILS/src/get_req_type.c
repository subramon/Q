#include <string.h>
#include "handler.h"
#include "get_req_type.h"
req_type_t 
get_req_type(
    const char *api
    )
{
  if (strcasecmp(api, "Ignore") == 0) {
    return Ignore;
  }
  //-----------------------------
  else if (strcasecmp(api, "Halt") == 0) {
    return Halt;
  }
  //-----------------------------
  else if (strcasecmp(api, "Memory") == 0) {
    return Memory;
  }
  //-----------------------------
  else if (strcasecmp(api, "Lua") == 0) {
    return Lua;
  }
  //--------------------------------------------------
  else {
    fprintf(stderr,  "Unknown API = %s \n", api);
    return Undefined;
  }
}
