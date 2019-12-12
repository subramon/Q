#define LUA_LIB

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"

#include "_isdir.h"
#include "_isfile.h"

int luaopen_libcutils (lua_State *L);

static int l_cutils_isdir( 
    lua_State *L
    )
{
  const char *const dir = luaL_checkstring(L, 1);
  bool exists = isdir(dir);
  lua_pushboolean(L, exists);
  return 1;
}
//----------------------------------------
static int l_cutils_isfile( 
    lua_State *L
    )
{
  const char *const dir = luaL_checkstring(L, 1);
  bool exists = isfile(dir);
  lua_pushboolean(L, exists);
  return 1;
}
//----------------------------------------
static int l_cutils_delete( 
    lua_State *L
    )
{
  const char *const filename = luaL_checkstring(L, 1);
  if ( ( filename == NULL ) || ( *filename == '\0' ) )  {
    WHEREAMI; goto BYE;
  }
  int status = remove(filename);
  if ( status != 0 ) { WHEREAMI; goto BYE; }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_cutils_currentdir( 
    lua_State *L
    )
{
  int bufsz = 1024;
  char buf[bufsz];
  memset(buf, '\0', bufsz);
  char *cptr = getcwd(buf, bufsz-1);
  if ( cptr != buf ) { WHEREAMI; goto BYE; }
  lua_pushstring(L, buf);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static const struct luaL_Reg cutils_methods[] = {
    { "currentdir",  l_cutils_currentdir },
    { "delete",      l_cutils_delete },
    { "isdir",       l_cutils_isdir },
    { "isfile",      l_cutils_isfile },
    { NULL,  NULL         }
};
 
static const struct luaL_Reg cutils_functions[] = {
    { "currentdir",  l_cutils_currentdir },
    { "delete",      l_cutils_delete },
    { "isdir",       l_cutils_isdir },
    { "isfile",      l_cutils_isfile },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/
int luaopen_libcutils (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "cutils");
  /* Duplicate the metatable on the stack (We know have 2). */
  lua_pushvalue(L, -1);
  /* Pop the first metatable off the stack and assign it to __index
   * of the second one. We set the metatable for the table to itself.
   * This is equivalent to the following in lua:
   * metatable = {}
   * metatable.__index = metatable
   */
  lua_setfield(L, -2, "__index");

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  luaL_register(L, NULL, cutils_methods);

  /* Register cutils in types table */
  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
  if (status != 0 ) {
    printf("Running require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  } 
  luaL_getmetatable(L, "cutils");
  lua_pushstring(L, "cutils");
  status =  lua_pcall(L, 2, 0, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering type failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  /* Register the object.func functions into the table that is at the
   op of the stack. */
  
  // Registering with Q
  status = luaL_dostring(L, "return require('Q/q_export').export");
  if (status != 0 ) {
    printf("Running Q registration require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  }
  lua_pushstring(L, "cutils");
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, cutils_functions);
  status = lua_pcall(L, 2, 1, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering with q_export failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  
  return 1;
}
#ifdef OLD
  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, cutils_functions);

  return 1;
#endif
