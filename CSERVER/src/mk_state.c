#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "q_macros.h"
#include "mk_state.h"

int
mk_state(
  lua_State **ptr_L
  )
{
  int status = 0; 

  lua_State *L = NULL; 
  // create Lua state
  L = luaL_newstate();
  if ( L == NULL ) { go_BYE(-1); }
  luaL_openlibs(L);
  // Initialize Lua State
  status = luaL_dostring(L, "require 'Q'");
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }
  cBYE(status); 
  *ptr_L = L;
BYE:
  return status;
}
