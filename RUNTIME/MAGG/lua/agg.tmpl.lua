return require 'Q/UTILS/lua/code_gen' { 
  definition = [[
#include "q_incs.h"
// for lua
#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
// for other run time stuff
#include "scalar_struct.h"
#include "cmem_struct.h"
// for hmap/aggregator stuff
#include "hmap_common.h"
#include "_hmap_types.h"
#include "_hmap_del.h"
#include "_hmap_destroy.h"
#include "_hmap_get.h"
#include "_hmap_getn.h"
#include "_hmap_instantiate.h"
#include "_hmap_put.h"
#include "_hmap_putn.h"
#include "agg_struct.h" // depends on hmap_types

int luaopen_libagg${lbl} (lua_State *L);
//----------------------------------------
static int l_agg_new( lua_State *L) 
{
  int status = 0;
  AGG_REC_TYPE *ptr_agg = NULL;

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

  ptr_agg = (AGG_REC_TYPE *)lua_newuserdata(L, sizeof(AGG_REC_TYPE));
  return_if_malloc_failed(ptr_agg);
  memset(ptr_agg, '\0', sizeof(AGG_REC_TYPE));

  ptr_agg->ptr_hmap = calloc(1, sizeof(hmap_t));
  return_if_malloc_failed(ptr_agg->ptr_hmap);

  ptr_agg->ptr_metrics = calloc(1, sizeof(MET_REC_TYPE));
  return_if_malloc_failed(ptr_agg->ptr_metrics);

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
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  hmap_t *ptr_hmap = ptr_agg->ptr_hmap;
  MET_REC_TYPE *ptr_metrics = ptr_agg->ptr_metrics;
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
  //--------------------------
  lua_pushstring(L, "num_probes");
  lua_pushnumber(L, ptr_metrics->num_probes);
  lua_settable(L, -3);

  return 1;  
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
static int l_agg_getn( lua_State *L) 
{
  int status = 0;
  uint64_t num_probes = 0;
  uint32_t num_new    = 0;

  int num_args = lua_gettop(L); if ( num_args != 5 ) { go_BYE(-1); }
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  CMEM_REC_TYPE *ptr_key   = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  int num_keys  = luaL_checknumber(L, 3);
  int num_threads = luaL_checknumber(L, 4);
  
  if ( !lua_istable(L, 5) ) { go_BYE(-1); }
  luaL_checktype(L, 5, LUA_TTABLE ); // another way of checking
  int num_vals = luaL_getn(L, 5);  /* get size of table */
  if ( num_vals != HMAP_NUM_VALS ) { go_BYE(-1); }

  keytype *keys =  (keytype *)ptr_key->data;
  uint32_t *hshs =  (uint32_t *)ptr_agg->ptr_bufs->hshs;
  uint32_t *locs =  (uint32_t *)ptr_agg->ptr_bufs->locs;
  status = hmap_mk_hsh(keys, num_keys, ptr_agg->ptr_hmap->hashkey, hshs);
  status = hmap_mk_loc(hshs, num_keys, ptr_agg->ptr_hmap->size, locs);
  status = hmap_getn (ptr_agg->ptr_hmap, num_threads, 
    (keytype *)ptr_key->data, ptr_agg->ptr_bufs->locs, 
    ptr_agg->ptr_bufs->mvals, num_keys, ptr_agg->ptr_bufs->fnds);
  cBYE(status);
  for ( int i = 1; i <= num_vals; i++ ) { 
    lua_rawgeti(L, 5, i); 
    CMEM_REC_TYPE *ptr_val = luaL_checkudata(L, 5+1, "CMEM"); 
    switch ( i )  {
      // START GENERATED CODE make_getn
      ${mk_getn}
      // STOP  GENERATED CODE make_getn
    }
    lua_pop(L, 1);
    int n = lua_gettop(L); if ( n != (num_args  ) ) { go_BYE(-1); }
  }
    

  lua_pushboolean(L, true);
  return 1;  
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
static int l_agg_putn( lua_State *L) 
{
  int status = 0;
  uint64_t num_probes = 0;
  uint32_t num_new    = 0;

  int num_args = lua_gettop(L); if ( num_args != 5 ) { go_BYE(-1); }
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  CMEM_REC_TYPE *ptr_key   = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  int num_keys  = luaL_checknumber(L, 3);
  int num_threads = luaL_checknumber(L, 4);
  
  if ( !lua_istable(L, 5) ) { go_BYE(-1); }
  luaL_checktype(L, 5, LUA_TTABLE ); // another way of checking
  int num_vals = luaL_getn(L, 5);  /* get size of table */
  if ( num_vals != HMAP_NUM_VALS ) { go_BYE(-1); }

  for ( int i = 1; i <= num_vals; i++ ) { 
    lua_rawgeti(L, 5, i); 
    CMEM_REC_TYPE *ptr_val = luaL_checkudata(L, 5+1, "CMEM"); 
    // TODO Need to parallelize across num_keysnum_keys
    switch ( i )  {
      // START AUTO GENERATED CODE make_putn
      ${mk_putn}
      // STOP AUTO GENERATED CODE make_putn
    }
    lua_pop(L, 1);
    int n = lua_gettop(L); if ( n != (num_args  ) ) { go_BYE(-1); }
  }
  keytype *keys =  (keytype *)ptr_key->data;
  uint32_t *hshs =  (uint32_t *)ptr_agg->ptr_bufs->hshs;
  uint32_t *locs =  (uint32_t *)ptr_agg->ptr_bufs->locs;
  uint8_t  *tids =  (uint8_t  *)ptr_agg->ptr_bufs->tids;
  status = hmap_mk_hsh(keys, num_keys, ptr_agg->ptr_hmap->hashkey, hshs);
  status = hmap_mk_loc(hshs, num_keys, ptr_agg->ptr_hmap->size, locs);
  status = hmap_mk_tid(hshs, num_keys, num_threads, tids);
  status = hmap_putn(ptr_agg->ptr_hmap, keys,  hshs, locs, tids, 
    num_threads, ptr_agg->ptr_bufs->mvals, 
    num_keys, ptr_agg->ptr_bufs->fnds, &num_new, &num_probes);

  lua_pushboolean(L, true);
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
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  hmap_t *ptr_hmap = ptr_agg->ptr_hmap;
  SCLR_REC_TYPE *ptr_key = luaL_checkudata(L, 2, "Scalar"); 
  key = ptr_key->cdata.val${qkeytype}; 

  if ( !lua_istable(L, 3) ) { go_BYE(-1); }
  luaL_checktype(L, 3, LUA_TTABLE ); // another way of checking
  int num_vals = luaL_getn(L, 3);  /* get size of table */
  if ( num_vals != HMAP_NUM_VALS ) { go_BYE(-1); }

  for ( int i = 1; i <= num_vals; i++ ) { 
    lua_rawgeti(L, 2+1, i); 
    SCLR_REC_TYPE *ptr_val = luaL_checkudata(L, 3+1, "Scalar"); 
    switch ( i )  {
      // START GENERATED CODE make_put1
    ${mk_put1}
      // STOP  GENERATED CODE make_put1
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
      // START GENERATED CODE 
      ${create_scalars_for_return}
      // STOP  GENERATED CODE 
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
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  hmap_t *ptr_hmap = ptr_agg->ptr_hmap;
  SCLR_REC_TYPE *ptr_key = luaL_checkudata(L, 2, "Scalar"); 
  key = ptr_key->cdata.val${qkeytype}; 

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
      // START AUTO GENERATED CODE make_get1
      ${mk_get1}
      // STOP  AUTO GENERATED CODE make_get1
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
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  hmap_t *ptr_hmap = ptr_agg->ptr_hmap;
  SCLR_REC_TYPE *ptr_key = luaL_checkudata(L, 2, "Scalar"); 
  key = ptr_key->cdata.val${qkeytype}; 

  status = hmap_del(ptr_hmap, key, &is_found, &oldval, &num_probes);

  lua_pushboolean(L, is_found);
  if ( !is_found ) { return 1; }
  // return oldval as table of scalars
  lua_newtable(L);
  for ( int i = 1; i <= HMAP_NUM_VALS; i++ ) { 
    lua_pushnumber(L, i);
    SCLR_REC_TYPE *ptr_val_sclr = lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
    switch ( i )  {
      // START GENERATED CODE make_get1
      ${mk_get1}
      // START GENERATED CODE make_get1
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
static int l_agg_unbufferize( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  if ( ptr_agg == NULL ) { go_BYE(-1); }
  BUF_REC_TYPE *ptr_bufs = ptr_agg->ptr_bufs;
  if ( ptr_bufs == NULL ) { go_BYE(-1); }
  free_if_non_null(ptr_bufs->tids);
  free_if_non_null(ptr_bufs->fnds);
  free_if_non_null(ptr_bufs->locs);
  free_if_non_null(ptr_bufs->hshs);
  free_if_non_null(ptr_bufs->mvals);
  ptr_agg->ptr_bufs = NULL;
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_agg_free( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
  if ( ptr_agg == NULL ) { go_BYE(-1); }
  hmap_t *ptr_hmap = ptr_agg->ptr_hmap;
  BUF_REC_TYPE *ptr_bufs = ptr_agg->ptr_bufs;
  hmap_destroy(ptr_hmap); 
  if ( ptr_bufs != NULL ) { 
    free_if_non_null(ptr_bufs->tids);
    free_if_non_null(ptr_bufs->fnds);
    free_if_non_null(ptr_bufs->locs);
    free_if_non_null(ptr_bufs->hshs);
    free_if_non_null(ptr_bufs->mvals);
    free_if_non_null(ptr_bufs);
  }
  free_if_non_null(ptr_agg->ptr_metrics);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_agg_bufferize( lua_State *L) {
  int status = 0;
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  ptr_agg->ptr_bufs = calloc(1, sizeof(BUF_REC_TYPE));
  return_if_malloc_failed(ptr_agg->ptr_bufs);
  BUF_REC_TYPE *ptr_bufs = ptr_agg->ptr_bufs;

  uint32_t chunk_size = luaL_checknumber(L, 2);
  if ( chunk_size == 0 ) { go_BYE(-1); }
  if ( ptr_bufs->hshs  != NULL ) { go_BYE(-1); }
  if ( ptr_bufs->locs  != NULL ) { go_BYE(-1); }
  if ( ptr_bufs->tids  != NULL ) { go_BYE(-1); }
  if ( ptr_bufs->fnds  != NULL ) { go_BYE(-1); }
  if ( ptr_bufs->mvals != NULL ) { go_BYE(-1); }

  ptr_bufs->hshs = calloc(chunk_size, sizeof(uint32_t));
  return_if_malloc_failed(ptr_bufs->hshs);
  ptr_bufs->locs = calloc(chunk_size, sizeof(uint32_t));
  return_if_malloc_failed(ptr_bufs->locs);
  ptr_bufs->tids = calloc(chunk_size, sizeof(uint8_t));
  return_if_malloc_failed(ptr_bufs->tids);
  ptr_bufs->fnds = calloc(chunk_size, sizeof(uint8_t));
  return_if_malloc_failed(ptr_bufs->fnds);
  ptr_bufs->mvals = calloc(chunk_size, sizeof(val_t));
  return_if_malloc_failed(ptr_bufs->mvals);
  
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
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L,1,"Aggregator");
  hmap_t *ptr_hmap = ptr_agg->ptr_hmap;
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
  // TODO 
  AGG_REC_TYPE *ptr_agg = (AGG_REC_TYPE *)luaL_checkudata(L, 1, "Aggregator");
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
    { "bufferize",    l_agg_bufferize },
    { "check",        l_agg_check },
    { "del1",         l_agg_del1 },
    { "delete",       l_agg_free   },
    { "get1",         l_agg_get1 },
    { "getn",         l_agg_getn },
    { "instantiate",  l_agg_instantiate },
    { "meta",         l_agg_meta },
    { "put1",         l_agg_put1 },
    { "putn",         l_agg_putn },
    { "unbufferize",  l_agg_unbufferize },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg aggregator_functions[] = {
    { "new",          l_agg_new },
    { "bufferize",    l_agg_bufferize },
    { "check",        l_agg_check },
    { "del1",         l_agg_del1 },
    { "delete",       l_agg_free   },
    { "get1",         l_agg_get1 },
    { "getn",         l_agg_getn },
    { "instantiate",  l_agg_instantiate },
    { "meta",         l_agg_meta },
    { "put1",         l_agg_put1 },
    { "putn",         l_agg_putn },
    { "unbufferize",  l_agg_unbufferize },
    { NULL,  NULL         }
  };

  /*
  ** Open aggregator library
  */
  int luaopen_libagg${lbl} (lua_State *L) { 
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
]],
}
