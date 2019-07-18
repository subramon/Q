#define LUA_LIB

#define ALIGNMENT  256 // TODO P2 DOCUMENT AND PLACE CAREFULLY

#include <stdlib.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

// #include "q_constants.h" // gets us Q_CHUNK_SIZE 
#include "q_incs.h"
#include "core_vec.h"
#include "scalar_struct.h"
#include "cmem_struct.h"
#include "cmem.h"
#include "mm.h"
#include "_txt_to_I4.h"

// TODO P3: I don't like this static. What's the best way to 
// store stuff on the C side of the fence to avoid Lua having to 
// send it each time
static int32_t chunk_size = 0; 



static int l_set_chunk_size( lua_State *L) {
  int32_t new_chunk_size  = luaL_checknumber(L, 1);
  if ( new_chunk_size < 64 ) { WHEREAMI; goto BYE; }
  // check that it is a power of 2 
  for ( int32_t x = new_chunk_size; x > 1; ) { 
    if ( ( ( x / 2 ) * 2 ) != x ) { WHEREAMI; goto BYE; }
    x = x / 2;
  }
  chunk_size = new_chunk_size;
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  char buf[128];
  sprintf(buf, "ERROR: %s: bad chunk size %d \n", __func__, new_chunk_size);
  lua_pushstring(L, buf);
  return 2;
}

static int l_print_timers( lua_State *L) {
  vec_print_timers();
  return 0;
}

static int l_print_mem( lua_State *L) {
  int status = 0;
  char buf[128];
  uint64_t vec_sz, sz2;
  status = mm(0, false, false, &vec_sz, &sz2); cBYE(status);
  
  bool is_quiet = true;
  if ( lua_isboolean(L, 2) ) { 
    is_quiet = lua_toboolean(L, 2);
  }
  if ( !is_quiet ) { 
    fprintf(stdout, "VEC,sz_malloc,0,%" PRIu64 "\n", vec_sz);
  }
  lua_pushnumber(L, vec_sz);
  return 1;
BYE:
  lua_pushnil(L);
  sprintf(buf, "ERROR: %s\n", __func__);
  lua_pushstring(L, buf);
  return 2;
}

static int l_reset_timers( lua_State *L) {
  vec_reset_timers();
  return 0;
}

static int 
get_chunk_size(
  lua_State *L,
  int32_t *ptr_chunk_size
)
{
  int status = 0;
  *ptr_chunk_size = 0;
  if ( chunk_size == 0 ) { 
    status = luaL_dostring(L, "return require('Q/UTILS/lua/q_consts').chunk_size");
    if ( status != 0 ) {
      fprintf(stderr, "Failed in getting chunk_size:  %s\n", lua_tostring(L, -1));
      exit(1);
    }
    chunk_size = lua_tonumber(L, -1);
    lua_pop(L, 1); 
    // fprintf(stderr, "C code chunk_size = %d \n", chunk_size);
  }
  *ptr_chunk_size = chunk_size;
  return status;
}
LUALIB_API void *luaL_testudata (lua_State *L, int ud, const char *tname);
int luaopen_libvec (lua_State *L);
//----------------------------------------
static int l_vec_no_memcpy( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE  *ptr_vec  = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  if ( chunk_size <= 0 ) { 
    status = get_chunk_size(L, &chunk_size); cBYE(status);
  }
  status = vec_no_memcpy(ptr_vec, ptr_cmem, chunk_size); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: l_vec_no_memcpy. ");
  return 2;
}
//-----------------------------------
static int l_vec_flush_buffer( lua_State *L) {
  int status = 0;
  // TODO P3 Delete this function once you are sure it is not needed
  go_BYE(-1); 
  VEC_REC_TYPE  *ptr_vec  = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = flush_buffer(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: l_vec_flush_buffer. ");
  return 2;
}
//----------------------------------------
static int l_vec_set_name( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  const char * const name  = luaL_checkstring(L, 2);
  status = vec_set_name(ptr_vec, name); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_set_name. ");
  return 2;
}
//-----------------------------------
static int l_vec_get_name( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushstring(L, ptr_vec->name);
  return 1;
}
//----------------------------------------
static int l_vec_fldtype( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushstring(L, ptr_vec->field_type);
  return 1;
}
//----------------------------------------
static int l_vec_field_size( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->field_size);
  return 1;
}
//----------------------------------------
static int l_vec_cast( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  const char * const new_field_type  = luaL_checkstring(L, 2);
  int32_t new_field_size  = luaL_checknumber(L, 3);
  status = vec_cast(ptr_vec, new_field_type, new_field_size); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_cast. ");
  return 2;
}
//----------------------------------------
static int l_vec_is_eov( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_eov);
  return 1;
}
//----------------------------------------
static int l_vec_file_name( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( ptr_vec->file_name[0] == '\0' ) { WHEREAMI; goto BYE; }
  lua_pushstring(L, ptr_vec->file_name);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_file_name. ");
  return 2;
}
//----------------------------------------
static int l_vec_file_size( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( ptr_vec->file_name[0] == '\0' ) { WHEREAMI; goto BYE; }
  lua_pushnumber(L, ptr_vec->file_size);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_file_size. ");
  return 2;
}
//----------------------------------------
static int l_vec_is_mono( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_mono);
  return 1;
}
//----------------------------------------
static int l_vec_is_memo( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_memo);
  return 1;
}
//----------------------------------------
static int l_vec_mono( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_mono = true;
  if ( lua_isboolean(L, 2) ) { 
    is_mono = lua_toboolean(L, 2);
  }
  //------------------------------
  status = vec_mono(ptr_vec, is_mono); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_mono. ");
  return 2;
}
//----------------------------------------
static int l_vec_memo( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_memo = true;
  if ( lua_isboolean(L, 2) ) { 
    is_memo = lua_toboolean(L, 2);
  }
  //------------------------------
  status = vec_memo(ptr_vec, is_memo); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_memo. ");
  return 2;
}
//----------------------------------------
static int l_vec_persist( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  bool is_persist = true;
  if ( lua_isboolean(L, 2) ) { 
    is_persist = lua_toboolean(L, 2);
  }
  //------------------------------
  status = vec_persist(ptr_vec, is_persist); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_memo. ");
  return 2;
}
//----------------------------------------
static int l_vec_eov( lua_State *L) {
  int status = 0;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //------------------------------
  status = vec_eov(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_eov. ");
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vec_get( lua_State *L) {
  int status = 0;
  char *ret_addr = NULL;
  uint64_t ret_len = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  SCLR_REC_TYPE *ptr_sclr = NULL;

  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t idx = luaL_checknumber(L, 2);
  int32_t len = luaL_checknumber(L, 3);
  status = vec_get(ptr_vec, idx, len, &ret_addr, &ret_len);
  cBYE(status);
  int num_to_return = 2;

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  // printf("cmem dupe to %x \n", ptr_cmem);

  // TODO: Should we be using ret_len below?
  status = cmem_dupe(ptr_cmem, ret_addr, ret_len, ptr_vec->field_type, "");
  cBYE(status);
  lua_pushinteger(L, ret_len);

  if ( len == 1 ) {  // this is for debugging help and for get_one()

    ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
    return_if_malloc_failed(ptr_sclr);
    memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
    luaL_getmetatable(L, "Scalar");/* Add the metatable to the stack. */
    lua_setmetatable(L, -2);/* Set the metatable on the userdata. */
    // printf("sclr new to %x \n", ptr_sclr);

    num_to_return++;
    strcpy(ptr_sclr->field_type, ptr_vec->field_type);
    ptr_sclr->field_size = ptr_vec->field_size;
    if ( strcmp(ptr_sclr->field_type, "B1") == 0 ) { 
      uint64_t word = ((uint64_t *)ret_addr)[0];
      uint32_t bit_idx = idx % 64;
      ptr_sclr->cdata.valB1 = word >> bit_idx & 0x1;
    }
    else {
      memcpy(&(ptr_sclr->cdata), ret_addr, ptr_vec->field_size);
    }
  }
  return num_to_return;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_get. ");
  return 2;
}
//------------------------------------------
static int l_vec_get_chunk( lua_State *L) 
{
  int status = 0;
  char *ret_addr = NULL;
  uint64_t ret_len = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  int64_t chunk_num = -1;
  uint64_t idx = 0;

  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( chunk_size <= 0 ) { 
    status = get_chunk_size(L, &chunk_size); cBYE(status);
  }

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  cmem_undef(ptr_cmem);

  chunk_num = luaL_checknumber(L, 2);
  if ( chunk_num < 0 ) { go_BYE(-1); }
  idx = chunk_num * chunk_size;

  bool is_malloc = false; 
  if ( ( chunk_num < ptr_vec->chunk_num ) && ( ptr_vec->is_eov == false ) ){
    if ( ptr_vec->is_memo == false ) { go_BYE(-1); }
    is_malloc = true;
    // allocate memory since you cannot send back address of Vector's chunk
    status = cmem_malloc(ptr_cmem, ptr_vec->chunk_sz, 
        ptr_vec->field_type, "", ALIGNMENT);
    cBYE(status);
    ret_addr = ptr_cmem->data;
  }
  status = vec_get(ptr_vec, idx, chunk_size, &ret_addr, &ret_len);
  // if asked for too far or something that we cannot satisfy, error
  if ( status == -2 ) { goto BYE; } 
  cBYE(status);
  if ( is_malloc ) { 
    // already taken care of 
  }
  else {
    // TODO This is special case for return of mmap pointer
    // THINK THROUGH IT MORE CAREFULLY P1
    int64_t csz = ptr_vec->chunk_sz;
    if ( csz == 0 ) { 
      csz = ptr_vec->map_len;
    }
    status = cmem_dupe(ptr_cmem, ret_addr, csz, ptr_vec->field_type, "");
    cBYE(status);
    // printf("cmem dupe to %x \n", ptr_cmem);
  }
  lua_pushinteger(L, ret_len);
  return 2;
BYE:
  lua_pushnil(L); 
  lua_pushinteger(L, 0);
  lua_pushstring(L, "ERROR: vec_get. "); 
  return 3;
}
//----------------------------------------------------
static int l_vec_put1( lua_State *L) {
  int status = 0;
  void *addr = NULL;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( !ptr_vec->is_nascent ) { go_BYE(-1); }
  if ( strcmp(ptr_vec->field_type, "SC") == 0 ) { 
    CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 2, "CMEM");
    addr = ptr_cmem->data;
  }
  else {
    SCLR_REC_TYPE *ptr_sclr = luaL_checkudata(L, 2, "Scalar");
    if ( strcmp(ptr_vec->field_type, ptr_sclr->field_type) != 0 ) { 
      go_BYE(-1);
    }
    addr = (void *)(&ptr_sclr->cdata);
  }
  status = vec_add(ptr_vec, addr, 1); cBYE(status);
  lua_pushinteger(L, status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_put1. ");
  return 2;
}
//----------------------------------------
static int l_vec_start_write( lua_State *L) {
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vec_start_write(ptr_vec); cBYE(status);

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  cmem_dupe(ptr_cmem, ptr_vec->map_addr, ptr_vec->map_len, 
      ptr_vec->field_type, ptr_vec->name);

  lua_pushinteger(L, ptr_vec->num_elements);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_start_write. ");
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
  lua_pushstring(L, "ERROR: vec_end_write. ");
  return 2;
}
//----------------------------------------

static int l_vec_set( lua_State *L) {
  int status = 0;
  char *addr;
  int64_t idx;
  int32_t len;
  double buf; // need this to be word aligned
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  idx = luaL_checknumber(L, 3);
  if (  luaL_testudata(L, 2, "CMEM") ) { 
    CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 2, "CMEM");
    addr = ptr_cmem->data;
    len = luaL_checknumber(L, 4);
  }
  else if (  luaL_testudata(L, 2, "Scalar") ) { 
    SCLR_REC_TYPE *ptr_sclr = luaL_checkudata(L, 2, "Scalar");
    addr = (char *)&(ptr_sclr->cdata);
    len = 1;
  }
  else if (  lua_isnumber(L, 2) ) {
    double dtemp = luaL_checknumber(L, 2);
    if ( strcmp(ptr_vec->field_type, "B1") == 0 ) { 
      bool val = dtemp; memcpy(&buf, &val, 1);
    }
    else if ( strcmp(ptr_vec->field_type, "I1") == 0 ) { 
      int8_t val = dtemp; memcpy(&buf, &val, 1);
    }
    else if ( strcmp(ptr_vec->field_type, "I2") == 0 ) { 
      int16_t val = dtemp; memcpy(&buf, &val, 2);
    }
    else if ( strcmp(ptr_vec->field_type, "I4") == 0 ) { 
      int32_t val = dtemp; memcpy(&buf, &val, 4);
    }
    else if ( strcmp(ptr_vec->field_type, "I8") == 0 ) { 
      int64_t val = dtemp; memcpy(&buf, &val, 8);
    }
    else if ( strcmp(ptr_vec->field_type, "F4") == 0 ) { 
      float val = dtemp; memcpy(&buf, &val, 4);
    }
    else if ( strcmp(ptr_vec->field_type, "F8") == 0 ) { 
      double val = dtemp; memcpy(&buf, &val, 8);
    }
    // Note that SV is treated as I4
    else if ( strcmp(ptr_vec->field_type, "SV") == 0 ) { 
      int32_t val = dtemp; memcpy(&buf, &val, 4);
    }
    else {
      go_BYE(-1);
    }
    addr = (char *)&buf;
    len = 1;
  }
  else {
    go_BYE(-1);
  }
  status = vec_set(ptr_vec, addr, idx, len); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_set. ");
  return 2;
}
//----------------------------------------
static int l_vec_put_chunk( lua_State *L) {
  int status = 0;
  void *addr = NULL;
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int32_t len = luaL_checknumber(L, 3);
  if ( !luaL_testudata (L, 2, "CMEM") ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 2, "CMEM");
  if ( ptr_cmem == NULL ) { go_BYE(-1); }
  addr = ptr_cmem->data;
  //---------------------------------------
  status = vec_add(ptr_vec, addr, len); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_put_chunk. ");
  return 2;
}
//----------------------------------------
static int l_vec_is_nascent( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushboolean(L, ptr_vec->is_nascent);
  return 1;
}
//----------------------------------------
static int l_vec_chunk_num( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->chunk_num);
  return 1;
}
//----------------------------------------
static int l_vec_chunk_size( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->chunk_size);
  return 1;
}
//----------------------------------------
static int l_vec_num_in_chunk( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->num_in_chunk);
  return 1;
}
//----------------------------------------
static int l_vec_num_elements( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  lua_pushnumber(L, ptr_vec->num_elements);
  return 1;
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
    lua_pushstring(L, "ERROR: vec_check. ");
    return 2;
  }
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
    lua_pushstring(L, "ERROR: vec_check. ");
    return 2;
  }
}
//----------------------------------------
static int l_vec_free( lua_State *L) {
  VEC_REC_TYPE *ptr_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int status = vec_free(ptr_vec); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: vec_free. ");
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
  lua_pushstring(L, "ERROR: vec_delete. ");
  return 2;
}
//----------------------------------------
static int l_vec_new( lua_State *L) 
{
  int status = 0;
  VEC_REC_TYPE *ptr_vec = NULL;

  bool is_memo = true;
  const char *q_data_dir = NULL;
  const char *file_name = NULL;
  int64_t num_elements = -1;
  const char * const qtype_sz  = luaL_checkstring(L, 1);
  /* Note that I would have normally called it qtype 
     instead of qtype_sz but in the case of SC we send 
     SC:len where len is an integer */
  if ( chunk_size <= 0 ) { 
    status = get_chunk_size(L, &chunk_size); cBYE(status);
  }

  q_data_dir = luaL_checkstring(L, 2);
  if ( q_data_dir == NULL ) { go_BYE(-1); }
  if ( lua_isstring(L, 3) ) { // filename provided for materialized vec
    file_name = luaL_checkstring(L, 3);
  }
  if ( lua_isboolean(L, 4) ) { // is_memo specified
    is_memo = lua_toboolean(L, 4);
  }
  if ( file_name != NULL && strcmp(qtype_sz, "B1") == 0 ) { // num_elements provided for materialized B1 vec
    num_elements = luaL_checknumber(L, 5);
    if ( num_elements <= 0 ) { go_BYE(-1); }
  }

  ptr_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_vec);
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  // printf("vect new to %x \n", ptr_vec);

  status = vec_new(ptr_vec, qtype_sz, q_data_dir, chunk_size, is_memo, file_name, num_elements);
  cBYE(status);

  return 1; // Used to be return 2 because of errbuf return
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not create vector\n");
  return 2;
}
//----------------------------------------
static int l_vec_clone( lua_State *L) 
{
  int status = 0;
  const char *q_data_dir = NULL;
  VEC_REC_TYPE *ptr_new_vec = NULL;

  VEC_REC_TYPE *ptr_old_vec = (VEC_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  q_data_dir = luaL_checkstring(L, 2);
  if ( q_data_dir == NULL ) { go_BYE(-1); }  

  ptr_new_vec = (VEC_REC_TYPE *)lua_newuserdata(L, sizeof(VEC_REC_TYPE));
  return_if_malloc_failed(ptr_new_vec);
  memset(ptr_new_vec, '\0', sizeof(VEC_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vec_clone(ptr_old_vec, ptr_new_vec, q_data_dir);
  cBYE(status);

  return 1; // Used to be return 2 because of errbuf return
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not clone vector\n");
  return 2;
}
//-----------------------
static const struct luaL_Reg vector_methods[] = {
    { "__gc",    l_vec_free   },
    { "eov", l_vec_eov },
    { "check", l_vec_check },
    { "meta", l_vec_meta },
    { "put1", l_vec_put1 },
    { "persist", l_vec_persist },
    { "memo", l_vec_memo },
    { "mono", l_vec_mono },
    { "is_memo", l_vec_is_memo },
    { "is_mono", l_vec_is_mono },
    { "num_elements", l_vec_num_elements },
    { "num_in_chunk", l_vec_num_in_chunk },
    { "chunk_size", l_vec_chunk_size },
    { "get_chunk", l_vec_get_chunk },
    { "set_chunk_size", l_set_chunk_size },
    { "put_chunk", l_vec_put_chunk },
    { "is_eov", l_vec_is_eov },
    { "cast", l_vec_cast },
    { "set", l_vec_set },
    { "get", l_vec_get },
    { "set_name", l_vec_set_name },
    { "get_name", l_vec_get_name },
    { "fldtype", l_vec_fldtype },
    { "file_size", l_vec_file_size },
    { "file_name", l_vec_file_name },
    { "field_size", l_vec_field_size },
    { "start_write", l_vec_start_write },
    { "end_write", l_vec_end_write },
    { "no_memcpy", l_vec_no_memcpy },
    { "flush_buffer", l_vec_flush_buffer },
    { "delete", l_vec_delete },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "new", l_vec_new },
    { "clone", l_vec_clone },
    { "check", l_vec_check },
    { "meta", l_vec_meta },
    { "num_elements", l_vec_num_elements },
    { "num_in_chunk", l_vec_num_in_chunk },
    { "put1", l_vec_put1 },
    { "persist", l_vec_persist },
    { "memo", l_vec_memo },
    { "mono", l_vec_mono },
    { "is_memo", l_vec_is_memo },
    { "is_mono", l_vec_is_mono },
    { "set", l_vec_set },
    { "get", l_vec_get },
    { "set_name", l_vec_set_name },
    { "get_name", l_vec_get_name },
    { "fldtype", l_vec_fldtype },
    { "field_size", l_vec_field_size },
    { "eov", l_vec_eov },
    { "chunk_num", l_vec_chunk_num },
    { "chunk_size", l_vec_chunk_size },
    { "file_size", l_vec_file_size },
    { "file_name", l_vec_file_name },
    { "is_nascent", l_vec_is_nascent },
    { "is_eov", l_vec_is_eov },
    { "cast", l_vec_cast },
    { "get_chunk", l_vec_get_chunk },
    { "set_chunk_size", l_set_chunk_size },
    { "put_chunk", l_vec_put_chunk },
    { "start_write", l_vec_start_write },
    { "end_write", l_vec_end_write },
    { "print_timers", l_print_timers },
    { "print_mem", l_print_mem },
    { "reset_timers", l_reset_timers },
    { "no_memcpy", l_vec_no_memcpy },
    { "flush_buffer", l_vec_flush_buffer },
    { "delete", l_vec_delete },
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
  int luaopen_libvec (lua_State *L) {
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
