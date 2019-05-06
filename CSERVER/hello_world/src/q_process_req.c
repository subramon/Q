#include "q_incs.h"
#include "q_process_req.h"
#include "auxil.h"
#include "init.h"
#include "setup.h"
#include "do_string.h"
#include "do_file.h"

extern bool g_halt; 

// START FUNC DECL
int
q_process_req(
    Q_REQ_TYPE req_type,
    const char *const api,
    char * const args,
    const char * const body
    )
  // STOP FUNC DECL
{
  int status = 0;
  //-----------------------------------------
  switch ( req_type ) {
    case Undefined :
      go_BYE(-1);
      break;
      //--------------------------------------------------------
    case DoString :
      status = do_string(args, body); cBYE(status);
      break;
      //--------------------------------------------------------
    case DoFile :
      status = do_file(args, body); cBYE(status);
      break;
      //--------------------------------------------------------
    case Halt : 
      fprintf(stdout, "{ \"%s\" : \"OK\" }", api);
      g_halt = true;
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
