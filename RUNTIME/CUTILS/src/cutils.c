#define LUA_LIB

#include <dirent.h>
#include <regex.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"

#include "isdir.h"
#include "isfile.h"
#include "rs_mmap.h"

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
  const char *const filename = luaL_checkstring(L, 1);
  bool exists = isfile(filename);
  lua_pushboolean(L, exists);
  return 1;
}
//----------------------------------------
static int l_cutils_read( 
    lua_State *L
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  char *buf = NULL;
  const char *const filename = luaL_checkstring(L, 1);
  status = rs_mmap(filename, &X, &nX, 0); cBYE(status);
  buf = malloc(nX+1);
  return_if_malloc_failed(buf);
  memcpy(buf, X, nX);
  buf[nX] = '\0';
  lua_pushstring(L, buf);
  free(buf);
  munmap(X, nX);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
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
static int l_cutils_getfiles( 
    lua_State *L
    )
{
  DIR *d = NULL;
  struct dirent *dir;
  const char *mask = NULL;
  regex_t regex; int reti;
  const char *const dirname = luaL_checkstring(L, 1);
  if ( ( dirname == NULL ) || ( *dirname == '\0' ) )  {
    WHEREAMI; goto BYE;
  }
  /* Use mask = ".*.c" to match .c files */
  if ( lua_gettop(L) >= 2 ) {
    mask  = luaL_checkstring(L, 2);
    /* Compile regular expression */
    reti = regcomp(&regex, mask, 0);
    if ( reti != 0 ) { 
      fprintf(stderr, "Could not compile regex\n"); WHEREAMI; goto BYE;
    }
  }

  //-------------
  d = opendir(dirname);
  if ( d == NULL ) { WHEREAMI; goto BYE; }
  // Now return table of strings
  lua_newtable(L);
  int dir_idx = 1;
  while ( (dir = readdir(d)) != NULL) {
    const char *file_name = dir->d_name;
    bool include = false;
    if ( mask != NULL ) { 
      reti = regexec(&regex, file_name, 0, NULL, 0);
    }
    if ( mask == NULL ) {
      include = true;
    }
    else {
      if ( !reti ) { 
        include= true;
      }
    }
    if ( include ) {
      lua_pushnumber(L, dir_idx);
      lua_pushstring(L, file_name);
      lua_settable(L, -3);
      // printf("including %s \n", file_name);
      dir_idx++;
    }
    else {
      // printf("Excluding %s \n", file_name);
    }
  }
  closedir(d);
  if ( mask != NULL ) { 
    /* Free memory allocated to the pattern buffer by regcomp() */
    regfree(&regex);
  }
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static const struct luaL_Reg cutils_methods[] = {
    { "currentdir",  l_cutils_currentdir },
    { "getfiles",    l_cutils_getfiles },
    { "delete",      l_cutils_delete },
    { "isdir",       l_cutils_isdir },
    { "isfile",      l_cutils_isfile },
    { "read",        l_cutils_read },
    { NULL,  NULL         }
};
 
static const struct luaL_Reg cutils_functions[] = {
    { "currentdir",  l_cutils_currentdir },
    { "delete",      l_cutils_delete },
    { "getfiles",    l_cutils_getfiles },
    { "isdir",       l_cutils_isdir },
    { "isfile",      l_cutils_isfile },
    { "read",        l_cutils_read },
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
