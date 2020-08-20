#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "vec_macros.h"
#include "core_vec.h"
#include "aux_core_vec.h"
#include "scalar_struct.h"
#include "cmem_struct.h"
#include "cmem.h"
#include "aux_lua_to_c.h"

#include "txt_to_I4.h"
#include "isdir.h"


VEC_GLOBALS_TYPE g_S;

// Set globals in C in main program after creating Lua state
// but before doing anything else
// chunk_size, memory structures, ...

LUALIB_API void *luaL_testudata (lua_State *L, int ud, const char *tname);
int luaopen_libvctr (lua_State *L);


static int
set_default_values(
    VEC_GLOBALS_TYPE *ptr_g_S
    )
{
  int status = 0;
  ptr_g_S->sz_chunk_dir = Q_INITIAL_SZ_CHUNK_DIR; 
  ptr_g_S->chunk_size   = Q_DEFAULT_CHUNK_SIZE;
  //----------------------------------
  char *cptr = getenv("Q_DATA_DIR");
  if ( ( cptr == NULL ) || ( *cptr == '\0' ) ) { go_BYE(-1); }
  if ( !isdir(cptr) ) { go_BYE(1); }
  free_if_non_null(ptr_g_S->q_data_dir); 
  ptr_g_S->q_data_dir = malloc(strlen(cptr)+1); 
  return_if_malloc_failed(ptr_g_S->q_data_dir);
  strcpy(ptr_g_S->q_data_dir, cptr);
  //----------------------------------
BYE:
  return status;
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_check_chunks( lua_State *L) {
  int status = check_chunks(&g_S); 
  if ( status != 0 ) {
    WHEREAMI;
    lua_pushnil(L);
    lua_pushstring(L, __func__);
    return 2;
  }
  else {
    lua_pushboolean(L, true);
    return 1;
  }
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_init_globals( lua_State *L) {
  int status = 0;
  FILE *fp = NULL;
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
  if ( ( g_S.chunk_dir != NULL ) || ( g_S.q_data_dir != NULL ) ||
       ( g_S.chunk_size > 0 ) ) {
    // fprintf(stderr, "ERROR: globals have been initialized already\n");
    // go_BYE(-1); 
    status = -1; goto BYE;
  }
  status = check_args_is_table(L); cBYE(status);
  //-------------------------------
  status = get_int_from_tbl(L, "sz_chunk_dir", &is_key, &itmp); 
  cBYE(status);
  if ( !is_key )  {
    g_S.sz_chunk_dir = Q_INITIAL_SZ_CHUNK_DIR; // use default 
  }
  else {
    if ( itmp <= 8 ) { go_BYE(-1); }
    g_S.sz_chunk_dir = itmp;
  }
  //------------------- get chunk size 
  status = get_int_from_tbl(L, "chunk_size", &is_key, &itmp); 
  if ( !is_key ) { 
    int chunk_size = 0;
    char *str_chunk_size = getenv("Q_CHUNK_SIZE");
    if ( str_chunk_size == NULL ) { 
      chunk_size = Q_DEFAULT_CHUNK_SIZE;
    }
    else {
      chunk_size = atoi(str_chunk_size);
    }
    if ( chunk_size < 64 ) { go_BYE(-1); }
    if ( ( ( chunk_size / 64 ) * 64 )   != chunk_size )  { go_BYE(-1); }
    g_S.chunk_size = chunk_size;
  }
  else {
    if ( itmp < 1024 ) { go_BYE(-1); }
    // must be a multiple of 1024
    if ( ( ( itmp / 64 ) * 64 )  != itmp ) { go_BYE(-1); }
    g_S.chunk_size = itmp;
  }
  //------------------- get q_data_dir
  status = get_str_from_tbl(L, "data_dir", &is_key, &cptr);  cBYE(status);
  if ( !is_key ) {  // get from environment variable
    cptr = getenv("Q_DATA_DIR");
    if ( ( cptr == NULL ) || ( *cptr == '\0' ) ) { go_BYE(-1); }
  }
  if ( !isdir(cptr) ) { go_BYE(-1); }
  g_S.q_data_dir = malloc(strlen(cptr)+1); 
  return_if_malloc_failed(g_S.q_data_dir);
  strcpy(g_S.q_data_dir, cptr);
  //-------------------
  g_S.max_file_num = 0;
  //-------------------
  status = init_globals(&g_S); cBYE(status);
  fclose_if_non_null(fp);
  lua_pushboolean(L, true);
  return 1;
BYE:
  fclose_if_non_null(fp);
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_set_globals( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  const char *key = luaL_checkstring(L, 1); 
  const char *val = luaL_checkstring(L, 2); 
  if ( strcmp(key, "max_file_num") == 0 ) { 
    int itmp = atoi(val);
    if ( itmp < 0 ) { go_BYE(-1); }
    g_S.max_file_num = itmp;
  }
  else {
    go_BYE(-1);
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//------------------------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_get_globals( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  const char *key = luaL_checkstring(L, 1); 
  if ( strcmp(key, "max_file_num") == 0 ) { 
    lua_pushnumber(L, g_S.max_file_num);
  }
  else if ( strcmp(key, "data_dir") == 0 ) { 
    lua_pushstring(L, g_S.q_data_dir);
  }
  else {
    go_BYE(-1);
  }
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//------------------------------------------------
static int l_vec_free_globals( lua_State *L) {
  free_if_non_null(g_S.chunk_dir);
  free_if_non_null(g_S.q_data_dir);
  lua_pushboolean(L, true);
  return 1;
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_chunk_size( lua_State *L) {
  int status = 0; 
  if ( g_S.chunk_size == 0 ) {  
    // printf("Setting default values \n");
    status = set_default_values(&g_S); cBYE(status);
  }
  lua_pushnumber(L, g_S.chunk_size);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//-----------------------------------
// TODO P3 Should not be part of vector code, this deals with globals
static int l_vec_data_dir( lua_State *L) {
  int status = 0;
  if ( ( g_S.q_data_dir == NULL ) || ( g_S.q_data_dir[0] == '\0' ) ) {  
    status = set_default_values(&g_S); cBYE(status);
  }
  if ( !isdir(g_S.q_data_dir) ) { go_BYE(-1); }
  lua_pushstring(L, g_S.q_data_dir);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------------------
static int l_vec_reincarnate( lua_State *L) {
  int status = 0;
  bool is_clone = true;
  char *X = NULL;
  int nargs = lua_gettop(L);
  if ( nargs != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  // check status of vector 
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->num_writers > 0 ) { go_BYE(-1); }
  if ( !ptr_vec->is_eov ) { go_BYE(-1); }
  //--------------
  status = reincarnate(&g_S, ptr_vec, &X, is_clone);
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
static int l_vec_shutdown( lua_State *L) {
  int status = 0;
  char *X = NULL;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_shutdown(&g_S, ptr_vec, &X); 
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
  status = vec_file_name(&g_S, ptr_vec, chunk_number, file_name, 
      Q_MAX_LEN_FILE_NAME); 
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
    CHUNK_REC_TYPE *ptr_chunk = g_S.chunk_dir + chunk_dir_idx;
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
static int l_vec_kill( lua_State *L) {
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_kill(&g_S, ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
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
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  SCLR_REC_TYPE *ptr_sclr = NULL;
  CMEM_REC_TYPE *ptr_cmem = NULL;

  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t idx = luaL_checknumber(L, 2);
  void *data = NULL; int width = ptr_vec->field_width;

  status = vec_get1(&g_S, ptr_vec, idx, &data); cBYE(status);

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

  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  cmem_undef(ptr_cmem);

  status = vec_start_read(&g_S, ptr_vec, ptr_cmem); cBYE(status);
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

  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t chunk_num = luaL_checknumber(L, 2);

  status = vec_unget_chunk(&g_S, ptr_vec, chunk_num); cBYE(status);
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

  status = vec_get_chunk(&g_S, ptr_vec, chunk_num, ptr_cmem, 
      &num_in_chunk);
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
  status = vec_put1(&g_S, ptr_vec, addr); cBYE(status);
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
  status = vec_start_write(&g_S, ptr_vec, ptr_cmem); cBYE(status);
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
  int num_args = lua_gettop(L);
  if ( num_args != 3 ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( !luaL_testudata (L, 2, "CMEM") ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 2, "CMEM");
  if ( ptr_cmem == NULL ) { go_BYE(-1); }
  // Ideally should have == in comparison below
  // You (generator) need to give me (Vector) a buffer whose size 
  // is *at least* as the size of my chunk
  if ( ptr_cmem->size < ptr_vec->chunk_size_in_bytes ) { 
    go_BYE(-1); 
  }
  int64_t num_in_cmem = luaL_checknumber(L, 3);
  if ( num_in_cmem <= 0 ) { go_BYE(-1); }
  status = vec_put_chunk(&g_S, ptr_vec, ptr_cmem, num_in_cmem); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_meta( lua_State *L) {
  char opbuf[4096]; // TODO P4 try not to hard code bound
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
static int l_vec_check( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_check(&g_S, ptr_vec);
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
  int status = vec_free(&g_S, ptr_vec); cBYE(status);
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
  int status = vec_delete(&g_S, ptr_vec); cBYE(status);
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
  int status = vec_delete_chunk_file(&g_S,  ptr_vec, chunk_num); 
  cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vec_unmaster( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_unmaster(&g_S, ptr_vec); cBYE(status);
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
  //------------------- get qtype and width
  status = check_args_is_table(L); cBYE(status);
  status = get_str_from_tbl(L, "qtype", &is_key, &qtype);  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( *qtype == '\0' ) { go_BYE(-1); }
  //----------------
  status = get_int_from_tbl(L, "width", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp < 1 ) { go_BYE(-1); }
  if ( strcmp(qtype, "SC") == 0 ) { 
    if ( itmp < 2 ) { go_BYE(-1); }
  }
  field_width = itmp;
  //------------------

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_new(&g_S, ptr_vec, qtype, field_width);
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
  bool is_key; int64_t itmp;  int num_chunks; 
  const char * qtype = NULL;
  int64_t vec_uqid;
  int64_t *chunk_uqids = NULL;
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
  if ( itmp != g_S.chunk_size ) { go_BYE(-1); }
  //------------------
  status = get_int_from_tbl(L, "vec_uqid", &is_key, &vec_uqid);  
  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  //------------------
  num_chunks = ceil((double)num_elements / (double)g_S.chunk_size);
  chunk_uqids = malloc(num_chunks * sizeof(uint64_t));
  return_if_malloc_failed(chunk_uqids);
  memset(chunk_uqids, 0,  num_chunks * sizeof(uint64_t));
  status = get_array_of_ints_from_tbl(L, "chunk_uqids", &is_key, 
        chunk_uqids, num_chunks);
  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  //------------------
  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_rehydrate(&g_S, ptr_vec, qtype, field_width, 
      num_elements, vec_uqid, chunk_uqids);
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
static int l_vec_make_chunk_file( lua_State *L) 
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
  status = vec_make_chunk_file(&g_S, ptr_vec, free_mem, chunk_idx); 
  cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_make_chunk_files( lua_State *L) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( ( num_args < 1 ) || ( num_args > 2 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool free_mem = false; // default 
  if ( num_args == 2 ) {
    free_mem = lua_toboolean(L, 2); 
  }
  status = vec_make_chunk_files(&g_S, ptr_vec, free_mem); cBYE(status);
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vec_master( lua_State *L) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( ( num_args < 1 ) || ( num_args > 2 ) ) { go_BYE(-1); }
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool free_mem = false; // default 
  if ( num_args == 2 ) {
    free_mem = lua_toboolean(L, 2); 
  }
  status = vec_master(&g_S, ptr_vec, free_mem); cBYE(status);
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
    { "check_chunks", l_vec_check_chunks }, 
    { "chunk_size", l_vec_chunk_size }, 
    { "data_dir", l_vec_data_dir }, 
    { "delete", l_vec_delete },

    { "delete_chunk_file", l_vec_delete_chunk_file },
    { "make_chunk_file", l_vec_make_chunk_file },
    { "make_chunk_files", l_vec_make_chunk_files },

    { "end_read", l_vec_end_read },
    { "end_write", l_vec_end_write },
    { "eov", l_vec_eov },
    { "file_name", l_vec_file_name },
    { "free", l_vec_free },
    { "free_globals", l_vec_free_globals },
    { "get_globals", l_vec_get_globals },
    { "get1", l_vec_get1 },
    { "get_chunk", l_vec_get_chunk },
    { "init_globals", l_vec_init_globals },
    { "is_dead", l_vec_is_dead },
    { "is_eov", l_vec_is_eov },
    { "is_killable", l_vec_killable },
    { "is_memo", l_vec_is_memo },
    { "killable", l_vec_killable },
    { "me", l_vec_me },
    { "meta", l_vec_meta },
    { "memo", l_vec_memo },
    { "num_elements", l_vec_num_elements },
    { "persist", l_vec_persist },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "rehydrate", l_vec_rehydrate},
    { "reincarnate", l_vec_reincarnate},
    { "same_state", l_vec_same_state },
    { "set_globals", l_vec_set_globals },
    { "set_name", l_vec_set_name },
    { "shutdown", l_vec_shutdown },
    { "start_read", l_vec_start_read },
    { "start_write", l_vec_start_write },
    { "unget_chunk", l_vec_unget_chunk },

    { "master", l_vec_master },
    { "unmaster", l_vec_unmaster },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "check", l_vec_check },
    { "check_chunks", l_vec_check_chunks }, 
    { "chunk_size", l_vec_chunk_size }, 
    { "data_dir", l_vec_data_dir }, 
    { "delete", l_vec_delete },

    { "delete_chunk_file", l_vec_delete_chunk_file },
    { "make_chunk_file", l_vec_make_chunk_file },
    { "make_chunk_files", l_vec_make_chunk_files },

    { "eov", l_vec_eov },
    { "file_name", l_vec_file_name },
    { "free", l_vec_free },
    { "get_globals", l_vec_get_globals },
    { "init_globals", l_vec_init_globals },
    { "is_dead", l_vec_is_dead },
    { "is_eov", l_vec_is_eov },
    { "is_killable", l_vec_is_killable },
    { "is_memo", l_vec_is_memo },
    { "kill", l_vec_kill},
    { "killable", l_vec_killable },
    { "me", l_vec_me },
    { "memo", l_vec_memo },
    { "meta", l_vec_meta },
    { "new", l_vec_new },
    { "num_elements", l_vec_num_elements },
    { "persist", l_vec_persist },
    { "rehydrate", l_vec_rehydrate},
    { "reincarnate", l_vec_reincarnate},
    { "same_state", l_vec_same_state },
    { "set_globals", l_vec_set_globals },
    { "set_name", l_vec_set_name },
    { "shutdown", l_vec_shutdown },

    { "start_read", l_vec_start_read },
    { "end_read", l_vec_end_read },

    { "start_write", l_vec_start_write },
    { "end_write", l_vec_end_write },

    { "get1", l_vec_get1 },
    { "put1", l_vec_put1 },
    { "put_chunk", l_vec_put_chunk },
    { "get_chunk", l_vec_get_chunk },
    { "unget_chunk", l_vec_unget_chunk },

    { "master", l_vec_master },
    { "unmaster", l_vec_unmaster },

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

