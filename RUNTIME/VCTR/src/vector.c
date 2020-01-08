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

static int check_args_is_table(
    lua_State *L
    )
{
  int status =0;
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking
BYE:
  return status;
}

static int get_tbl_from_tbl(
      lua_State *L,
      const char * const key,
      bool *ptr_is_key,
      const char **file_names, // [n] 
      int n
      )
{
  int status = 0; 
  *ptr_is_key = false;
  int nstack = lua_gettop(L); 
  if ( nstack != 1 ) { go_BYE(-1); }
  lua_getfield (L, 1, key); 
  nstack = lua_gettop(L); 
  if ( nstack != (1+1) ) { go_BYE(-1); }
  if  ( lua_type(L, 1+1) != LUA_TTABLE ) { 
    *ptr_is_key = false; goto BYE;
  }
  int chk_n = luaL_getn(L, 1+1);
  if ( chk_n != n ) { go_BYE(-1); }
  for ( int i = 0; i < n; i++ ) { 
    lua_rawgeti(L, 1+1, i+1);
    nstack = lua_gettop(L);
    if ( nstack != 1+1+1 ) { go_BYE(-1); }
    file_names[i] = luaL_checkstring(L, 1+1+1);
    lua_pop(L, 1);
    nstack = lua_gettop(L);
    if ( nstack != 1+1 ) { go_BYE(-1); }
  }

  *ptr_is_key = true;
BYE:
  lua_pop(L, 1);
  n = lua_gettop(L); if ( n != 1  ) { go_BYE(-1); }
  return status;
}
static int get_str_from_tbl(
      lua_State *L,
      const char * const key,
      bool *ptr_is_key,
      const char **ptr_cptr
      )
{
  int status = 0; 
  *ptr_cptr = false;
  *ptr_is_key = false;
  int n = lua_gettop(L); if ( n != 1 ) { go_BYE(-1); }
  lua_getfield (L, 1, key); 
  n = lua_gettop(L); if ( n != (1+1) ) { go_BYE(-1); }
  if  ( lua_type(L, 1+1) != LUA_TSTRING ) { 
    *ptr_is_key = false; goto BYE;
  }
  *ptr_cptr = luaL_checkstring(L, 1+1); 
  *ptr_is_key = true;
BYE:
  lua_pop(L, 1);
  n = lua_gettop(L); if ( n != 1  ) { go_BYE(-1); }
  return status;
}
static int
get_int_from_tbl(
    lua_State *L, 
    const char * const key,
    bool *ptr_is_key,
    int64_t *ptr_itmp
    )
{
  int status = 0;
  *ptr_itmp = -1; *ptr_is_key = false;
  //------------------- get sz_chunk_dir
  lua_getfield (L, 1, key);
  int n = lua_gettop(L); if ( n != (1+1) ) { go_BYE(-1); }
  if  ( lua_type(L, 1+1) != LUA_TNUMBER ) { 
    *ptr_is_key = false; goto BYE;
  }
  *ptr_itmp = luaL_checknumber(L, 1+1); 
  *ptr_is_key = true;
BYE:
  lua_pop(L, 1);
  n = lua_gettop(L); if ( n != 1  ) { go_BYE(-1); }
  return status;
}
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
static int l_vec_chunk_size( lua_State *L) {
  lua_pushnumber(L, g_chunk_size);
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
  bool is_key; int64_t itmp;
  const char * cptr = NULL;
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
  status = check_args_is_table(L); cBYE(status);
  //-------------------------------
  status = get_int_from_tbl(L, "sz_chunk_dir", &is_key, &itmp); 
  cBYE(status);
  if ( !is_key )  {
    g_sz_chunk_dir = Q_INITIAL_SZ_CHUNK_DIR; // use default 
  }
  else {
    if ( itmp <= 8 ) { go_BYE(-1); }
    g_sz_chunk_dir = itmp;
  }
  //------------------- get chunk size 
  status = get_int_from_tbl(L, "chunk_size", &is_key, &itmp); 
  if (  ( !is_key) || ( itmp < 1024 ) ) { go_BYE(-1); }
  if ( ( ( itmp / 64 ) * 64 )  != itmp ) { go_BYE(-1); }
  g_chunk_size = itmp;
  //------------------- get q_data_dir
  status = get_str_from_tbl(L, "data_dir", &is_key, &cptr);  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( !isdir(cptr) ) { go_BYE(-1); }
  if ( strlen(cptr) > Q_MAX_LEN_DIR ) { go_BYE(-1); }
  strcpy(g_q_data_dir, cptr);
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
  // TODO P1 : Study the mempcy thingy
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
static int l_vec_same_state( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 3 ) { go_BYE(-1); }
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
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int32_t chunk_number = -1;
  int num_args = lua_gettop(L); 
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
  SCLR_REC_TYPE *ptr_sclr = NULL;
  CMEM_REC_TYPE *ptr_cmem = NULL;

  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t idx = luaL_checknumber(L, 2);
  char *data = NULL; int width = ptr_vec->field_width;

  status = vec_get1(ptr_vec, idx, &data); cBYE(status);

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
      ptr_sclr->cdata.valB1 = (word >> bit_idx) & 0x1;
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
  int64_t num_in_cmem;
  if ( num_args == 3 ) { 
    num_in_cmem = luaL_checknumber(L, 3);
  }
  else {
    num_in_cmem = g_chunk_size; 
  }
  if ( num_in_cmem < 0 ) { num_in_cmem = g_chunk_size; }
  status = vec_put_chunk(ptr_vec, addr, num_in_cmem); cBYE(status);
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
  bool is_key; int64_t itmp; 
  const char * qtype;
  uint32_t field_width;
  //------------------- get qtype
  status = check_args_is_table(L); cBYE(status);
  status = get_str_from_tbl(L, "qtype", &is_key, &qtype);  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( *qtype == '\0' ) { go_BYE(-1); }
  status = get_int_from_tbl(L, "width", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp < 1 ) { go_BYE(-1); }
  if ( strcmp(qtype, "QC") == 0 ) { 
    if ( itmp < 2 ) { go_BYE(-1); }
  }
  field_width = itmp;
  //------------------

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_new(ptr_vec, qtype, field_width);
  cBYE(status);

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}

static int l_vec_rehydrate( lua_State *L) 
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;
  bool is_key; int64_t itmp;  int num_chunks; bool is_single;
  const char * qtype = NULL;
  const char *file_name = NULL; 
  const char **file_names = NULL;  /* [num_chunks] */
  uint64_t num_elements;
  uint32_t field_width;
  //------------------- get qtype
  status = check_args_is_table(L); cBYE(status);
  status = get_str_from_tbl(L, "qtype", &is_key, &qtype);  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( *qtype == '\0' ) { go_BYE(-1); }
  //------------------
  status = get_int_from_tbl(L, "width", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp < 1 ) { go_BYE(-1); }
  if ( strcmp(qtype, "QC") == 0 ) { 
    if ( itmp < 2 ) { go_BYE(-1); }
  }
  field_width = itmp;
  //------------------
  status = get_int_from_tbl(L, "num_elements", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp <= 0 ) { go_BYE(-1); }
  num_elements = itmp;
  //------------------
  status = get_int_from_tbl(L, "chunk_size", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp != g_chunk_size ) { go_BYE(-1); }
  //------------------
  status = get_str_from_tbl(L, "file_name", &is_key, &file_name);  
  cBYE(status);
  if ( is_key ) { 
    is_single = true;
    if ( *file_name == '\0' ) { go_BYE(-1); }
  }
  else {
    num_chunks = ceil((double)num_elements / (double)g_chunk_size);
    if ( num_chunks == 1 ) { go_BYE(-1); }
    is_single = false;
    file_names = malloc(num_chunks * sizeof(char *));
    return_if_malloc_failed(file_names);
    memset(file_names, '\0',  (num_chunks * sizeof(char *)));
    status = get_tbl_from_tbl(L, "file_names", &is_key, file_names, 
        num_chunks);
    cBYE(status);
  }
  //------------------

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  if ( is_single ) { 
    status = vec_rehydrate_single(ptr_vec, qtype, field_width, 
      num_elements, file_name);
  }
  else {
    status = vec_rehydrate_multi(ptr_vec, qtype, field_width, 
      num_elements, num_chunks, file_names);
  }
  cBYE(status);
  free_if_non_null(file_names);
  return 1; 
BYE:
  free_if_non_null(file_names);
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
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
    { "chunk_size", l_vec_chunk_size }, 
    { "delete", l_vec_delete },
    { "delete_chunk_file", l_vec_delete_chunk_file },
    { "delete_master_file", l_vec_delete_master_file },
    { "end_read", l_vec_end_read },
    { "end_write", l_vec_end_write },
    { "eov", l_vec_eov },
    { "file_name", l_vec_file_name },
    { "flush_all", l_vec_flush_all },
    { "flush_chunk", l_vec_flush_chunk },
    { "free", l_vec_free },
    { "get1", l_vec_get1 },
    { "get_chunk", l_vec_get_chunk },
    { "init_globals", l_vec_init_globals },
    { "is_dead", l_vec_is_dead },
    { "is_eov", l_vec_is_eov },
    { "is_memo", l_vec_is_memo },
    { "me", l_vec_me },
    { "meta", l_vec_meta },
    { "memo", l_vec_memo },
    { "num_elements", l_vec_num_elements },
    { "persist", l_vec_persist },
    { "print_timers", l_vec_print_timers },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "no_memcpy", l_vec_no_memcpy },
    { "rehydrate", l_vec_rehydrate},
    { "reset_timers", l_vec_reset_timers },
    { "same_state", l_vec_same_state },
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
    { "check_chunks", l_vec_check_chunks }, 
    { "chunk_size", l_vec_chunk_size }, 
    { "delete", l_vec_delete },
    { "delete_chunk_file", l_vec_delete_chunk_file },
    { "delete_master_file", l_vec_delete_master_file },
    { "end_read", l_vec_end_read },
    { "end_write", l_vec_end_write },
    { "eov", l_vec_eov },
    { "file_name", l_vec_file_name },
    { "flush_all", l_vec_flush_all },
    { "flush_chunk", l_vec_flush_chunk },
    { "free", l_vec_free },
    { "get1", l_vec_get1 },
    { "get_chunk", l_vec_get_chunk },
    { "init_globals", l_vec_init_globals },
    { "is_dead", l_vec_is_dead },
    { "is_eov", l_vec_is_eov },
    { "is_memo", l_vec_is_memo },
    { "me", l_vec_me },
    { "memo", l_vec_memo },
    { "meta", l_vec_meta },
    { "new", l_vec_new },
    { "no_memcpy", l_vec_no_memcpy },
    { "num_elements", l_vec_num_elements },
    { "persist", l_vec_persist },
    { "print_timers", l_vec_print_timers },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "rehydrate", l_vec_rehydrate},
    { "reset_timers", l_vec_reset_timers },
    { "same_state", l_vec_same_state },
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
  return 1; // we are returning 1 thing to Lua -- a table of functions
}

