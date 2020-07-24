#ifndef __Q_SERVER_STRUCT_H
#define __Q_SERVER_STRUCT_H
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
typedef struct _q_server_t { 
  struct event_base *base;
  char *body; // [sz_body] 
  int sz_body;
  char *rslt; // [sz_body] 
  int sz_rslt;
  int port;
  //------------------
  lua_State *L;
  //------------------
  char *q_src_root;
  char *q_root; 
  char *qc_flags;
  char *q_data_dir; 
  int chunk_size;
} q_server_t;
#endif
