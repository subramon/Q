// The original inspiration for this was to replace Penlight
// While a wonderful library, I did not want to depend on Penlight
// for run time. For testing, it is just fine to use Penlight.
// Hence, some of the names use here are from Penlight. 
#define LUA_LIB

#include <fcntl.h>
#include <dirent.h>
#include <libgen.h>
#include <sys/stat.h>
#include <stdint.h>
#include "q_incs.h"

#include "luaconf.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_instantiate.h"

#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_instantiate.h"

#include "import_tbsp.h"
#include "vctr_name_to_uqid.h"


#undef MAIN_PGMN
#include "qjit_globals.h"

int luaopen_liblgutils (lua_State *L);

static int l_lgutils_save_session( 
    lua_State *L
    )
{
  int status = 0;
  int tbsp = 0; // you can freeze only primary tablespace
  status = g_vctr_hmap[tbsp].freeze(&g_vctr_hmap[tbsp], g_meta_dir_root, 
      "_vctr_meta.csv", "_vctr_bkts.bin", "_vctr_full.bin"); 
  cBYE(status);
  status = g_chnk_hmap[tbsp].freeze(&g_chnk_hmap[tbsp], g_meta_dir_root, 
      "_chnk_meta.csv", "_chnk_bkts.bin", "_chnk_full.bin"); 
  cBYE(status);
  lua_pushboolean(L, true); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}

static int l_lgutils_name_to_uqid(
    lua_State *L
    )
{
  int status = 0;
  if ( lua_gettop(L) != 2 ) { go_BYE(-1); }
  uint32_t tbsp = luaL_checknumber(L, 1); 
  const char * const name = luaL_checkstring(L, 2); 
  uint32_t vctr_uqid = 0;
  bool found = false; 
  status = vctr_name_to_uqid(tbsp, name, &vctr_uqid, &found); cBYE(status);
  lua_pushnumber(L, vctr_uqid);
  lua_pushnumber(L, found);
  return 2; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}

//----------------------------------------
static int l_lgutils_dsk_used( 
    lua_State *L
    )
{
  int status = 0;
  if ( lua_gettop(L) != 0 ) { go_BYE(-1); }
  lua_pushnumber(L, g_dsk_used); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_decr_mem_used( 
    lua_State *L
    )
{
  int status = 0;
  if ( lua_gettop(L) != 1 ) { go_BYE(-1); }
  double num = luaL_checknumber(L, 1); 
  if ( num < 0 ) { go_BYE(-1); } 
  __atomic_sub_fetch(&g_mem_used, num, 0);
  lua_pushnumber(L, g_mem_used); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_incr_mem_used( 
    lua_State *L
    )
{
  int status = 0;
  if ( lua_gettop(L) != 1 ) { go_BYE(-1); }
  double num = luaL_checknumber(L, 1); 
  if ( num < 0 ) { go_BYE(-1); } 
  __atomic_add_fetch(&g_mem_used, num, 0);
  lua_pushnumber(L, g_mem_used); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_mem_used( 
    lua_State *L
    )
{
  int status = 0;
  if ( lua_gettop(L) != 0 ) { go_BYE(-1); }
  lua_pushnumber(L, g_mem_used); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_is_restore_session( 
    lua_State *L
    )
{
  int status = 0;
  if ( lua_gettop(L) != 0 ) { go_BYE(-1); }
  lua_pushboolean(L, g_restore_session); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_meta_dir( 
    lua_State *L
    )
{
  int status = 0;
  if ( lua_gettop(L) != 0 ) { go_BYE(-1); } 
  lua_pushstring(L, g_meta_dir_root); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_import_tbsp( 
    lua_State *L
    )
{
  int status = 0;
  int tbsp = -1;
  if ( lua_gettop(L) != 3 ) {  go_BYE(-1); } 
  if ( !lua_isstring(L, 1) ) { go_BYE(-1); } 
  if ( !lua_isstring(L, 2) ) { go_BYE(-1); } 
  if ( !lua_isstring(L, 3) ) { go_BYE(-1); } 
  const char * const tbsp_name = luaL_checkstring(L, 1); 
  const char * const meta_dir  = luaL_checkstring(L, 2); 
  const char * const data_dir  = luaL_checkstring(L, 3); 
  status = import_tbsp(tbsp_name, meta_dir, data_dir, &tbsp);  cBYE(status);
  if ( tbsp <= 0 ) { go_BYE(-1); } 
  lua_pushnumber(L, tbsp);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_data_dir( 
    lua_State *L
    )
{
  int status = 0;
  int tbsp;
  if ( lua_gettop(L) == 0 ) { 
    tbsp = 0;
  }
  else if ( lua_gettop(L) == 1 ) { 
    if ( !lua_isnumber(L, 1) ) { go_BYE(-1); } 
    tbsp = luaL_checknumber(L, 1); 
  }
  else {
    go_BYE(-1);
  }
  lua_pushstring(L, g_data_dir_root[tbsp]); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
static int l_lgutils_tbsp_name( 
    lua_State *L
    )
{
  int status = 0;
  int tbsp;
  if ( lua_gettop(L) == 0 ) { 
    tbsp = 0;
  }
  else if ( lua_gettop(L) == 1 ) { 
    if ( !lua_isnumber(L, 1) ) { go_BYE(-1); } 
    tbsp = luaL_checknumber(L, 1); 
  }
  else {
    go_BYE(-1);
  }
  lua_pushstring(L, g_tbsp_name[tbsp]); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3; 
}
//----------------------------------------
//----------------------------------------
static const struct luaL_Reg lgutils_methods[] = {
    { "import_tbsp", l_lgutils_import_tbsp },
    { "is_restore_session", l_lgutils_is_restore_session },
    { "mem_used", l_lgutils_mem_used },
    { "incr_mem_used", l_lgutils_incr_mem_used },
    { "decr_mem_used", l_lgutils_decr_mem_used },
    { "dsk_used", l_lgutils_dsk_used },
    { "tbsp_name",           l_lgutils_tbsp_name },
    { "data_dir",           l_lgutils_data_dir },
    { "meta_dir",           l_lgutils_meta_dir },
    { "save_session",       l_lgutils_save_session },
    { "vctr_name_to_uqid", l_lgutils_name_to_uqid },
    { NULL,  NULL         }
};
 
static const struct luaL_Reg lgutils_functions[] = {
    { "import_tbsp", l_lgutils_import_tbsp },
    { "is_restore_session", l_lgutils_is_restore_session },
    { "mem_used", l_lgutils_mem_used },
    { "incr_mem_used", l_lgutils_incr_mem_used },
    { "decr_mem_used", l_lgutils_decr_mem_used },
    { "dsk_used", l_lgutils_dsk_used },
    { "tbsp_name",           l_lgutils_tbsp_name },
    { "data_dir",           l_lgutils_data_dir },
    { "meta_dir",           l_lgutils_meta_dir },
    { "save_session",       l_lgutils_save_session },
    { "vctr_name_to_uqid", l_lgutils_name_to_uqid },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/
int luaopen_liblgutils (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "lgutils");
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
  luaL_register(L, NULL, lgutils_methods);

  /* Register lgutils in types table */
  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/register_type'");
  if (status != 0 ) {
    printf("Running require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  } 
  luaL_getmetatable(L, "lgutils");
  lua_pushstring(L, "lgutils");
  status =  lua_pcall(L, 2, 0, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering type failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  /* Register the object.func functions into the table that is at the
   op of the stack. */
  
  // Registering with Q
  status = luaL_dostring(L, "return require('Q/q_export').export");
  if (status != 0 ) {
    printf("Running Q registration require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  }
  lua_pushstring(L, "lgutils");
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, lgutils_functions);
  status = lua_pcall(L, 2, 1, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering with q_export failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  
  return 1;
}
#ifdef OLD
  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, lgutils_functions);

  return 1;
#endif
