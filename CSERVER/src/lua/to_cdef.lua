local ffi = require 'ffi'
ffi.cdef[[
extern void *malloc(size_t size);
typedef struct lua_State lua_State;

typedef struct _config_t { 
  int port;
  char *qc_flags;
  char *q_data_dir; 
} config_t;
typedef struct _q_server_t { 
  lua_State *L;
  char *body; // [sz_body] 
  int sz_body;
  char *rslt; // [sz_body] 
  int sz_rslt;
} q_server_t;
]]
