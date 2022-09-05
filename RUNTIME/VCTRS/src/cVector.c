#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"
#include "qtypes.h"
#include "cmem_struct.h"
#include "aux_lua_to_c.h" // get_int_from_tbl()
// #include "aux_lua_to_c.h" // get_str_from_tbl()
#include "vctr_struct.h"

#include "vctr_add.h"
#include "vctr_chk.h"
#include "vctr_del.h"
#include "vctr_name.h"
#include "vctr_num_elements.h"
#include "vctr_is_eov.h"
#include "vctr_put.h"
#include "vctr_put_chunk.h"

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
static int l_vctr_set_name( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  const char * const name  = luaL_checkstring(L, 2);
  status = vctr_set_name(ptr_v->uqid, name); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_vctr_get_name( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  char * name = vctr_get_name(ptr_v->uqid); 
  if ( name == NULL ) { go_BYE(-1); } 
  lua_pushstring(L, name); // TODO make sure no strdup needed
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------------
static int l_vctr_nop( lua_State *L) {
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  if ( ptr_v == NULL ) { goto BYE; }
  fprintf(stdout, "nop\n");
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vctr_num_elements( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  uint64_t num_elements;
  status = vctr_num_elements(ptr_v->uqid, &num_elements); cBYE(status);
  lua_pushnumber(L, num_elements);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vctr_chk( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  status = vctr_chk(ptr_v->uqid);  cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vctr_is_eov( lua_State *L) {
  int status = 0;
  if (  lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool b_is_eov; 
  status = vctr_is_eov(ptr_v->uqid, &b_is_eov);
  lua_pushboolean(L, b_is_eov);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vctr_put( lua_State *L) {
  int status = 0;
  // get args from Lua 
  int num_args = lua_gettop(L); if ( num_args != 2 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 2, "CMEM");
  char *data = ptr_cmem->data;
  int64_t n = luaL_checknumber(L, 3);

  status = vctr_put(ptr_v->uqid, data, n); cBYE(status);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vctr_put_chunk( lua_State *L) {
  int status = 0;
  // TODO 
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vctr_free( lua_State *L) {
  WHEREAMI; // TODO delete 
  int status = 0;
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool is_found;
  status = vctr_del(ptr_v->uqid, &is_found); 
  lua_pushboolean(L, is_found);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//-----------------------
// TODO: Do we care about this difference? If so, implement it 
// Difference between delete and free is that in delete we destroy
// an underlying file if it exists
// free just 
// (1) frees   stuff that has been malloc'd and 
// (2) munmaps stuff that has been mmapped
static int l_vctr_delete( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  VCTR_REC_TYPE *ptr_v = (VCTR_REC_TYPE *)luaL_checkudata(L, 1, "Vector");
  bool is_found;
  status = vctr_del(ptr_v->uqid, &is_found); 
  lua_pushboolean(L, is_found);
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
//----------------------------------------
static int l_vctr_add1( lua_State *L) 
{
  int status = 0;
  VCTR_REC_TYPE *ptr_v = NULL;
  bool is_key; int64_t itmp; 
  const char * str_qtype;
  qtype_t qtype;
  uint32_t width; 
  uint32_t chunk_size;
  // width needed only for SC; all other qtypes have known fixed widths
  //--- get args passed from Lua 
  int num_args = lua_gettop(L); if ( num_args != 1 ) { go_BYE(-1); }
  if ( !lua_istable(L, 1) ) { go_BYE(-1); }
  luaL_checktype(L, 1, LUA_TTABLE ); // another way of checking
  // CMEM_REC_TYPE *ptr_c = luaL_checkudata(L, 2, "CMEM");
  //------------------- get qtype and width
  status = get_str_from_tbl(L, 1, "qtype", &is_key, &str_qtype);  
  cBYE(status);
  if ( !is_key ) { go_BYE(-1); }
  if ( *str_qtype == '\0' ) { go_BYE(-1); }
  //----------------
  status = get_int_from_tbl(L, 1, "width", &is_key, &itmp); cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp < 1 ) { go_BYE(-1); }
  if ( strcmp(str_qtype, "SC") == 0 ) { 
    if ( itmp < 2 ) { go_BYE(-1); }
  }
  width = (uint32_t)itmp;
  //------------------
  status = get_int_from_tbl(L, 1, "chunk_size", &is_key, &itmp); 
  cBYE(status);
  if ( !is_key )  { go_BYE(-1); }
  if ( itmp < 0 ) { go_BYE(-1); }
  chunk_size = (uint32_t)itmp;

  ptr_v = (VCTR_REC_TYPE *)lua_newuserdata(L, sizeof(VCTR_REC_TYPE));
  return_if_malloc_failed(ptr_v);
  memset(ptr_v, '\0', sizeof(VCTR_REC_TYPE));
  luaL_getmetatable(L, "Vector"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  qtype = F4; // TODO HARD COODED
  status = vctr_add1(qtype, chunk_size, &(ptr_v->uqid)); cBYE(status);

  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}

//-----------------------
static const struct luaL_Reg vector_methods[] = {
    { "__gc",    l_vctr_free   },
    { "chk", l_vctr_chk },

    { "free", l_vctr_free },
    { "delete", l_vctr_delete },
    //--------------------------------
    { "is_eov", l_vctr_is_eov },
    { "nop", l_vctr_nop },
    //--------------------------------
    { "set_name", l_vctr_set_name },
    { "get_name", l_vctr_get_name },
    //--------------------------------
    { "num_elements", l_vctr_num_elements },
    // creation, new, ...
    { "add1", l_vctr_add1 },
    //--------------------------------
    { "put", l_vctr_put },
    { "put_chunk", l_vctr_put_chunk },
    //--------------------------------
    { NULL,          NULL               },
};
 
static const struct luaL_Reg vector_functions[] = {
    { "chk", l_vctr_chk },

    { "free", l_vctr_free },
    { "delete", l_vctr_delete },
    //--------------------------------
    { "is_eov", l_vctr_is_eov },
    { "nop", l_vctr_nop },
    //--------------------------------
    { "set_name", l_vctr_set_name },
    { "get_name", l_vctr_get_name },
    //--------------------------------
    { "num_elements", l_vctr_num_elements },
    // creation, new, ...
    { "add1", l_vctr_add1 },
    //--------------------------------
    { "put", l_vctr_put },
    { "put_chunk", l_vctr_put_chunk },
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

