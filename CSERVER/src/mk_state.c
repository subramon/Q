#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "q_macros.h"
#include "q_server_struct.h"
#include "mk_state.h"

int
mk_state(
    q_server_t **ptr_q_server
    )
{
  int status = 0; 
  q_server_t *q_server = NULL;
  const char * const lua_fn = "mk_config";

  q_server = malloc(1 * sizeof(q_server_t));
  memset(q_server, 0,  (1 * sizeof(q_server_t)));

  lua_State *L = NULL;  int chk;
  // create Lua state
  L = luaL_newstate();
  if ( L == NULL ) { go_BYE(-1); }
  luaL_openlibs(L);
  // Initialize Lua State with  server stuff
  status = luaL_dostring(L, "require 'Q/CSERVER/src/lua/init'");
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }
  q_server->L = L;
  //------------------------------------
  chk = lua_gettop(L); if ( chk != 0 ) { go_BYE(-1); }
  lua_getglobal(L, lua_fn);
  chk = lua_gettop(L); if ( chk != 1 ) { go_BYE(-1); }
  if ( !lua_isfunction(L, -1)) {
    fprintf(stderr, "Lua Function %s undefined\n", lua_fn);
    lua_pop(L, 1);
    go_BYE(-1);
  }
  //--------------------------------
  lua_pushlightuserdata(L, q_server);
  chk = lua_gettop(L); if ( chk != 2 ) { go_BYE(-1); }
  //--------------------------------
  status = lua_pcall(L, 1, 0, 0); 
  if ( status != 0 ) { 
    fprintf(stderr, "ERROR: %s : %s\n", lua_fn, lua_tostring(L, -1));
    lua_pop(L, 1);
  }
  cBYE(status);
  chk = lua_gettop(L); if ( chk != 0 ) { go_BYE(-1); }
  //--------------------------------
  q_server->body = malloc(q_server->sz_body);
  return_if_malloc_failed(q_server->body);
  q_server->rslt = malloc(q_server->sz_rslt);
  return_if_malloc_failed(q_server->rslt);
  //--------------------------------
  // Set environment variables using informatiion from q_server
  char buf[32];
  setenv("Q_SRC_ROOT", q_server->q_src_root, 1); 
  setenv("Q_ROOT", q_server->q_root, 1); 
  setenv("Q_DATA_DIR", q_server->q_data_dir, 1); 
  sprintf(buf, "%d", q_server->chunk_size);
  setenv("CHUNK_SIZE", buf, 1);
  //--------------------------------
  // Initialize Lua State with Q 
  status = luaL_dostring(L, "Q = require 'Q'");
  if ( status != 0 ) { 
    fprintf(stderr, "Error luaL_string=%s\n", lua_tostring(L,-1));
  }
  cBYE(status); 

  *ptr_q_server = q_server;
BYE:
  return status;
}
