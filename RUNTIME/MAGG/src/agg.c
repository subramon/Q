#define LUA_LIB

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"
#include "scalar_struct.h"

#include "q_incs.h"
#include "cmem_struct.h"

#include "hmap_common.h"
#include "_hmap_types.h"
#include "_hmap_del.h"
#include "_hmap_instantiate.h"
#include "_hmap_put.h"

int luaopen_libagg (lua_State *L);
//----------------------------------------
static int l_agg_new( lua_State *L) 
{
  int status = 0;
  hmap_t *ptr_hmap = NULL;

  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  // undefined symbol : luaL_checktable(L, 1); 
  // The table is here just to improve my understanding
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking

  int tbl_sz = luaL_getn(L, 1);  /* get size of table */
  if ( tbl_sz != HMAP_NUM_VALS ) { go_BYE(-1); }

  for ( int i = 1; i <= tbl_sz; i++ ) { 
    char buf[16];
    lua_rawgeti(L, 1, i); 
    int n = lua_gettop(L); if ( n != (num_args+1) ) { go_BYE(-1); }
    const char *x = luaL_checkstring(L, 1+1);
    sprintf(buf, "string_%d", i);
    if ( ( x == NULL ) || ( strcmp(x, buf) != 0 ) ) { go_BYE(-1); }
    lua_pop(L, 1);
    n = lua_gettop(L); if ( n != (num_args  ) ) { go_BYE(-1); }
  }

  ptr_hmap = (hmap_t *)lua_newuserdata(L, sizeof(hmap_t));
  return_if_malloc_failed(ptr_hmap);
  memset(ptr_hmap, '\0', sizeof(hmap_t));
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
static int l_agg_meta( lua_State *L) 
{
  int status = 0;

  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  hmap_t *ptr_hmap = (hmap_t *)luaL_checkudata(L, 1, "Aggregator");
  // Now return table of meta data  
  lua_newtable(L);

  //--------------------------
  lua_pushstring(L, "size");
  lua_pushnumber(L, ptr_hmap->size);
  lua_settable(L, -3);
  //--------------------------
  lua_pushstring(L, "nitems");
  lua_pushnumber(L, ptr_hmap->nitems);
  lua_settable(L, -3);
  //--------------------------
  lua_pushstring(L, "minsize");
  lua_pushnumber(L, ptr_hmap->minsize);
  lua_settable(L, -3);

  return 1;  
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
static int l_agg_put1( lua_State *L) 
{
  int status = 0;
  bool is_updated; 
  val_t newval, oldval;
  keytype key;
  uint64_t num_probes = 0;

  memset(&newval, '\0', sizeof(val_t));
  memset(&oldval, '\0', sizeof(val_t));
  int num_args = lua_gettop(L); if ( num_args != 3 ) { go_BYE(-1); }
  hmap_t *ptr_hmap = (hmap_t *)luaL_checkudata(L, 1, "Aggregator");
  SCLR_REC_TYPE *ptr_key = luaL_checkudata(L, 2, "Scalar"); 
  key = ptr_key->cdata.valI8; // AUTO GENERATE TODO 

  if ( !lua_istable(L, 3) ) { go_BYE(-1); }
  luaL_checktype(L, 3, LUA_TTABLE ); // another way of checking
  int num_vals = luaL_getn(L, 3);  /* get size of table */
  if ( num_vals != HMAP_NUM_VALS ) { go_BYE(-1); }

  for ( int i = 1; i <= num_vals; i++ ) { 
    lua_rawgeti(L, 2+1, i); 
    SCLR_REC_TYPE *ptr_val = luaL_checkudata(L, 3+1, "Scalar"); 
    switch ( i )  {
      // START AUTO GENERATE TODO 
      case 1 : oldval.val_1 = ptr_val->cdata.valF4; break;
      case 2 : oldval.val_2 = ptr_val->cdata.valI1; break;
      case 3 : oldval.val_3 = ptr_val->cdata.valI2; break;
      case 4 : oldval.val_4 = ptr_val->cdata.valI4; break;
               // STOP AUTO GENERATE TODO 
    }
    lua_pop(L, 1);
    int n = lua_gettop(L); if ( n != (num_args  ) ) { go_BYE(-1); }
  }
  status = hmap_put(ptr_hmap, key, oldval, &newval, &is_updated, &num_probes);

  // Now return table of strings 
  lua_newtable(L);
  for ( int i = 1; i <= num_vals; i++ ) { 
    lua_pushnumber(L, i);
    SCLR_REC_TYPE *ptr_val_sclr = lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
    switch ( i )  {
      // START AUTO GENERATE TODO 
      case 1 : 
        ptr_val_sclr->cdata.valF4 = oldval.val_1; 
        strcpy(ptr_val_sclr->field_type, "F4");
        break;
      case 2 : 
        ptr_val_sclr->cdata.valI1 = oldval.val_2; 
        strcpy(ptr_val_sclr->field_type, "I1");
        break;
      case 3 : 
        ptr_val_sclr->cdata.valI2 = oldval.val_3; 
        strcpy(ptr_val_sclr->field_type, "I2");
        break;
      case 4 : 
        ptr_val_sclr->cdata.valI4 = oldval.val_4; 
        strcpy(ptr_val_sclr->field_type, "I4");
        break;
      // STOP AUTO GENERATE TODO 
    }
    luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
    lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
    lua_settable(L, -3);
  }
  lua_pushboolean(L, is_updated);
  return 2;  
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
static int l_agg_get1( lua_State *L) 
{
  int status = 0;
  bool is_found; 
  val_t oldval;
  keytype key;
  cnttype cnt;
  uint64_t num_probes = 0;

  memset(&oldval, '\0', sizeof(val_t));
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  hmap_t *ptr_hmap = (hmap_t *)luaL_checkudata(L, 1, "Aggregator");
  SCLR_REC_TYPE *ptr_key = luaL_checkudata(L, 2, "Scalar"); 
  key = ptr_key->cdata.valI8; // AUTO GENERATE TODO 

  status = hmap_get(ptr_hmap, key, &oldval, &cnt, &is_found, &num_probes);

  lua_pushboolean(L, is_found);
  if ( !is_found ) { return 1; }
  // return oldval as table of scalars
  lua_pushnumber(L, cnt);
  lua_newtable(L);
  for ( int i = 1; i <= HMAP_NUM_VALS; i++ ) { 
    lua_pushnumber(L, i);
    SCLR_REC_TYPE *ptr_val_sclr = lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
    switch ( i )  {
      // START AUTO GENERATE TODO 
      case 1 : 
        ptr_val_sclr->cdata.valF4 = oldval.val_1; 
        strcpy(ptr_val_sclr->field_type, "F4");
        break;
      case 2 : 
        ptr_val_sclr->cdata.valI1 = oldval.val_2; 
        strcpy(ptr_val_sclr->field_type, "I1");
        break;
      case 3 : 
        ptr_val_sclr->cdata.valI2 = oldval.val_3; 
        strcpy(ptr_val_sclr->field_type, "I2");
        break;
      case 4 : 
        ptr_val_sclr->cdata.valI4 = oldval.val_4; 
        strcpy(ptr_val_sclr->field_type, "I4");
        break;
      // STOP AUTO GENERATE TODO 
    }
    luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
    lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
    lua_settable(L, -3);
  }
  return 3;  
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
static int l_agg_del1( lua_State *L) 
{
  int status = 0;
  bool is_found; 
  val_t oldval;
  keytype key;
  uint64_t num_probes = 0;

  memset(&oldval, '\0', sizeof(val_t));
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  hmap_t *ptr_hmap = (hmap_t *)luaL_checkudata(L, 1, "Aggregator");
  SCLR_REC_TYPE *ptr_key = luaL_checkudata(L, 2, "Scalar"); 
  key = ptr_key->cdata.valI8; // AUTO GENERATE TODO 

  status = hmap_del(ptr_hmap, key, &is_found, &oldval, &num_probes);

  lua_pushboolean(L, is_found);
  if ( !is_found ) { return 1; }
  // return oldval as table of scalars
  lua_newtable(L);
  for ( int i = 1; i <= HMAP_NUM_VALS; i++ ) { 
    lua_pushnumber(L, i);
    SCLR_REC_TYPE *ptr_val_sclr = lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
    switch ( i )  {
      // START AUTO GENERATE TODO 
      case 1 : 
        ptr_val_sclr->cdata.valF4 = oldval.val_1; 
        strcpy(ptr_val_sclr->field_type, "F4");
        break;
      case 2 : 
        ptr_val_sclr->cdata.valI1 = oldval.val_2; 
        strcpy(ptr_val_sclr->field_type, "I1");
        break;
      case 3 : 
        ptr_val_sclr->cdata.valI2 = oldval.val_3; 
        strcpy(ptr_val_sclr->field_type, "I2");
        break;
      case 4 : 
        ptr_val_sclr->cdata.valI4 = oldval.val_4; 
        strcpy(ptr_val_sclr->field_type, "I4");
        break;
      // STOP AUTO GENERATE TODO 
    }
    luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
    lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
    lua_settable(L, -3);
  }
  return 2;  
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------
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
  uint32_t minsize = luaL_checknumber(L, 2);
  status = hmap_instantiate(ptr_hmap, minsize); cBYE(status);
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
  hmap_t *ptr_agg = (hmap_t *)luaL_checkudata(L, 1, "Aggregator");
  // TODO status = agg_check(ptr_agg); cBYE(status);
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
    { "del1",         l_agg_del1 },
    { "delete",       l_agg_free   },
    { "get1",         l_agg_get1 },
    { "instantiate",  l_agg_instantiate },
    { "meta",         l_agg_meta },
    { "put1",         l_agg_put1 },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg aggregator_functions[] = {
    { "new",          l_agg_new },
    { "check",        l_agg_check },
    { "del1",         l_agg_del1 },
    { "delete",       l_agg_free   },
    { "get1",         l_agg_get1 },
    { "instantiate",  l_agg_instantiate },
    { "meta",         l_agg_meta },
    { "put1",         l_agg_put1 },
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
