#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "q_incs.h"
#include "init.h"
#include "auxil.h"
extern lua_State *g_L_Q; 
extern bool g_halt; 

extern char g_valid_chars_in_url[256]; 

extern char g_q_data_dir[Q_MAX_LEN_FILE_NAME+1]; 
extern char g_q_metadata_file[Q_MAX_LEN_FILE_NAME+1]; 
extern char g_qc_flags[Q_MAX_LEN_FLAGS+1]; 
extern char g_link_flags[Q_MAX_LEN_FLAGS+1]; 
extern char g_ld_library_path[Q_MAX_LEN_PATH+1]; 

void
free_globals(
    void
    )
{
  if ( g_L_Q != NULL ) { lua_close(g_L_Q); g_L_Q = NULL; }
}

void
zero_globals(
    void
    )
{
  g_halt = false;

  memset(g_q_data_dir,  '\0', Q_MAX_LEN_FILE_NAME+1);
  memset(g_q_metadata_file, '\0', Q_MAX_LEN_FILE_NAME+1);
  memset(g_qc_flags, '\0', Q_MAX_LEN_FLAGS+1);
  memset(g_link_flags, '\0', Q_MAX_LEN_FLAGS+1);
  memset(g_ld_library_path, '\0', Q_MAX_LEN_PATH+1);

  //------------
  const char *str = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ=/_:.";
  /* Note that I added period to allow FileNames to be passed as args */
  /* Not sure if that is good practice */
  memset(g_valid_chars_in_url, '\0', 256);
  for ( char *cptr = (char *)str; *cptr != '\0'; cptr++ ) {
    g_valid_chars_in_url[(uint8_t)(*cptr)] = true;
  }

}

int
init_lua(
    void
    )
{
  int status = 0;
  g_L_Q = luaL_newstate(); if ( g_L_Q == NULL ) { go_BYE(-1); }
  luaL_openlibs(g_L_Q);  

  status = luaL_dostring(g_L_Q, "Q = require 'Q'; ");
  mcr_chk_lua_rslt(status);
  if ( ( g_q_metadata_file != NULL ) && ( *g_q_metadata_file != '\0' ) ) {
    status = luaL_dostring(g_L_Q, "Q.restore()");
    mcr_chk_lua_rslt(status);
  }

BYE:
  return status;
}
