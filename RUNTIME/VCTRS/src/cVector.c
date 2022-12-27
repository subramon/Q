#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "qtypes.h"
#include "get_file_size.h"
#include "cmem_struct.h"
#include "aux_lua_to_c.h" // get_int_from_tbl()
// #include "aux_lua_to_c.h" // get_str_from_tbl()
#include "vctr_struct.h"

#include "chnk_del.h"

#include "vctr_add.h"
#include "vctr_chk.h"
#include "vctr_cnt.h"
#include "vctr_del.h"

#include "vctr_set_lma.h"
#include "vctr_lma_access.h"
#include "vctr_make_lma.h"
#include "vctr_lma_to_chnks.h"
#include "vctr_chnks_to_lma.h"

#include "vctr_drop_l1_l2.h"
#include "vctr_eov.h"
#include "vctr_early_free.h"
#include "vctr_incr_ref_count.h"
#include "vctr_is.h"
#include "vctr_is_eov.h"
#include "vctr_is_early_free.h"
#include "vctr_l1_to_l2.h"
#include "vctr_is_persist.h"
#include "vctr_get_chunk.h"
#include "vctr_get1.h"
#include "vctr_name.h"
#include "vctr_num_elements.h"
#include "vctr_persist.h"
#include "vctr_print.h"
#include "vctr_putn.h"
#include "vctr_put1.h"
#include "vctr_put_chunk.h"
#include "vctr_set_memo.h"
#include "vctr_width.h"

  /*
  ** Implementation of luaL_testudata which will return NULL in case 
  if udata is not of type tname
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
static int l_vctr_set_name( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  const char * const name  = luaL_checkstring(L, 2);
  status = vctr_set_name(ptr_v->tbsp, ptr_v->uqid, name); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vctr_get_qtype( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  qtype_t qtype;
  status = vctr_get_qtype(ptr_v->tbsp, ptr_v->uqid, &qtype); cBYE(status);
  lua_pushstring(L, get_str_qtype(qtype)); 
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------------
static int l_vctr_get_name( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  char * name = vctr_get_name(ptr_v->tbsp, ptr_v->uqid); 
  if ( name == NULL ) { go_BYE(-1); } 
  lua_pushstring(L, name); // 99% sure that no strdup needed
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------------
static int l_vctr_print( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 6 ) { go_BYE(-1); }
  uint32_t uqid = 0, nn_uqid = 0;
  uint32_t tbsp = 0, nn_tbsp = 0;
  const char * opfile = NULL;
  const char * format = NULL;
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE*)luaL_checkudata(L, 1, "Vector");
  uqid = ptr_v->uqid;
  tbsp = ptr_v->tbsp;

  if ( lua_isnumber(L, 2) ) { 
    nn_uqid = 0; // indicating null 
  }
  else {
    VCTR_REC_TYPE *ptr_nn_v = (VCTR_REC_TYPE*)luaL_checkudata(L, 2, "Vector");
    nn_uqid = ptr_nn_v->uqid;
    nn_tbsp = ptr_nn_v->tbsp;
    if ( tbsp != nn_tbsp ) { go_BYE(-1); } 
  }

  if ( lua_isstring(L, 3) ) { 
    opfile = luaL_checkstring(L, 3);
  }
  if ( !lua_isnumber(L, 4) ) { go_BYE(-1); }
  uint64_t lb = luaL_checknumber(L, 4);

  if ( !lua_isnumber(L, 5) ) { go_BYE(-1); }
  uint64_t ub = luaL_checknumber(L, 5);

  if ( !lua_isstring(L, 6) ) { go_BYE(-1); }
  format = luaL_checkstring(L, 6);

  status = vctr_print(tbsp, uqid, nn_uqid, opfile, format, lb, ub); cBYE(status);
  lua_pushboolean(L, true); 
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------------
static int l_vctr_nop( lua_State *L) {
  int status = 0;
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( ptr_v == NULL ) { go_BYE(-1); }
  uint32_t uqid = ptr_v->uqid; 
  uint32_t tbsp = ptr_v->tbsp; 
  bool  is_found; uint32_t where_found = ~0;
  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_set_memo( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int memo_len = luaL_checknumber(L, 2); 
  status = vctr_set_memo(ptr_v->tbsp, ptr_v->uqid, memo_len); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_check_all( lua_State *L) {
  uint32_t tbsp = 0;
  if (  lua_gettop(L) == 1 ) { 
    tbsp = luaL_checknumber(L, 1); 
  }
  int status = status = vctrs_chk(tbsp, false); 
  if ( status == 0 ) { 
    lua_pushboolean(L, true);
  }
  else { 
    lua_pushboolean(L, false);
  }
  return 1;
}
//----------------------------------------
static int l_vctr_count( lua_State *L) {
  int status = 0;
  uint32_t tbsp = 0;
  if (  lua_gettop(L) == 1 ) { 
    tbsp = luaL_checknumber(L, 1); 
  }
  uint32_t count = vctr_cnt(tbsp);
  lua_pushnumber(L, count);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_width( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t width;
  status = vctr_width(ptr_v->tbsp, ptr_v->uqid, &width); cBYE(status);
  lua_pushnumber(L, width);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_num_elements( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint64_t num_elements;
  status = vctr_num_elements(ptr_v->tbsp, ptr_v->uqid, &num_elements); cBYE(status);
  lua_pushnumber(L, num_elements);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_chk( lua_State *L) {
  int status = 0;
  int num_args =  lua_gettop(L); if ( num_args != 3 ) { go_BYE(-1); } 
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool is_at_rest = lua_toboolean(L, 2); 
  bool is_forall   = lua_toboolean(L, 3); // just for this Vector or all
  if ( is_forall ) { 
    status = vctrs_chk(ptr_v->tbsp, is_at_rest);  cBYE(status);
  }
  else {
    status = vctr_chk(ptr_v->tbsp, ptr_v->uqid, is_at_rest);  cBYE(status);
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_is_persist( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool b_is_persist; 
  status = vctr_is_persist(ptr_v->tbsp, ptr_v->uqid, &b_is_persist);
  lua_pushboolean(L, b_is_persist);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_is_lma( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool b_is_lma; 
  status = vctr_is_lma(ptr_v->tbsp, ptr_v->uqid, &b_is_lma);
  lua_pushboolean(L, b_is_lma);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_is_eov( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool b_is_eov; 
  status = vctr_is_eov(ptr_v->tbsp, ptr_v->uqid, &b_is_eov);
  lua_pushboolean(L, b_is_eov);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_chnks_to_lma( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vctr_chnks_to_lma(ptr_v->tbsp, ptr_v->uqid); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_lma_to_chnks( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vctr_lma_to_chnks(ptr_v->tbsp, ptr_v->uqid); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_is_early_free( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool b_is_early_free; 
  status = vctr_is_early_free(ptr_v->tbsp, ptr_v->uqid, &b_is_early_free);
  lua_pushboolean(L, b_is_early_free);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_persist( lua_State *L) {
  int status = 0;
  bool bval = true;
  if (  lua_gettop(L) < 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if (  lua_gettop(L) == 2 ) { 
    bval = lua_toboolean(L, 2); 
  }
  status = vctr_persist(ptr_v->tbsp, ptr_v->uqid, bval); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_eov( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vctr_eov(ptr_v->tbsp, ptr_v->uqid); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_l1_to_l2( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); 
  if ( ( num_args < 0 ) || ( num_args > 2 ) )  { go_BYE(-1); } 
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_nn_v = NULL; uint64_t nn_uqid = 0; // for nn vector 
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( num_args == 2 ) { 
    ptr_nn_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 2, "Vector");
  }
  if ( ptr_nn_v != NULL ) { nn_uqid = ptr_nn_v->uqid; } 
  status = vctr_l1_to_l2(ptr_v->tbsp, ptr_v->uqid, nn_uqid); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_put1( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  SCLR_REC_TYPE *ptr_sclr = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");

  status = vctr_put1(ptr_v->tbsp, ptr_v->uqid, ptr_sclr); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_putn( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 3 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  int32_t n = n = luaL_checknumber(L, 3);
  char *data = ptr_cmem->data;
  if ( data == NULL ) { go_BYE(-1); }

  status = vctr_putn(ptr_v->tbsp, ptr_v->uqid, data, n); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_put_chunk( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 3 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  uint32_t n = luaL_checknumber(L, 3); // num elements in chunk

  status = vctr_put_chunk(ptr_v->tbsp, ptr_v->uqid, ptr_cmem, n); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_unget_chunk( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int chnk_idx = -1; 
  if ( !lua_isnil(L, 2) ) { 
    chnk_idx = luaL_checknumber(L, 2); 
  }
  status = vctr_unget_chunk(ptr_v->tbsp, ptr_v->uqid, chnk_idx);
  cBYE(status);
  lua_pushboolean(L, 1);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_uqid( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  lua_pushnumber(L, ptr_v->uqid);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_max_num_in_chunk( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t max_num_in_chunk;;

  status = vctr_get_max_num_in_chunk(ptr_v->tbsp, ptr_v->uqid, &max_num_in_chunk);
  cBYE(status);

  lua_pushnumber(L, max_num_in_chunk);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_ref_count( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t ref_count;
  status = vctr_get_ref_count(ptr_v->tbsp, ptr_v->uqid, &ref_count);
  cBYE(status);
  lua_pushnumber(L, ref_count);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_memo_len( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int memo_len;
  status = vctr_get_memo_len(ptr_v->tbsp, ptr_v->uqid, &memo_len);
  cBYE(status);
  lua_pushnumber(L, memo_len);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_incr_num_readers( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t num_readers;
  uint32_t chnk_idx = ~0; // some fake number
  bool is_lma; bool is_incr = true; bool is_read = true;
  if ( lua_isnil(L, 2) ) { 
    is_lma = true;
  }
  else {
    chnk_idx = luaL_checknumber(L, 2); 
    is_lma = false;
  }
  status = vctr_get_num_readers(is_read, is_incr, is_lma, ptr_v->tbsp, 
      ptr_v->uqid, chnk_idx, &num_readers);
  cBYE(status);

  lua_pushnumber(L, num_readers);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_get_num_writers( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t num_writers;
  uint32_t chnk_idx = ~0; // some fake number
  bool is_lma; bool is_incr = false; bool is_read = false;
  if ( lua_isnil(L, 2) ) { 
    is_lma = true;
  }
  else {
    chnk_idx = luaL_checknumber(L, 2); 
    is_lma = false;
  }
  status = vctr_get_num_readers(is_read, is_incr, is_lma, ptr_v->tbsp, 
      ptr_v->uqid, chnk_idx, &num_writers);
  cBYE(status);

  lua_pushnumber(L, num_writers);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_get_num_readers( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t num_readers;
  uint32_t chnk_idx = ~0; // some fake number
  bool is_lma; bool is_incr = false; bool is_read = true;
  if ( lua_isnil(L, 2) ) { 
    is_lma = true;
  }
  else {
    chnk_idx = luaL_checknumber(L, 2); 
    is_lma = false;
  }
  status = vctr_get_num_readers(is_read, is_incr, is_lma, ptr_v->tbsp, 
      ptr_v->uqid, chnk_idx, &num_readers);
  cBYE(status);

  lua_pushnumber(L, num_readers);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_get1( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int64_t elem_idx = luaL_checknumber(L, 2); 
  //-- allocate SCLR to go back 
  SCLR_REC_TYPE *ptr_s = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  return_if_malloc_failed(ptr_s);
  memset(ptr_s, '\0', sizeof(SCLR_REC_TYPE));
  luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vctr_get1(ptr_v->tbsp, ptr_v->uqid, elem_idx, ptr_s); cBYE(status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_get_chunk( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t chnk_idx = luaL_checknumber(L, 2); 
  uint32_t num_in_chunk = 0;
  //-- allocate CMEM to go back 
  CMEM_REC_TYPE *ptr_c = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_c);
  memset(ptr_c, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vctr_get_chunk(ptr_v->tbsp, ptr_v->uqid, chnk_idx, ptr_c, 
      &num_in_chunk);
  cBYE(status);

  lua_pushnumber(L, num_in_chunk);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_free( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool is_found;
  /*
  char *name = vctr_get_name(ptr_v->tbsp, ptr_v->uqid); 
  if ( name == NULL ) { 
    printf("\n"); 
  }
  else {
    printf("%s\n", name); 
  }
  */
  if (  ptr_v->uqid == 0 ) { 
    // This is because of vctr_null() Not dangerous 
    goto BYE;
  }
  status = vctr_del(ptr_v->tbsp, ptr_v->uqid, &is_found); cBYE(status); 
  lua_pushboolean(L, is_found);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//---------------------------------------------
static int l_vctr_drop_l1_l2( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  int level = luaL_checknumber(L, 2);
  status = vctr_drop_l1_l2(ptr_v->tbsp, ptr_v->uqid, level); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//---------------------------------------------
static int l_vctr_early_free( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vctr_early_free(ptr_v->tbsp, ptr_v->uqid); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_chnk_delete( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint32_t chnk_idx = luaL_checknumber(L, 2);
  bool is_found = true, b_is_persist;
  status = vctr_is_persist(ptr_v->tbsp, ptr_v->uqid, &b_is_persist); cBYE(status);
  status = chnk_del(ptr_v->tbsp, ptr_v->uqid, chnk_idx, b_is_persist);
  if ( ( status == -2 ) || ( status == -3 ) ) {
    is_found = false; status = 0; 
  }
  cBYE(status);
  lua_pushboolean(L, is_found);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_vctr_rehydrate( lua_State *L) 
{
  int status = 0;
  VCTR_REC_TYPE *ptr_v = NULL;
  bool is_key; int64_t itmp; 
  uint32_t uqid = 0, tbsp = 0;
  // width needed only for SC; all other qtypes have known fixed widths
  //--- get args passed from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking
  // CMEM_REC_TYPE *ptr_c = luaL_checkudata(L, 2, "CMEM");
  //------------------- get qtype and width
  //-------------------------------------------
  status = get_int_from_tbl(L, 1, "uqid", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); } 
  uqid = (uint32_t)itmp;
  //-------------------------------------------
  // TODO TODO P0 FIX THIS ONE 
  status = get_int_from_tbl(L, 1, "tbsp", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); } 
  tbsp = (uint32_t)itmp;
  //-------------------------------------------

  ptr_v = (VCTR_REC_TYPE *)lua_newuserdata(L, sizeof(VCTR_REC_TYPE));
  return_if_malloc_failed(ptr_v);
  memset(ptr_v, '\0', sizeof(VCTR_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  bool  is_found; uint32_t where_found = ~0;
  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { go_BYE(-1); } 
  status = vctr_incr_ref_count(tbsp, where_found); cBYE(status);
  ptr_v->uqid = uqid; 

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
static int l_vctr_add1( lua_State *L) 
{
  int status = 0;
  VCTR_REC_TYPE *ptr_v = NULL;
  bool is_key; int64_t itmp; 
  const char * str_qtype = NULL, *str_name = NULL, *file_name = NULL;
  uint32_t width = 0; 
  uint32_t max_num_in_chnk;
  int memo_len;
  // width needed only for SC; all other qtypes have known fixed widths
  //--- get args passed from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking
  // CMEM_REC_TYPE *ptr_c = luaL_checkudata(L, 2, "CMEM");
  //------------------- get name
  status = get_str_from_tbl(L, 1, "name", &is_key, &str_name);  
  cBYE(status);
  //------------------- get file_name
  status = get_str_from_tbl(L, 1, "file_name", &is_key, &file_name);  
  cBYE(status);
  //------------------- get qtype 
  status = get_str_from_tbl(L, 1, "qtype", &is_key, &str_qtype);  
  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( *str_qtype == '\0' ) { go_BYE(-1); }
  qtype_t qtype  = get_c_qtype(str_qtype);
  if ( qtype == Q0 ) { go_BYE(-1); }
  //-------------------- get width 
  status = get_int_from_tbl(L, 1, "width", &is_key, &itmp); cBYE(status);
  if ( is_key )  { 
    if ( itmp < 1 ) { go_BYE(-1); }
  }
  else { // must specify width for SC 
    if ( qtype == SC ) { go_BYE(-1); } 
    itmp = get_width_c_qtype(qtype);
  }
  width = (uint32_t)itmp;
  // need to keep 1 char for nullc when qtype == SC 
  if ( qtype == SC ) { if ( width < 2 ) { go_BYE(-1); } }
  //-------------------------------------------
  status = get_int_from_tbl(L, 1, "max_num_in_chunk", &is_key, &itmp); 
  cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp <= 0 ) { go_BYE(-1); }
  max_num_in_chnk = (uint32_t)itmp;
  //-------------------------------------------
  status = get_int_from_tbl(L, 1, "memo_len", &is_key, &itmp); 
  cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  memo_len = itmp;
  //-------------------------------------------

  ptr_v = (VCTR_REC_TYPE *)lua_newuserdata(L, sizeof(VCTR_REC_TYPE));
  return_if_malloc_failed(ptr_v);
  memset(ptr_v, '\0', sizeof(VCTR_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vctr_add1(qtype, width, max_num_in_chnk, memo_len,
      &ptr_v->uqid); 
  cBYE(status);
  if ( ( str_name != NULL ) && ( * str_name != '\0' ) ) {
    status = vctr_set_name(ptr_v->tbsp, ptr_v->uqid, str_name); cBYE(status);
  }
  if ( ( file_name != NULL ) && ( *file_name != '\0' ) ) {
    uint64_t num_elements = 0;
    status = get_int_from_tbl(L, 1, "num_elements", &is_key, &itmp); 
    cBYE(status);
    if ( is_key )  { 
      if ( itmp < 1 ) { go_BYE(-1); } 
      num_elements = (uint64_t)itmp;
    }
    status = vctr_set_lma(ptr_v->tbsp, ptr_v->uqid, file_name, num_elements); 
    cBYE(status);
  }

  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
static int l_vctr_null( lua_State *L) 
{ // create a null vector, needed for function signature compatibility
  int status = 0;
  VCTR_REC_TYPE *ptr_v = NULL;
  ptr_v = (VCTR_REC_TYPE *)lua_newuserdata(L, sizeof(VCTR_REC_TYPE));
  return_if_malloc_failed(ptr_v);
  memset(ptr_v, '\0', sizeof(VCTR_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------------------
static int l_make_lma( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  char *file_name  = vctr_make_lma(ptr_v->tbsp, ptr_v->uqid); 
  if ( file_name == NULL ) { go_BYE(-1); } 
  int64_t file_sz = get_file_size(file_name); 
  lua_pushstring(L, file_name);
  lua_pushnumber(L, file_sz);
  return 2;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------------------
static int l_get_lma_write( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //-- allocate CMEM to go back 
  CMEM_REC_TYPE *ptr_x = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_x);
  memset(ptr_x, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vctr_get_lma_write(ptr_v->tbsp, ptr_v->uqid, ptr_x); cBYE(status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------------------
static int l_get_lma_read( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  //-- allocate CMEM to go back 
  CMEM_REC_TYPE *ptr_x = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_x);
  memset(ptr_x, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = vctr_get_lma_read(ptr_v->tbsp, ptr_v->uqid, ptr_x); cBYE(status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_unget_lma_read( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  status = vctr_unget_lma_read(ptr_v->tbsp, ptr_v->uqid); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------
static int l_unget_lma_write( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); 
  if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");

  status = vctr_unget_lma_write(ptr_v->tbsp, ptr_v->uqid); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
//----------------------------------------

//-----------------------
static const struct luaL_Reg vector_methods[] = {
    { "__gc",    l_vctr_free   },
    { "delete",    l_vctr_free   }, // try not to call this explicitly
    { "chk", l_vctr_chk },
    { "check_all", l_vctr_check_all },

    { "free", l_vctr_free },
    { "chunk_delete", l_chnk_delete },
    //--------------------------------
    { "eov",    l_vctr_eov },
    { "early_free",    l_vctr_early_free },
    { "is_eov", l_vctr_is_eov },
    { "is_lma", l_vctr_is_lma },
    { "is_early_free", l_vctr_is_early_free },
    { "nop", l_vctr_nop },
    //--------------------------------
    { "lma_to_chnks", l_vctr_lma_to_chnks },
    { "chnks_to_lma", l_vctr_chnks_to_lma },
    { "get_lma_read",     l_get_lma_read },
    { "get_lma_write",    l_get_lma_write },
    { "make_lma",         l_make_lma },
    { "unget_lma_read",   l_unget_lma_read },
    { "unget_lma_write",  l_unget_lma_write },
    //--------------------------------
    { "set_memo", l_vctr_set_memo },
    { "set_name", l_vctr_set_name },
    //--------------------------------
    { "name", l_vctr_get_name },
    { "qtype", l_vctr_get_qtype },
    { "num_elements", l_vctr_num_elements },
    { "num_readers", l_vctr_get_num_readers },
    { "num_writers", l_vctr_get_num_writers },
    { "incr_num_readers", l_vctr_incr_num_readers },
    { "max_num_in_chunk", l_vctr_max_num_in_chunk },
    { "memo_len", l_vctr_memo_len },
    { "ref_count", l_vctr_ref_count },
    { "uqid", l_vctr_uqid },
    { "width", l_vctr_width },
    { "pr", l_vctr_print },
    // creation, new, ...
    { "add1", l_vctr_add1 },
    { "rehydrate", l_vctr_rehydrate },
    { "null", l_vctr_null },
    //--------------------------------
    { "put1", l_vctr_put1 },
    { "putn", l_vctr_putn },
    { "put_chunk", l_vctr_put_chunk },
    { "get1", l_vctr_get1 },
    { "get_chunk", l_vctr_get_chunk },
    { "unget_chunk", l_vctr_unget_chunk },
    //--------------------------------
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "delete",    l_vctr_free   }, // try not to call this explicitly
    { "chk", l_vctr_chk },
    { "check_all", l_vctr_check_all },

    { "free", l_vctr_free },
    { "chunk_delete", l_chnk_delete },
    //--------------------------------
    { "eov",    l_vctr_eov },
    { "early_free",    l_vctr_early_free },
    { "is_eov", l_vctr_is_eov },
    { "is_lma", l_vctr_is_lma },
    { "is_early_free", l_vctr_is_early_free },
    { "persist", l_vctr_persist },
    { "is_persist", l_vctr_is_persist },
    { "nop",    l_vctr_nop },
    //--------------------------------
    { "lma_to_chnks", l_vctr_lma_to_chnks },
    { "chnks_to_lma", l_vctr_chnks_to_lma },
    { "get_lma_read",     l_get_lma_read },
    { "get_lma_write",    l_get_lma_write },
    { "make_lma",         l_make_lma },
    { "unget_lma_read",   l_unget_lma_read },
    { "unget_lma_write",  l_unget_lma_write },
    //--------------------------------
    { "set_memo", l_vctr_set_memo},
    { "set_name", l_vctr_set_name },
    //--------------------------------
    { "count", l_vctr_count },
    { "name", l_vctr_get_name },
    { "qtype", l_vctr_get_qtype },
    { "num_elements", l_vctr_num_elements },
    { "num_readers", l_vctr_get_num_readers },
    { "num_writers", l_vctr_get_num_writers },
    { "incr_num_readers", l_vctr_incr_num_readers },
    { "max_num_in_chunk", l_vctr_max_num_in_chunk },
    { "max_num_in_chunk", l_vctr_max_num_in_chunk },
    { "uqid", l_vctr_uqid },
    { "memo_len", l_vctr_memo_len },
    { "ref_count", l_vctr_ref_count },
    { "width", l_vctr_width },
    { "pr", l_vctr_print },
    // creation, new, ...
    { "add1", l_vctr_add1 },
    { "drop_l1_l2", l_vctr_drop_l1_l2 },
    { "rehydrate", l_vctr_rehydrate },
    { "null", l_vctr_null },
    //--------------------------------
    { "l1_to_l2", l_vctr_l1_to_l2 },
    //--------------------------------
    { "put1", l_vctr_put1 },
    { "putn", l_vctr_putn },
    { "put_chunk", l_vctr_put_chunk },
    { "get1", l_vctr_get1 },
    { "get_chunk", l_vctr_get_chunk },
    { "unget_chunk", l_vctr_unget_chunk },
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

