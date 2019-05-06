// Global State that persists across invocations
#include "q_incs.h"
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <pthread.h>

bool g_halt; // For multi-threading
//-----------------------------------------------------------------

char g_body[Q_MAX_LEN_BODY+1];
int g_sz_body;

char g_valid_chars_in_url[256]; 

// Environment variables
char g_q_data_dir[Q_MAX_LEN_FILE_NAME+1];
char g_q_metadata_file[Q_MAX_LEN_FILE_NAME+1];
char g_qc_flags[Q_MAX_LEN_FLAGS]; 
char g_link_flags[Q_MAX_LEN_FLAGS]; 
char g_ld_library_path[Q_MAX_LEN_PATH+1];
// TODO: do we require below globals?
char g_q_src_root[Q_MAX_LEN_FILE_NAME+1];
char g_q_root[Q_MAX_LEN_FILE_NAME+1];
char g_q_trace_dir[Q_MAX_LEN_FILE_NAME+1];
char g_q_build_dir[Q_MAX_LEN_FILE_NAME+1];
char g_lua_path[Q_MAX_LEN_PATH+1];
//------------------------ For Lua
lua_State *g_L_Q; 

