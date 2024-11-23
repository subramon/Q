#include "q_incs.h"
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "q_config.h"

#include "qjit_globals.h"
#include "read_configs.h"

int
read_configs(
    void
    )
{
  int status = 0;
  lua_State *L = NULL;
  q_config_t C; memset(&C, 0, sizeof(q_config_t));
  const char * const lua_fn = "rdfn";
  char cmd[128]; uint32_t sz = sizeof(cmd); memset(cmd, 0, sz);
  int tbsp = 0; // we read configs only for default table space
  char *real_data_dir_root = NULL;

  L = luaL_newstate();
  if ( L == NULL ) { go_BYE(-1); }
  luaL_openlibs(L);

  // Note that T is a global in the Lua state 
  if ( ( g_q_config != NULL ) && ( *g_q_config != '\0' ) ) { 
    if ( (strlen(g_q_config) + 24 ) > sz ) { go_BYE(-1); }
    sprintf(cmd, "tmp = loadfile(\"%s\")", g_q_config); 
    status = luaL_dostring(L, cmd); 
    if ( status != 0 ) { 
      fprintf(stderr, "Error executing [%s]: luaL_string=%s\n", 
          cmd, lua_tostring(L,-1));
    }
    sprintf(cmd, "T = tmp()"); 
    status = luaL_dostring(L, cmd); 
    if ( status != 0 ) { 
      fprintf(stderr, "Error executing [%s]: luaL_string=%s\n", 
          cmd, lua_tostring(L,-1));
    }
  }
  else {
    status = luaL_dostring(L, "T = require 'q_config'");
    if ( status != 0 ) { 
      fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
    }
  }
  status = luaL_dostring(L, "assert(type(T) == 'table')");
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }
  cBYE(status); 
  //-----------------------------------------------------
  snprintf(cmd, sz-1, 
      "%s = require 'Q/QJIT/GUTILS/lua/read_configs'", lua_fn);
  status = luaL_dostring(L, cmd);
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }

  snprintf(cmd, sz-1, "assert(type(%s) == 'function')", lua_fn);
  status = luaL_dostring(L, cmd);
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }
  cBYE(status); 
  //-----------------------------------------------------
  // Put lua read_configs function on stack 
  int chk = lua_gettop(L); if ( chk != 0 ) { go_BYE(-1); }
  lua_getglobal(L, lua_fn);
  chk = lua_gettop(L); if ( chk != 1 ) { go_BYE(-1); }
  if ( !lua_isfunction(L, -1)) {
    fprintf(stderr, "Lua Function [%s] undefined\n", lua_fn);
    lua_pop(L, 1);
    go_BYE(-1);
  }
  // put config file and pointer to C struct config on stack 
  lua_pushlightuserdata(L, &C);
  chk = lua_gettop(L); if ( chk != 2 ) { go_BYE(-1); }
  // call lua function and check status 
  status = lua_pcall(L, 1, 1, 0);
  if ( status != 0 ) {
    fprintf(stderr, "fn %s failed: %s\n", lua_fn, lua_tostring(L, -1));
    lua_pop(L, 1);
    go_BYE(-1); 
  }
  // check return value which should be true 
  chk = lua_gettop(L); if ( chk != 1 ) { go_BYE(-1); }
  if ( !lua_isboolean(L, 1) ) {
    bool rslt = lua_toboolean(L, -1);
    if ( !rslt ) { go_BYE(-1); }
  }
  // clean up lua stack 
  lua_pop(L, 1);
  chk = lua_gettop(L); if ( chk != 0 ) { go_BYE(-1); }
  // clean up globals 
  status = luaL_dostring(L, "T = nil"); 
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }
  //-----------------------------------------------------
  // START: This is ugly to have to copy out of struct TODO P4
  g_restore_session = C.restore_session;
  g_is_webserver    = C.is_webserver;
  g_is_out_of_band  = C.is_out_of_band;

  printf("g_restore_session = %s \n", g_restore_session ? "true" : "false");
  if ( g_restore_session ) { 
   if ( !isdir(C.data_dir_root, NULL) ) { go_BYE(-1); }
   if ( !isdir(C.meta_dir_root, NULL) ) { go_BYE(-1); }
  }
  else {
    // Following should be dine in init_session
    // But I need realpath to work, so I do it here
    // clean out out data 
    if ( isdir(C.data_dir_root, NULL) ) { 
      status = rmtree(C,data_dir_root); 
    }
    if ( isdir(C.data_dir_root, NULL) ) { 
      status = rmtree(C,data_dir_root); 
    }
    //---------------------------
    status = mkdir(C.data_dir_root, 0744); cBYE(status);
    status = mkdir(C.meta_dir_root, 0744); cBYE(status);
    //---------------------------
    if ( !isdir(C.data_dir_root, NULL) ) { go_BYE(-1); }
    if ( !isdir(C.meta_dir_root, NULL) ) { go_BYE(-1); }
    //---------------------------
  }
  
  real_data_dir_root = realpath(C.data_dir_root, NULL);
  if ( real_data_dir_root == NULL ) { 
    fprintf(stderr, "C.data_dir_root = %s \n", C.data_dir_root);
    go_BYE(-1); 
  } 
  g_data_dir_root[tbsp] = strdup(real_data_dir_root);

  if ( strlen(C.meta_dir_root) >= Q_MAX_LEN_DIR_NAME ) { go_BYE(-1); } 
  strcpy(g_meta_dir_root, C.meta_dir_root); // allocated in init_globals

  g_mem_allowed = C.mem_allowed * 1024 * 1048576; // convert GBytes to bytes
  g_dsk_allowed = C.dsk_allowed * 1024 * 1048576; // convert GBytes to bytes

  g_web_info.port         = C.web_port;
  g_out_of_band_info.port = C.out_of_band_port;

  g_vctr_hmap_config.min_size = C.vctr_hmap_min_size;
  g_vctr_hmap_config.max_size = C.vctr_hmap_max_size;

  g_chnk_hmap_config.min_size = C.chnk_hmap_min_size;
  g_chnk_hmap_config.max_size = C.chnk_hmap_max_size;

  g_master_interested = C.initial_master_interested;
  // STOP : This is ugly to have to copy out of struct TODO P4

BYE:
  free_if_non_null(C.data_dir_root);
  free_if_non_null(C.meta_dir_root);
  free_if_non_null(real_data_dir_root);
  if ( L != NULL ) { lua_close(L);  }
  return status;
}
