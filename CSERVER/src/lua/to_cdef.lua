local ffi = require 'ffi'
ffi.cdef[[
extern void *malloc(size_t size);
typedef struct lua_State lua_State;
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
]]
