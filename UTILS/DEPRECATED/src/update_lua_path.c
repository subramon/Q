#include "q_incs.h"
#include "q_macros.h"
#include "isfile.h"
#include "isdir.h"
#include "update_lua_path.h"
// This function pre-pends the specified directory to the beginning
// of the existing environment variable LUA_PATH and updates LUA_PATH
// Returns old LUA_PATH
int
update_lua_path(
    const char * const dir,  // directory to be added to path at beginning
    char **ptr_old_lua_path
    )
{
  int status = 0;
  char *config_file = NULL;
  char *new_lua_path = NULL;
  //--- Get and check old LUA_PATH
  char *old_lua_path = getenv("LUA_PATH");
  if ( ( old_lua_path == NULL ) || ( *old_lua_path == '\0' ) ) { 
    go_BYE(-1); 
  }
  int len = strlen(old_lua_path); if ( len <= 3 ) { go_BYE(-1); }
  if (( old_lua_path[len-1] == ';' ) && ( old_lua_path[len-2] == ';' )) {
    // all is well
  }
  else {
    fprintf(stderr, "LUA_PATH must end with [;;]\n"); go_BYE(-1);
  }
  //-----------------------------------------
  // Verify q_config.lua exists 
  if ( !isdir(dir) ) { 
    fprintf(stderr, "directory not found %s \n", dir); go_BYE(-1); 
  }
  len = strlen(dir) + strlen("/q_config.lua") + 16;
  config_file = malloc(len); 
  return_if_malloc_failed(config_file);
  sprintf(config_file, "%s/q_config.lua", dir);
  if ( !isfile(config_file) ) { go_BYE(-1); }
  //-----------------------------------------
  len = strlen(old_lua_path) + strlen(dir) + 16;
  new_lua_path = malloc(len);
  return_if_malloc_failed(new_lua_path);
  sprintf(new_lua_path, "%s/?.lua;%s", dir, old_lua_path);
  status = setenv("LUA_PATH", new_lua_path, 1); cBYE(status);
  *ptr_old_lua_path = strdup(old_lua_path); 
BYE:
  free_if_non_null(new_lua_path);
  free_if_non_null(config_file);
  return status;
}
