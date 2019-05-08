#define LUA_LIB

#define ALIGNMENT  256 // TODO P2 DOCUMENT AND PLACE CAREFULLY

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "core_agg.h"

//----------------------------------------
static int l_agg_new( lua_State *L) 
{
  int status = 0;
  AGG_REC_TYPE *ptr_agg = NULL;

  int initial_size            = luaL_checknumber(L, 1);
  const char * const keytype  = luaL_checkstring(L, 2);
  const char * const valtype  = luaL_checkstring(L, 3);

  ptr_agg = (AGG_REC_TYPE *)lua_newuserdata(L, sizeof(AGG_REC_TYPE));
  return_if_malloc_failed(ptr_agg);
  memset(ptr_agg, '\0', sizeof(AGG_REC_TYPE));
  luaL_getmetatable(L, "Aggregator"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = agg_new(initial_size, keytype, valtype, ptr_agg);
  cBYE(status);

  return 1; // Used to be return 2 because of errbuf return
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not create aggregator\n");
  return 2;
}
//-----------------------
static int l_agg_delete( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  status = agg_delete(ptr_agg); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: agg_end_write. ");
  return 2;
}
//----------------------------------------
static int l_agg_check( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  status = agg_check(ptr_agg); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: agg_end_write. ");
  return 2;
}
//----------------------------------------
static int l_agg_set_name( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  const char * const name  = luaL_checkstring(L, 2);
  status = agg_set_name(ptr_agg, name); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: agg_set_name. ");
  return 2;
}
//-----------------------------------
static int l_agg_get_name( lua_State *L) {
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  lua_pushstring(L, ptr_agg->name);
  return 1;
}
//----------------------------------------
static int l_agg_num_elements( lua_State *L) {
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  lua_pushnumber(L, agg_num_elements(ptr_agg));
  return 1;
}
//----------------------------------------
static int l_agg_meta( lua_State *L) {
  char opbuf[4096]; // TODO P3 try not to hard code bound
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");

  memset(opbuf, '\0', 4096);
  int status = agg_meta(ptr_agg, opbuf);
  if ( status == 0) { 
    lua_pushstring(L, opbuf);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, "ERROR: agg_check. ");
    return 2;
  }
}
//----------------------------------------
static const struct luaL_Reg aggregator_methods[] = {
    { "check",        l_agg_check },
    { "__gc",         l_agg_delete   },
    { "get_name",     l_agg_get_name },
    { "meta",         l_agg_meta },
    { "num_elements", l_agg_num_elements },
    { "set_name",     l_agg_set_name },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg aggregator_functions[] = {
    { "new",          l_agg_new },
    { "check",        l_agg_check },
    { "delete",       l_agg_delete   },
    { "get_name",     l_agg_get_name },
    { "meta",         l_agg_meta },
    { "num_elements", l_agg_num_elements },
    { "set_name",     l_agg_set_name },
    { NULL,  NULL         }
  };

  /*
  ** Implementation of luaL_testudata which will return NULL in case if udata is not of type tname
  ** TODO: Check for the appropriate location for this function
  */
  LUALIB_API void *luaL_testudata (lua_State *L, int ud, const char *tname) {
    void *p = lua_touserdata(L, ud);
    if (p != NULL) {  /* value is a userdata? */
      if (lua_getmetatable(L, ud)) {  /* does it have a metatable? */
        lua_getfield(L, LUA_REGISTRYINDEX, tname);  /* get correct metatable */
        if (lua_rawequal(L, -1, -2)) {  /* does it have the correct mt? */
          lua_pop(L, 2);  /* remove both metatables */
          return p;
        }
      }
    }
    return NULL;  /* to avoid warnings */
  }
   
  /*
  ** Open aggregator library
  */
  int luaopen_libagg (lua_State *L) {
    /* Create the metatable and put it on the stack. */
    luaL_newmetatable(L, "Aggregator");
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
    luaL_register(L, NULL, aggregator_methods);

    int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
    if ( status != 0 ) {
      WHEREAMI;
      fprintf(stderr, "Running require failed:  %s\n", lua_tostring(L, -1));
      exit(1);
    } 
    luaL_getmetatable(L, "Aggregator");
    lua_pushstring(L, "Aggregator");
    status =  lua_pcall(L, 2, 0, 0);
    if (status != 0 ) {
       WHEREAMI; 
       fprintf(stderr, "Type Registering failed: %s\n", lua_tostring(L, -1));
       exit(1);
    }

    /* Register the object.func functions into the table that is at the
     * top of the stack. */
    lua_createtable(L, 0, 0);
    luaL_register(L, NULL, aggregator_functions);
    // Why is return code not 0
    return 1;
}
