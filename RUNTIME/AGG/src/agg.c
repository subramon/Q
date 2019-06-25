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
#include "_q_rhashmap_I8_I8.h"

#include "_mk_hash_I4.h"
#include "_mk_hash_I8.h"
#include "mk_loc.h"
#include "mk_tid.h"

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
static int l_agg_free( lua_State *L) {
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
static int l_agg_get_meta( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  uint32_t nitems;
  uint32_t size;
  status = agg_get_meta(ptr_agg, &nitems, &size); cBYE(status);
  lua_pushnumber(L, nitems);
  lua_pushnumber(L, size);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_agg_del1( lua_State *L) {
  SCLR_REC_TYPE *ptr_old_val = NULL;
  ptr_old_val = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_old_val, '\0', sizeof(SCLR_REC_TYPE));

  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  SCLR_REC_TYPE *ptr_key = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  const char * const val_qtype = luaL_checkstring(L, 3);

  strcpy(ptr_old_val->field_type, val_qtype);
  bool is_found;
  int status = agg_del1(ptr_key, val_qtype, &(ptr_old_val->cdata), &is_found,ptr_agg); 
  if ( status < 0 ) { WHEREAMI; goto BYE; }
  if ( !is_found  ) { // set scalar output value to 0
  }
  luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  lua_pushboolean(L, is_found);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
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
  luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  lua_pushboolean(L, is_found);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 1;
}
static int l_agg_putn( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata( L, 1, "Aggregator");
  CMEM_REC_TYPE *keys   = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  int update_type       = luaL_checknumber(                L, 3);
  CMEM_REC_TYPE *hashes = (CMEM_REC_TYPE *)luaL_checkudata(L, 4, "CMEM");
  CMEM_REC_TYPE *locs   = (CMEM_REC_TYPE *)luaL_checkudata(L, 5, "CMEM");
  CMEM_REC_TYPE *tids   = (CMEM_REC_TYPE *)luaL_checkudata(L, 6, "CMEM");
  int num_threads       = luaL_checknumber(                L, 7);
  CMEM_REC_TYPE *vals   = (CMEM_REC_TYPE *)luaL_checkudata(L, 8, "CMEM");
  int nkeys             = luaL_checknumber(                L, 9);
  CMEM_REC_TYPE *isfs   = (CMEM_REC_TYPE *)luaL_checkudata(L, 10, "CMEM");

  q_rhashmap_I8_I8_t *hmap = ( q_rhashmap_I8_I8_t *)(ptr_agg->hmap);
  /* TODO P3: Fix following. agg.c should be just a bridge from Lua to C
   * No processing should be done here. Violated this principle */
  if ( strcmp(keys->field_type, "I4") == 0 ) {
    status = mk_hash_I4((int32_t *)keys->data, nkeys, 
        hmap->hashkey, (uint32_t *)hashes->data);
  }
  else if ( strcmp(keys->field_type, "I8") == 0 ) {
    status = mk_hash_I8((int64_t *)keys->data, nkeys, 
        hmap->hashkey, (uint32_t *)hashes->data);
  }
  else {
    go_BYE(-1);
  }
  cBYE(status);
  status = mk_loc((uint32_t *)hashes->data, nkeys, hmap->size, 
      (uint32_t *)locs->data); cBYE(status);
  status = mk_tid((uint32_t *)hashes->data, nkeys, num_threads, 
      (uint8_t *)tids->data); cBYE(status);

  status = agg_putn(ptr_agg, keys, update_type, 
      hashes, locs, tids, num_threads, vals, nkeys, isfs);
  if ( status < 0 ) { WHEREAMI; goto BYE; }
  lua_pushboolean(L, true);
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
  int update_type        = luaL_checknumber(L, 4);

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
    { "__gc",         l_agg_free   },
    { "check",        l_agg_check },
    { "del1",         l_agg_del1 },
    { "delete",       l_agg_delete },
    { "get1",         l_agg_get1 },
    { "get_name",     l_agg_get_name },
    { "meta",         l_agg_meta },
    { "get_meta",   l_agg_get_meta },
    { "put1",         l_agg_put1 },
    { "putn",         l_agg_putn },
    { "set_name",     l_agg_set_name },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg aggregator_functions[] = {
    { "new",          l_agg_new },
    { "check",        l_agg_check },
    { "delete",       l_agg_delete   },
    { "get_name",     l_agg_get_name },
    { "meta",         l_agg_meta },
    { "get_meta",   l_agg_get_meta },
    { "set_name",     l_agg_set_name },
    { "put1",         l_agg_put1 },
    { "putn",         l_agg_putn },
    { "get1",         l_agg_get1 },
    { "del1",         l_agg_del1 },
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
