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
  lua_State *L
  )
{
  int status = 0; 

  status = luaL_dostring(L, "require 'Q/CSERVER/src/config'");
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }
  cBYE(status); 
  *ptr_L = L;
BYE:
  return status;
}
