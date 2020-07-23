#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "q_macros.h"
#include "do_string.h"


int
do_string(
    lua_State *L,
    const char *const args,
    const char *const body
    )
{
  int status = 0;
  status = luaL_dostring(L, body);
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L, -1));
  }
  cBYE(status);
  // getting the output values from Lua stack
  int nargs = lua_gettop(L);
  if ( nargs == 0 ) { return status; }
  fprintf(stdout, "[ ");
  for ( int i = 1; i <= nargs; i++ ) {
    if ( i > 1 ) { 
      fprintf(stdout, ", ");
      if ( lua_isstring(L, i) ) {
        const char * arg_value = lua_tostring(L, i);
        fprintf(stdout, "\"%s\" ", arg_value);
      }
      else if ( lua_isnumber(L, i) ) {
        double  arg_value = lua_tonumber(L, i);
        fprintf(stdout, "%lf", arg_value);
      }
      else if ( lua_isboolean(L, i) ) {
        bool  arg_value = lua_toboolean(L, i);
        fprintf(stdout, "%s", arg_value ? "true" : "false");
      }
      else {
        go_BYE(-1);
      }
    }
  }
  fprintf(stdout, "]\n");
  // completely clear the stack before return
  lua_settop(L, 0);

BYE:
  return status;
}
