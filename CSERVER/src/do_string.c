#include "q_incs.h"
#include "do_string.h"

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

extern lua_State *g_L_Q; 
extern FILE *stdout;

int
do_string(
    const char *const args,
    const char *const body
    )
{
  int status = 0;
  status = luaL_dostring(g_L_Q, body);
  mcr_chk_lua_rslt(status);
  // getting the output values from Lua stack
  int nargs = lua_gettop(g_L_Q);
  for ( int i = 1; i <= nargs; i++ ) {
    if ( lua_isstring(g_L_Q, i) ) {
      char * arg_value = lua_tostring(g_L_Q, i);
      fprintf(stdout, "%s\t", arg_value);
    }
  }
  // completely clear the stack before return
  lua_settop(g_L_Q, 0);

BYE:
  return status;
}
