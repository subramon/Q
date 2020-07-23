#ifndef __Q_SERVER_STRUCT_H
#define __Q_SERVER_STRUCT_H
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
typedef struct _q_server_t { 
  lua_State *L;
  char *body; // [sz_body] 
  int sz_body;
  char *rslt; // [sz_body] 
  int sz_rslt;
} q_server_t;
#endif
