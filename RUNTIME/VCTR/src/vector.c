#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "core_vec.h"
#include "scalar_struct.h"
#include "cmem_struct.h"
#include "cmem.h"
#include "aux_core_vec.h"

#include "txt_to_I4.h"
#include "isdir.h"
#define MAIN_PGM
#include "vec_globals.h"
#undef MAIN_PGM

// Set globals in C in main program after creating Lua state
// but before doing anything else
// chunk_size, memory structures, ...

LUALIB_API void *luaL_testudata (lua_State *L, int ud, const char *tname);
int luaopen_libvctr (lua_State *L);
//----------------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_reset_timers( lua_State *L) {
  g_reset_timers();
  lua_pushboolean(L, true);
  return 1;
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_print_timers( lua_State *L) {
  g_print_timers();
  lua_pushboolean(L, true);
  return 1;
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_check_chunks( lua_State *L) {
  g_check_chunks(g_chunk_dir, g_sz_chunk_dir, g_n_chunk_dir);
  lua_pushboolean(L, true);
  return 1;
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_init_globals( lua_State *L) {
  int status = 0;
  int n, num_args;
  //-------------------------------
  static bool called = false;
  if ( called ) { 
    fprintf(stderr, "ERROR: init_globals cannot be called twice \n");
    go_BYE(-1);
  }
  else {
    called = true;
  }
  if ( ( g_chunk_dir != NULL ) || ( g_q_data_dir[0] != '\0' ) ||
       ( g_chunk_size > 0 ) ) {
    fprintf(stderr, "ERROR: globals have been initialized already\n");
    go_BYE(-1); 
  }
  //-------------------------------
  num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking

  //------------------- get sz_chunk_dir
  lua_getfield (L, 1, "sz_chunk_dir");
  n = lua_gettop(L); if ( n != (1+1) ) { go_BYE(-1); }
  if  ( lua_type(L, 1+1) != LUA_TNUMBER ) { 
    g_sz_chunk_dir = Q_INITIAL_SZ_CHUNK_DIR; // use default 
  }
  else {
    int new_sz_chunk_dir = luaL_checknumber(L, 1+1); 
    if ( new_sz_chunk_dir <= 8 ) { go_BYE(-1); }
    g_sz_chunk_dir = new_sz_chunk_dir;
  }
  lua_pop(L, 1);
  n = lua_gettop(L); if ( n != 1  ) { go_BYE(-1); }
  //------------------- get chunk size 
  lua_getfield (L, 1, "chunk_size");
  n = lua_gettop(L); if ( n != (1+1) ) { go_BYE(-1); }
  if  ( lua_type(L, 1+1) != LUA_TNUMBER ) { go_BYE(-1); }
  int new_chunk_size = luaL_checknumber(L, 1+1); 
  if ( new_chunk_size <= 1024 ) { go_BYE(-1); }
  g_chunk_size = new_chunk_size;
  lua_pop(L, 1);
  n = lua_gettop(L); if ( n != 1  ) { go_BYE(-1); }
  //------------------- get q_data_dir
  lua_getfield (L, 1, "data_dir");
  n = lua_gettop(L); if ( n != (1+1) ) { go_BYE(-1); }
  if  ( lua_type(L, 1+1) != LUA_TSTRING ) { go_BYE(-1); }
  const char * const cptr = luaL_checkstring(L, 1+1); 
  if ( !isdir(cptr) ) { go_BYE(-1); }
  if ( strlen(cptr) > Q_MAX_LEN_DIR ) { go_BYE(-1); }
  strcpy(g_q_data_dir, cptr);
  lua_pop(L, 1);
  n = lua_gettop(L); if ( n != 1  ) { go_BYE(-1); }
  //-------------------
  status = init_globals(); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------------------
static int l_vec_no_memcpy( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE  *ptr_vec  = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  // TODO: Study the mempcy thingy
  status = vec_no_memcpy(ptr_vec, ptr_cmem, g_chunk_size); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------------------
static int l_vec_shutdown( lua_State *L) {
  int status = 0;
  char *X = NULL;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_shutdown(ptr_vec, &X); 
  if ( status < 0 ) { free_if_non_null(X); } cBYE(status);
  lua_pushstring(L, X);
  free_if_non_null(X); 
  return 1;
BYE:
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
static int l_vec_get_name( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushstring(L, ptr_vec->name);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_num_chunks( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->num_chunks);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_chunk_size_in_bytes( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->chunk_size_in_bytes);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_fldtype( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushstring(L, ptr_vec->fldtype);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_field_width( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->field_width);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_file_size( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->file_size);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_file_name( lua_State *L) {
  int status = 0;
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int32_t chunk_number = -1;
  int num_args = lua_gettop(L); 
  if ( num_args == 1 ) { // we want name of file for vector
  } 
  else if ( num_args == 2 ) { // we want name of file for chunk
    chunk_number = luaL_checknumber(L, 2);
  }
  else {
    go_BYE(-1);
  }
  status = vec_file_name(ptr_vec, chunk_number, file_name, Q_MAX_LEN_FILE_NAME); 
  cBYE(status);
  lua_pushstring(L, file_name);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_me( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushlightuserdata(L, ptr_vec);
  // Now return table of CHUNK_REC_TYPE
  lua_newtable(L);
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    int chunk_dir_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
    lua_pushnumber(L, i+1);
    lua_pushlightuserdata(L, ptr_chunk);
    lua_settable(L, -3);
  }
  return 2;
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
  if ( (  lua_gettop(L) != 1 ) && ( lua_gettop(L) != 2 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_memo = true;
  if ( lua_isboolean(L, 2) ) { 
    is_memo = lua_toboolean(L, 2);
  }
  //------------------------------
  status = vec_memo(ptr_vec, &(ptr_vec->is_memo), is_memo); cBYE(status);
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
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  char *data = NULL;
  SCLR_REC_TYPE *ptr_sclr = NULL;

  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t idx = luaL_checknumber(L, 2);

  status = vec_get1(ptr_vec, idx, &data); cBYE(status);

  ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  return_if_malloc_failed(ptr_sclr);
  memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
  luaL_getmetatable(L, "Scalar");/* Add the metatable to the stack. */
  lua_setmetatable(L, -2);/* Set the metatable on the userdata. */
    // printf("sclr new to %x \n", ptr_sclr);

  strcpy(ptr_sclr->field_type, ptr_vec->fldtype);
  ptr_sclr->field_width = ptr_vec->field_width;
  if ( strcmp(ptr_sclr->field_type, "B1") == 0 ) { 
    uint64_t word = ((uint64_t *)data)[0];
    uint32_t bit_idx = idx % 64;
    ptr_sclr->cdata.valB1 = (word >> bit_idx) & 0x1;
  }
  else {
    memcpy(&(ptr_sclr->cdata), data, ptr_vec->field_width);
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
  uint64_t num_elements;
  char *data = NULL;

  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  cmem_undef(ptr_cmem);

  status = vec_start_read(ptr_vec, &data, &num_elements, ptr_cmem); 
  cBYE(status);
  lua_pushinteger(L, num_elements);
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

  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t chunk_num = luaL_checknumber(L, 2);

  status = vec_unget_chunk(ptr_vec, chunk_num); cBYE(status);
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

  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  chunk_num = luaL_checknumber(L, 2);

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  cmem_undef(ptr_cmem);

  status = vec_get_chunk(ptr_vec, chunk_num, ptr_cmem, &num_in_chunk);
  cBYE(status);
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
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
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
  status = vec_put1(ptr_vec, addr); cBYE(status);
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
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  status = vec_start_write(ptr_vec, ptr_cmem); cBYE(status);
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
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_end_read(ptr_vec); cBYE(status);
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
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_end_write(ptr_vec); cBYE(status);
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
  void *addr = NULL;
  int num_args = lua_gettop(L);
  if ( ( num_args != 2 ) && ( num_args != 3 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( !luaL_testudata (L, 2, "CMEM") ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 2, "CMEM");
  if ( ptr_cmem == NULL ) { go_BYE(-1); }
  addr = ptr_cmem->data;
  uint32_t num_in_chunk = 0;
  if ( num_args == 3 ) {
    num_in_chunk = luaL_checknumber(L, 3);
  }
  status = vec_put_chunk(ptr_vec, addr, num_in_chunk, ptr_cmem->size);
  cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_meta( lua_State *L) {
  char opbuf[4096]; // TODO P3 try not to hard code bound
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  memset(opbuf, '\0', 4096);
  int status = vec_meta(ptr_vec, opbuf);
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
static int l_vec_backup( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_backup(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_check( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_check(ptr_vec);
  if ( status == 0) { 
    lua_pushboolean(L, 1);
    return 1;
  }
  else {
    lua_pushnil(L);
    lua_pushstring(L, __func__);
    return 2;
  }
}
//----------------------------------------
static int l_vec_free( lua_State *L) {
  // printf("l_vec_free: Freeing vector\n");
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_free(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
// Difference between delete and free is that in delete we destroy
// an underlying file if it exists
// free just 
// (1) frees   stuff that has been malloc'd and 
// (2) munmaps stuff that has been mmapped
static int l_vec_delete( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_delete(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_delete_chunk_file( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int num_args = lua_gettop(L);
  int chunk_num = -1; // default is to delete for all chunks
  if ( num_args == 2 ) { 
    chunk_num = lua_tonumber(L, 2);
  }
  int status = vec_delete_chunk_file(ptr_vec, chunk_num); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
//----------------------------------------
static int l_vec_delete_master_file( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_delete_master_file(ptr_vec); cBYE(status);
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

  const char * const field_type = luaL_checkstring(L, 1);
  uint32_t field_width          = lua_tonumber(L, 2);

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_new(ptr_vec, field_type, field_width);
  cBYE(status);

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_rehydrate_single( lua_State *L) 
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;
  const char * const field_type = luaL_checkstring(L, 1);
  uint32_t field_width          = lua_tonumber(L, 2);
  int64_t num_elements          = lua_tonumber(L, 3);
  const char * const file_name  = luaL_checkstring(L, 4);

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_rehydrate_single(ptr_vec, field_type, field_width, 
      num_elements, file_name);
  cBYE(status);

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_rehydrate_multi( lua_State *L) 
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;
  const char * const field_type = luaL_checkstring(L, 1);
  uint32_t field_width          = lua_tonumber(L, 2);
  int64_t num_elements          = lua_tonumber(L, 3);
  const char * const file_name  = luaL_checkstring(L, 4);
  // TODO P1

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  go_BYE(-1);

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_flush_chunk( lua_State *L) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( ( num_args < 1 ) || ( num_args > 3 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int chunk_idx  = -1;
  bool free_mem = false; // default 
  if ( num_args >= 2 ) {
    chunk_idx = lua_tonumber(L, 2); 
  }
  if ( num_args >= 3 ) {
    free_mem = lua_toboolean(L, 3); 
  }
  status = vec_flush_chunk(ptr_vec, free_mem, chunk_idx); cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_flush_all( lua_State *L) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( num_args < 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_flush_all(ptr_vec); cBYE(status);
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
    { "backup", l_vec_backup },
    { "check", l_vec_check },
    { "check_chunks", l_vec_check_chunks }, 
    { "chunk_size_in_bytes", l_vec_chunk_size_in_bytes },
    { "delete", l_vec_delete },
    { "delete_chunk_file", l_vec_delete_chunk_file },
    { "delete_master_file", l_vec_delete_master_file },
    { "eov", l_vec_eov },
    { "end_read", l_vec_end_read },
    { "end_write", l_vec_end_write },
    { "field_width", l_vec_field_width },
    { "file_name", l_vec_file_name },
    { "file_size", l_vec_file_size },
    { "fldtype", l_vec_fldtype },
    { "flush_all", l_vec_flush_all },
    { "flush_chunk", l_vec_flush_chunk },
    { "get1", l_vec_get1 },
    { "get_chunk", l_vec_get_chunk },
    { "get_name", l_vec_get_name },
    { "init_globals", l_vec_init_globals },
    { "is_eov", l_vec_is_eov },
    { "is_memo", l_vec_is_memo },
    { "me", l_vec_me },
    { "meta", l_vec_meta },
    { "memo", l_vec_memo },
    { "num_elements", l_vec_num_elements },
    { "num_chunks", l_vec_num_chunks },
    { "persist", l_vec_persist },
    { "print_timers", l_vec_print_timers },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "no_memcpy", l_vec_no_memcpy },
    { "rehydrate_multi", l_vec_rehydrate_multi },
    { "rehydrate_single", l_vec_rehydrate_single },
    { "reset_timers", l_vec_reset_timers },
    { "set_name", l_vec_set_name },
    { "shutdown", l_vec_shutdown },
    { "start_read", l_vec_start_read },
    { "start_write", l_vec_start_write },
    { "unget_chunk", l_vec_unget_chunk },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "backup", l_vec_backup },
    { "check", l_vec_check },
    { "chunk_size_in_bytes", l_vec_chunk_size_in_bytes },
    { "delete", l_vec_delete },
    { "delete_chunk_file", l_vec_delete_chunk_file },
    { "delete_master_file", l_vec_delete_master_file },
    { "end_read", l_vec_end_read },
    { "end_write", l_vec_end_write },
    { "eov", l_vec_eov },
    { "field_width", l_vec_field_width },
    { "file_name", l_vec_file_name },
    { "file_size", l_vec_file_size },
    { "fldtype", l_vec_fldtype },
    { "flush_all", l_vec_flush_all },
    { "flush_chunk", l_vec_flush_chunk },
    { "get1", l_vec_get1 },
    { "get_chunk", l_vec_get_chunk },
    { "get_name", l_vec_get_name },
    { "init_globals", l_vec_init_globals },
    { "is_eov", l_vec_is_eov },
    { "is_memo", l_vec_is_memo },
    { "me", l_vec_me },
    { "memo", l_vec_memo },
    { "meta", l_vec_meta },
    { "new", l_vec_new },
    { "no_memcpy", l_vec_no_memcpy },
    { "num_elements", l_vec_num_elements },
    { "num_chunks", l_vec_num_chunks },
    { "persist", l_vec_persist },
    { "print_timers", l_vec_print_timers },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "rehydrate_multi", l_vec_rehydrate_multi },
    { "rehydrate_single", l_vec_rehydrate_single },
    { "reset_timers", l_vec_reset_timers },
    { "set_name", l_vec_set_name },
    { "shutdown", l_vec_shutdown },
    { "start_read", l_vec_start_read },
    { "start_write", l_vec_start_write },
    { "unget_chunk", l_vec_unget_chunk },
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

  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
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
  // Why is return code not 0
  return 1;
}
