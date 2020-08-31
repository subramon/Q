#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "vec_macros.h"
#include "core_vec.h"
#include "aux_core_vec.h" 
#include "aux_qmem.h"
#include "sclr_struct.h"
#include "cmem_struct.h"
#include "qmem_struct.h"
#include "cmem.h"
#include "aux_lua_to_c.h"
#include "isdir.h"


  /*
  ** Implementation of luaL_testudata which will return NULL in case if udata is not of type tname
  ** TODO: Check for the appropriate location for this function
  */
LUALIB_API void *luaL_testudata (
    lua_State *L, 
    int ud, 
    const char *tname
    );
LUALIB_API void *luaL_testudata (
    lua_State *L, 
    int ud, 
    const char *tname
    ) 
{
  void *p = lua_touserdata(L, ud);
  if (p != NULL) {  /* value is a userdata? */
    if (lua_getmetatable(L, ud)) {  /* does it have a metatable? */
      lua_getfield(L, LUA_REGISTRYINDEX, tname);  // get correct metatable
      if (lua_rawequal(L, -1, -2)) {  /* does it have the correct mt? */
        lua_pop(L, 2);  /* remove both metatables */
        return p;
      }
    }
  }
  return NULL;  /* to avoid warnings */
}

int luaopen_libvctr (lua_State *L);
//-----------------------------------
// Called by Q.save() for checkpointing or shutdown of Q
static int l_vec_shutdown( lua_State *L) {
  int status = 0;
  char *X = NULL;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  status = vec_shutdown(g_S, ptr_vec, &X); cBYE(status);
  // If vector is to be persisted, 
  // returns a string that can be used to reincarnate X; else, NULL
  if ( X == NULL ) { 
    lua_pushnil(L);
  }
  else {
    lua_pushstring(L, X);
  }
  free_if_non_null(X); 
  return 1;
BYE:
  free_if_non_null(X); 
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------------------
static int l_vec_set_name( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  const char * const name  = luaL_checkstring(L, 2);
  status = vec_set_name(ptr_vec, name); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------------------
static int l_vec_same_state( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_v1 = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  VEC_REC_TYPE *ptr_v2 = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_same_state(ptr_v1, ptr_v2); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------------------
static int l_vec_file_name( lua_State *L) {
  int status = 0;
  char *file_name = NULL;

  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( ( num_args != 1 ) && ( num_args != 2 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  int32_t chunk_number = -1;
  if ( num_args == 1 ) { 
    // we want name of file for vector
  } 
  else if ( num_args == 2 ) { 
    // we want name of file for chunk
    chunk_number = luaL_checknumber(L, 2);
  }
  else {
    go_BYE(-1);
  }
  status = vec_file_name(g_S, ptr_vec, chunk_number, &file_name);
  cBYE(status);
  lua_pushstring(L, file_name);
  free_if_non_null(file_name);
  return 1;
BYE:
  free_if_non_null(file_name);
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_me( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------

  lua_pushlightuserdata(L, ptr_vec);
  // Now return table of CHUNK_REC_TYPE
  lua_newtable(L);
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    int chunk_dir_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *chunk = g_S->chunk_dir->chunks + chunk_dir_idx;
    lua_pushnumber(L, i+1);
    lua_pushlightuserdata(L, chunk);
    lua_settable(L, -3);
  }
  // return info in whole_vec_dir
  lua_newtable(L);
  WHOLE_VEC_REC_TYPE *whole_vec_rec = 
    g_S->whole_vec_dir->whole_vecs +ptr_vec->whole_vec_dir_idx;

  lua_pushstring(L,"is_file");
  lua_pushboolean(L, whole_vec_rec->is_file);
  lua_settable(L, -3);
  // TODO P3 Put other relevant stuff over here

  return 3;
  
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vec_nop( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( ptr_vec == NULL ) { goto BYE; }
  fprintf(stdout, "nop\n");
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_num_elements( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->num_elements);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_kill( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  status = vec_kill(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vec_is_killable( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_killable);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_is_eov( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_eov);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_is_dead( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_dead);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_is_memo( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_memo);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_memo( lua_State *L) {
  int status = 0;
  if ( lua_gettop(L) != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool is_memo = lua_toboolean(L, 2);
  status = vec_memo(ptr_vec, &(ptr_vec->is_memo), is_memo); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_killable( lua_State *L) {
  int status = 0;
  if ( (  lua_gettop(L) != 1 ) && ( lua_gettop(L) != 2 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_killable = false; // default value
  int num_args = lua_gettop(L);
  if ( num_args >= 2 )  {
    if ( lua_isboolean(L, 2) ) { 
      is_killable = lua_toboolean(L, 2);
    }
  }
  //------------------------------
  status = vec_killable(ptr_vec, is_killable); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_persist( lua_State *L) {
  int status = 0;
  if ( (  lua_gettop(L) != 1 ) && ( lua_gettop(L) != 2 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_persist = true; // default value
  int num_args = lua_gettop(L);
  if ( num_args >= 2 )  {
    if ( lua_isboolean(L, 2) ) { 
      is_persist = lua_toboolean(L, 2);
    }
  }
  //------------------------------
  status = vec_persist(ptr_vec, is_persist); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_eov( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_eov(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vec_get1( lua_State *L) {
  int status = 0;
  SCLR_REC_TYPE *ptr_sclr = NULL;
  CMEM_REC_TYPE *ptr_cmem = NULL;

  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  int64_t idx = luaL_checknumber(L, 2);
  //------------------
  void *data = NULL; int width = ptr_vec->field_width;

  status = vec_get1(g_S, ptr_vec, idx, &data); cBYE(status);

  if ( strcmp(ptr_vec->fldtype, "SC") == 0 ) { 
    // set up mechanics for return 
    ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
    return_if_malloc_failed(ptr_cmem);
    memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
    luaL_getmetatable(L, "CMEM");/* Add the metatable to the stack. */
    lua_setmetatable(L, -2);/* Set the metatable on the userdata. */
    //-- now set the value 
    strcpy(ptr_cmem->fldtype, ptr_vec->fldtype);
    ptr_cmem->data  = malloc(width);
    return_if_malloc_failed(ptr_cmem->data);
    memset(ptr_cmem->data, '\0',   width); 
    ptr_cmem->size  = width;
    ptr_cmem->width = width;
    memcpy(ptr_cmem->data, data, width-1);  // Note the -1
  }
  else { 
    // set up mechanics for return 
    ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
    return_if_malloc_failed(ptr_sclr);
    memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
    luaL_getmetatable(L, "Scalar");/* Add the metatable to the stack. */
    lua_setmetatable(L, -2);/* Set the metatable on the userdata. */
    // now set the value 

    strcpy(ptr_sclr->field_type, ptr_vec->fldtype);
    ptr_sclr->field_width = width;
    if ( strcmp(ptr_sclr->field_type, "B1") == 0 ) { 
      uint64_t word = ((uint64_t *)data)[0];
      uint32_t bit_idx = idx % 64;
      uint32_t bitval = (word >> bit_idx) & 0x1;
      if ( bitval == 0 ) { 
        ptr_sclr->cdata.valB1 = false;
      }
      else {
        ptr_sclr->cdata.valB1 = true;
      }
    }
    else {
      memcpy(&(ptr_sclr->cdata), data, width);
    }
  }
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//------------------------------------------
static int l_vec_start_read( lua_State *L) 
{
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = NULL;

  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  status = vec_start_read(g_S, ptr_vec, ptr_cmem); cBYE(status);
  lua_pushinteger(L, ptr_vec->num_elements);
  return 2;
BYE:
  lua_pushnil(L); 
  lua_pushstring(L, __func__);
  return 2;
}
//------------------------------------------
static int l_vec_unget_chunk( lua_State *L) 
{
  int status = 0;

  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  uint32_t chunk_num = luaL_checknumber(L, 2);
  //------------------
  status = vec_unget_chunk(g_S, ptr_vec, chunk_num); cBYE(status);
  lua_pushboolean(L, 1);
  return 1;
BYE:
  lua_pushnil(L); 
  lua_pushstring(L, __func__);
  return 2;
}
//------------------------------------------
static int l_vec_get_chunk( lua_State *L) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  int64_t chunk_num = -1;
  uint32_t num_in_chunk;

  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  chunk_num = luaL_checknumber(L, 2);
  //------------------
  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  status = vec_get_chunk(g_S, ptr_vec, chunk_num, ptr_cmem, 
      &num_in_chunk);
  cBYE(status);
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  lua_pushinteger(L, num_in_chunk);
  return 2;
BYE:
  lua_pushnil(L); 
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------------------
static int l_vec_put1( lua_State *L) {
  int status = 0;
  void *addr = NULL;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------

  if ( strcmp(ptr_vec->fldtype, "SC") == 0 ) { 
    CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 2, "CMEM");
    addr = ptr_cmem->data;
  }
  else {
    SCLR_REC_TYPE *ptr_sclr = luaL_checkudata(L, 2, "Scalar");
    if ( strcmp(ptr_vec->fldtype, ptr_sclr->field_type) != 0 ) { 
      go_BYE(-1);
    }
    addr = (void *)(&ptr_sclr->cdata);
  }
  status = vec_put1(g_S, ptr_vec, addr); cBYE(status);
  lua_pushinteger(L, status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_start_write( lua_State *L) {
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  status = vec_start_write(g_S, ptr_vec, ptr_cmem); cBYE(status);
  lua_pushinteger(L, ptr_vec->num_elements);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_end_read( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //--------------------------
  status = vec_end_read(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_end_write( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //--------------------------
  status = vec_end_write(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_put_chunk( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 3 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  if ( !luaL_testudata (L, 2, "CMEM") ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 2, "CMEM");
  //--------------------------------------
  if ( ptr_cmem == NULL ) { go_BYE(-1); }
  // Ideally should have == in comparison below
  // You (generator) need to give me (Vector) a buffer whose size 
  // is *at least* as the size of my chunk
  size_t chunk_size = g_S->chunk_size;
  size_t chunk_size_in_bytes = ptr_vec->field_width * chunk_size;
  if ( (size_t)ptr_cmem->size < chunk_size_in_bytes ) { go_BYE(-1); }
  int64_t num_in_cmem = luaL_checknumber(L, 3);
  if ( num_in_cmem <= 0 ) { 
    fprintf(stderr, "WARNING! Empty chunk being ignored\n");
  }
  else {
    status = vec_put_chunk((qmem_struct_t *)g_S, ptr_vec, ptr_cmem, 
        num_in_cmem); 
    cBYE(status);
    lua_pushboolean(L, true);
    return 1;
  }
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_meta( lua_State *L) {
  int status = 0;
  char *opbuf = NULL;

  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //----------------------------
  status = vec_meta(g_S, ptr_vec, &opbuf); cBYE(status);
  lua_pushstring(L, opbuf);
  free_if_non_null(opbuf);
  return 1;
BYE:
  free_if_non_null(opbuf);
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_check_qmem( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_c = luaL_checkudata(L, 1, "CMEM");
  qmem_struct_t * g_S  = (qmem_struct_t *)(ptr_c->data);
  //------------------
  status = vec_check_qmem(g_S); cBYE(status);
  lua_pushboolean(L, 1);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_check( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  status = vec_check(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, 1);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_free( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  status = vec_free(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//-----------------------
// Difference between delete and free is that in delete we destroy
// an underlying file if it exists
// free just 
// (1) frees   stuff that has been malloc'd and 
// (2) munmaps stuff that has been mmapped
static int l_vec_delete( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  status = vec_delete(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_un_load_chunks( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  bool is_hard = false;
  status = qmem_un_load_chunks(g_S,  ptr_vec, is_hard); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_un_load_chunk( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  int chunk_num = lua_tonumber(L, 2);
  //------------------
  bool is_hard = false;
  status = qmem_un_load_chunk(g_S,  ptr_vec, chunk_num, is_hard); 
  cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_un_backup_chunk( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  int chunk_num = lua_tonumber(L, 2);
  //------------------
  bool is_hard = false;
  status = qmem_un_backup_chunk(g_S,  ptr_vec, chunk_num, is_hard); 
  cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_un_backup_chunks( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  bool is_hard = false;
  status = qmem_un_backup_chunks(g_S,  ptr_vec, is_hard); 
  cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_un_backup_vec( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  bool is_hard = false;
  status = qmem_un_backup_vec(g_S, ptr_vec, is_hard); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_new( lua_State *L) 
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;
  bool is_key; int64_t itmp; 
  const char * qtype;
  uint32_t field_width;
  //--- get args passed from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking
  CMEM_REC_TYPE *ptr_c = luaL_checkudata(L, 2, "CMEM");
  qmem_struct_t * g_S  = (qmem_struct_t *)(ptr_c->data);
  //------------------- get qtype and width
  status = get_str_from_tbl(L, 1, "qtype", &is_key, &qtype);  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( *qtype == '\0' ) { go_BYE(-1); }
  //----------------
  status = get_int_from_tbl(L, 1, "width", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp < 1 ) { go_BYE(-1); }
  if ( strcmp(qtype, "SC") == 0 ) { 
    if ( itmp < 2 ) { go_BYE(-1); }
  }
  field_width = (uint32_t)itmp;
  //------------------

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_new(g_S, ptr_vec, qtype, field_width, 0, 0); cBYE(status);
  ptr_vec->g_S = g_S; // needed for __gc

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}

static int l_vec_reincarnate( lua_State *L) 
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;
  bool is_key; int64_t itmp;  int num_chunks; 
  const char * qtype = NULL;
  int64_t vec_uqid;
  int64_t *chunk_uqids = NULL;
  uint64_t num_elements;
  uint32_t field_width;
  //--- get args passed from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking
  CMEM_REC_TYPE *ptr_c = luaL_checkudata(L, 2, "CMEM");
  qmem_struct_t * g_S  = (qmem_struct_t *)(ptr_c->data);
  //------------------- get qtype
  status = get_str_from_tbl(L, 1, "qtype", &is_key, &qtype);  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( *qtype == '\0' ) { go_BYE(-1); }
  //------------------
  status = get_int_from_tbl(L, 1, "width", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp < 1 ) { go_BYE(-1); }
  if ( strcmp(qtype, "QC") == 0 ) { 
    if ( itmp < 2 ) { go_BYE(-1); }
  }
  field_width = itmp;
  //------------------
  status = get_int_from_tbl(L, 1, "num_elements", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp <= 0 ) { go_BYE(-1); }
  num_elements = itmp;
  //------------------
  status = get_int_from_tbl(L, 1, "chunk_size", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( (uint64_t)itmp != g_S->chunk_size ) { go_BYE(-1); }
  //------------------
  status = get_int_from_tbl(L, 1, "vec_uqid", &is_key, &vec_uqid);  
  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  //------------------
  num_chunks = ceil((double)num_elements / (double)g_S->chunk_size);
  chunk_uqids = malloc(num_chunks * sizeof(uint64_t));
  return_if_malloc_failed(chunk_uqids);
  memset(chunk_uqids, 0,  num_chunks * sizeof(uint64_t));
  status = get_array_of_ints_from_tbl(L, 1, "chunk_uqids", &is_key, 
        chunk_uqids, num_chunks);
  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  //------------------
  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_reincarnate(g_S, ptr_vec, qtype, field_width, 
      num_elements, vec_uqid, chunk_uqids, num_chunks);
  cBYE(status);
  free_if_non_null(chunk_uqids);
  return 1; 
BYE:
  free_if_non_null(chunk_uqids);
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_load_chunks( lua_State *L) 
{
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //--------------------
  status = qmem_load_chunks(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_load_chunk( lua_State *L) 
{
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  int chunk_idx = lua_tonumber(L, 2); 
  //--------------------
  status = qmem_load_chunk(g_S, ptr_vec, chunk_idx); cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_backup_chunk( lua_State *L) 
{
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  int chunk_idx = lua_tonumber(L, 2); 
  //-------------------------
  status = qmem_backup_chunk(g_S, ptr_vec, chunk_idx); cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_backup_chunks( lua_State *L) 
{
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  status = qmem_backup_chunks(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_backup_vec( lua_State *L) 
{
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qmem_struct_t * g_S   = ptr_vec->g_S;
  //------------------
  status = qmem_backup_vec(g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
static const struct luaL_Reg vector_methods[] = {
    { "__gc",    l_vec_free   },
    { "check", l_vec_check },

    { "un_backup_chunk", l_vec_un_backup_chunk },
    { "un_backup_chunks", l_vec_un_backup_chunks },

    { "backup_chunk", l_vec_backup_chunk },
    { "backup_chunks", l_vec_backup_chunks },

    { "un_load_chunk", l_vec_un_load_chunk },
    { "un_load_chunks", l_vec_un_load_chunks },

    { "load_chunk", l_vec_load_chunk },
    { "load_chunks", l_vec_load_chunks },

    { "backup_vec", l_vec_backup_vec },
    { "un_backup_vec", l_vec_un_backup_vec }, 
    //---------------------------------------------------
    { "eov", l_vec_eov },
    { "file_name", l_vec_file_name },
    { "free", l_vec_free },
    { "kill", l_vec_kill},
    { "delete", l_vec_delete },
    //--------------------------------
    { "is_dead", l_vec_is_dead },
    { "is_eov", l_vec_is_eov },
    { "is_killable", l_vec_is_killable },
    { "is_memo", l_vec_is_memo },
    { "num_elements", l_vec_num_elements },
    { "nop", l_vec_nop },
    //--------------------------------
    { "killable", l_vec_killable },
    { "memo", l_vec_memo },
    { "persist", l_vec_persist },
    { "set_name", l_vec_set_name },
    //--------------------------------
    { "me", l_vec_me },
    { "meta", l_vec_meta },
    //--------------------------------
    { "new", l_vec_new },
    { "reincarnate", l_vec_reincarnate},
    { "same_state", l_vec_same_state },
    { "shutdown", l_vec_shutdown },
    //--------------------------------
    { "start_read", l_vec_start_read },
    { "end_read", l_vec_end_read },
    { "start_write", l_vec_start_write },
    { "end_write", l_vec_end_write },
    //--------------------------------
    { "get1", l_vec_get1 },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "get_chunk", l_vec_get_chunk },
    { "unget_chunk", l_vec_unget_chunk },
    //--------------------------------
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "check", l_vec_check },
    { "check_qmem", l_vec_check_qmem },

    { "un_backup_chunk", l_vec_un_backup_chunk },
    { "backup_chunk", l_vec_backup_chunk },
    { "backup_chunks", l_vec_backup_chunks },

    { "un_load_chunk", l_vec_un_load_chunk },
    { "load_chunk", l_vec_load_chunk },
    { "load_chunks", l_vec_load_chunks },

    { "backup_vec", l_vec_backup_vec },
    { "un_backup_vec", l_vec_un_backup_vec }, 
    //---------------------------------------------------
    { "eov", l_vec_eov },
    { "file_name", l_vec_file_name },
    { "free", l_vec_free },
    { "kill", l_vec_kill},
    { "delete", l_vec_delete },
    //--------------------------------
    { "is_dead", l_vec_is_dead },
    { "is_eov", l_vec_is_eov },
    { "is_killable", l_vec_is_killable },
    { "is_memo", l_vec_is_memo },
    { "num_elements", l_vec_num_elements },
    { "nop", l_vec_nop },
    //--------------------------------
    { "killable", l_vec_killable },
    { "memo", l_vec_memo },
    { "persist", l_vec_persist },
    { "set_name", l_vec_set_name },
    //--------------------------------
    { "me", l_vec_me },
    { "meta", l_vec_meta },
    //--------------------------------
    { "new", l_vec_new },
    { "reincarnate", l_vec_reincarnate},
    { "same_state", l_vec_same_state },
    { "shutdown", l_vec_shutdown },
    //--------------------------------
    { "start_read", l_vec_start_read },
    { "end_read", l_vec_end_read },
    { "start_write", l_vec_start_write },
    { "end_write", l_vec_end_write },
    //--------------------------------
    { "get1", l_vec_get1 },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "get_chunk", l_vec_get_chunk },
    { "unget_chunk", l_vec_unget_chunk },
    //--------------------------------

    { NULL,  NULL         }
  };
/*
** Open vector library
*/
int luaopen_libvctr (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "Vector");
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
  luaL_register(L, NULL, vector_methods);

  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/register_type'");
  if ( status != 0 ) {
    WHEREAMI;
    fprintf(stderr, "Running require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  } 
  luaL_getmetatable(L, "Vector");
  lua_pushstring(L, "Vector");
  status =  lua_pcall(L, 2, 0, 0);
  if (status != 0 ) {
    WHEREAMI; 
    fprintf(stderr, "Type Registering failed: %s\n", lua_tostring(L, -1));
    exit(1);
  }

  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, vector_functions);
  return 1; // we are returning 1 thing to Lua -- a table of functions
}

