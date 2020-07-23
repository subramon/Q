#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "q_types.h"
#include "auxil.h"
#include "do_string.h"
#include "do_file.h"
#include "q_process_req.h"

// START FUNC DECL
int
q_process_req(
    Q_REQ_TYPE req_type,
    const char *const api,
    char * const args,
    q_server_t *ptr_sinfo
    )
  // STOP FUNC DECL
{
  int status = 0;
  lua_State *L = ptr_sinfo->L;
  const char * const body = ptr_sinfo->body;
  //-----------------------------------------
  switch ( req_type ) {
    case Undefined :
      go_BYE(-1);
      break;
      //--------------------------------------------------------
    case DoString :
      status = do_string(L, args, body); cBYE(status);
      break;
      //--------------------------------------------------------
    case DoFile :
      status = do_file(L, args, body); cBYE(status);
      break;
      //--------------------------------------------------------
    case Halt : 
      fprintf(stdout, "{ \"%s\" : \"OK\" }", api);
      break;
      //--------------------------------------------------------
    case HealthCheck : 
    case Ignore :
      fprintf(stdout, "{ \"%s\" : \"OK\" }", api);
      break;
      //--------------------------------------------------------
    default :
      go_BYE(-1);
      break;
  }
BYE:
  return status ;
}
