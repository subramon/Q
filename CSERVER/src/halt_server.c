#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "q_incs.h"
#include "halt_server.h"

// extern lua_State *g_L_Q; 

void halt_server(
    int sig
    )
{
  int status = 0;
  /* TODO
  int status = luaL_dostring(g_L_Q, "Q.save()");
  if ( status != 0 ) {
    //TODO: do we require to print this message?
    fprintf(stderr, "Lua error : %s\n", lua_tostring(g_L_Q, -1));
    lua_pop(g_L_Q, 1);
    WHEREAMI;
  }
  */
  exit(status);
}
