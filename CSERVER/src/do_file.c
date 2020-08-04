#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>
#include <string.h>

#include "q_macros.h"
#include "auxil.h"
#include "isfile.h"
#include "do_file.h"


int
do_file(
    lua_State *L,
    const char *const args,
    const char *const body
    )
{
  int status = 0;
  status = luaL_dostring(L, body);
  char *cptr = strstr(args, "File=");
  if ( cptr == NULL ) { go_BYE(-1); }
  char *file_name = (char *)args + strlen("File=");
  if ( !isfile(file_name) ) { go_BYE(-1); }

  status = luaL_dofile(L, file_name);
  if ( status != 0 ) { 
    fprintf(stderr, "Lua load : %s\n", lua_tostring(L, -1));
    fprintf(stderr, "{ \"error\": \"%s\"}",lua_tostring(L, -1));
    lua_pop(L, 1); go_BYE(-1);
  }
  cBYE(status);
BYE:
  return status;
}
