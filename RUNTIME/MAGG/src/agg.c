#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"
#include "scalar_struct.h"

#include "q_incs.h"
#include "core_agg.h"
#include "cmem_struct.h"

#include "hmap_common.h"
#include "_hmap_types.h"

int luaopen_libagg (lua_State *L);
//----------------------------------------
static int l_agg_new( lua_State *L) 
{
  int status = 0;
  hmap_t *ptr_hmap = NULL;

  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  int minsize       = luaL_checknumber(L, 1);
  // undefined symbol : luaL_checktable(L, 2); 
  // The table is here just to improve my understanding
  if ( !lua_istable(L, 2) ) { go_BYE(-1); }
  luaL_checktype(L, 2, LUA_TTABLE ); // another way of checking

  int tbl_sz = luaL_getn(L, 2);  /* get size of table */
  if ( tbl_sz != HMAP_NUM_VALS ) { go_BYE(-1); }

  for ( int i = 1; i <= tbl_sz; i++ ) { 
    char buf[16];
    lua_rawgeti(L, 2, i); 
    int n = lua_gettop(L); if ( n != (num_args+1) ) { go_BYE(-1); }
    const char *x = luaL_checkstring(L, 2+1);
    sprintf(buf, "string_%d", i);
    if ( ( x == NULL ) || ( strcmp(x, buf) != 0 ) ) { go_BYE(-1); }
    lua_pop(L, 1);
    n = lua_gettop(L); if ( n != (num_args  ) ) { go_BYE(-1); }
  }

  ptr_hmap = (hmap_t *)lua_newuserdata(L, sizeof(hmap_t));
  return_if_malloc_failed(ptr_hmap);
  memset(ptr_hmap, '\0', sizeof(AGG_REC_TYPE));
  status = hmap_instantiate(ptr_hmap, minsize); cBYE(status);
  luaL_getmetatable(L, "Aggregator"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  // Now return table of strings 
  lua_newtable(L);
  for ( int i = 1; i <= tbl_sz; i++ ) { 
    char buf[16];
    sprintf(buf, "string_%d", i);
    lua_pushnumber(L, i);
    lua_pushstring(L, buf);
    lua_settable(L, -3);
  }
  return 1+1;  // 1 for Aggregator, 1 for table of strings
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
static int l_agg_free( lua_State *L) {
  int status = 0;
  hmap_t *ptr_hmap = (hmap_t *)luaL_checkudata(L, 1, "Aggregator");
  hmap_destroy(ptr_hmap); 
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_agg_instantiate( lua_State *L) {
  int status = 0;
  hmap_t *ptr_hmap = (hmap_t *)luaL_checkudata(L, 1, "Aggregator");
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
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
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static const struct luaL_Reg aggregator_methods[] = {
    { "__gc",         l_agg_free   },
    { "check",        l_agg_check },
    { "delete",       l_agg_free   },
    { "instantiate",  l_agg_instantiate },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg aggregator_functions[] = {
    { "new",          l_agg_new },
    { "check",        l_agg_check },
    { "delete",       l_agg_free   },
    { "instantiate",  l_agg_instantiate },
    { NULL,  NULL         }
  };

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
