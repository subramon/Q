#define LUA_LIB

#define ALIGNMENT  256 // TODO P2 DOCUMENT AND PLACE CAREFULLY

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"
#include "scalar.h"

#include "q_incs.h"
#include "core_agg.h"

int luaopen_libagg (lua_State *L);
//----------------------------------------
static int l_agg_new( lua_State *L) 
{
  int status = 0;
  AGG_REC_TYPE *ptr_agg = NULL;

  const char * const keytype  = luaL_checkstring(L, 1);
  const char * const valtype  = luaL_checkstring(L, 2);
  int initial_size = 0;
  if ( lua_gettop(L) > 3 ) {
    initial_size            = luaL_checknumber(L, 3);
  }
  if ( initial_size < 0 ) { go_BYE(-1); }
  ptr_agg = (AGG_REC_TYPE *)lua_newuserdata(L, sizeof(AGG_REC_TYPE));
  return_if_malloc_failed(ptr_agg);
  memset(ptr_agg, '\0', sizeof(AGG_REC_TYPE));
  luaL_getmetatable(L, "Aggregator"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = agg_new(keytype, valtype, initial_size, ptr_agg);
  cBYE(status);

  return 1; // Used to be return 2 because of errbuf return
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
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
static int l_agg_set_name( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  const char * const name  = luaL_checkstring(L, 2);
  status = agg_set_name(ptr_agg, name); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
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
static int l_agg_get1( lua_State *L) {
  SCLR_REC_TYPE *ptr_old_val = NULL;
  ptr_old_val = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_old_val, '\0', sizeof(SCLR_REC_TYPE));

  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  SCLR_REC_TYPE *ptr_key = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  const char * const val_qtype = luaL_checkstring(L, 3);

  strcpy(ptr_old_val->field_type, val_qtype);
  bool is_found;
  int status = agg_get1(ptr_key, val_qtype, &(ptr_old_val->cdata), &is_found,ptr_agg); 
  if ( status < 0 ) { WHEREAMI; goto BYE; }
  if ( !is_found  ) {           goto BYE; }
  luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 1;
}
//----------------------------------------
static int l_agg_put1( lua_State *L) {
  SCLR_REC_TYPE *ptr_old_val = NULL;
  ptr_old_val = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_old_val, '\0', sizeof(SCLR_REC_TYPE));

  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  SCLR_REC_TYPE *ptr_key = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  SCLR_REC_TYPE *ptr_val = (SCLR_REC_TYPE *)luaL_checkudata(L, 3, "Scalar");

  int update_type = 1; // TODO UNDO HARD CODE 
  if ( lua_gettop(L) > 4 ) {
    const char * const str_update_type = luaL_checkstring(L, 4);
    if ( strcasecmp(str_update_type, "SET") == 0 ) {
      update_type = 1;
    }
    else if ( strcasecmp(str_update_type, "INCR") == 0 ) {
      update_type = 2;
    }
    else {
      WHEREAMI; goto BYE;
    }
  }
  strcpy(ptr_old_val->field_type, ptr_val->field_type);
  int status = agg_put1(ptr_key, ptr_val, update_type, 
      &(ptr_old_val->cdata), ptr_agg); 
  if ( status < 0 ) { WHEREAMI; goto BYE; }
  luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
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
    lua_pushstring(L, __func__);
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
    { "put1",         l_agg_put1 },
    { "get1",         l_agg_get1 },
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
    { "put1",         l_agg_put1 },
    { "get1",         l_agg_get1 },
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
