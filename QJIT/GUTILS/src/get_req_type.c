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
  else if (strcasecmp(api, "HaltMaster") == 0) {
    return HaltMaster;
  }
  //-----------------------------
  else if (strcasecmp(api, "Disk") == 0) {
    return Disk;
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
  else if (strcasecmp(api, "favicon.ico") == 0) {
    return Favicon;
  }
  //--------------------------------------------------
  // for out of band 
  else if (strcasecmp(api, "SetDisk") == 0) {
    return SetDisk;
  }
  //-----------------------------
  else if (strcasecmp(api, "SetMemory") == 0) {
    return SetMemory;
  }
  //-----------------------------
  else if (strcasecmp(api, "SetMaster") == 0) {
    return SetMaster;
  }
  //-----------------------------
  else {
    fprintf(stderr,  "Unknown API = %s \n", api);
    return Undefined;
  }
}
