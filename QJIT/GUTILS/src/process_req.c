#include "q_incs.h" 
#include <lua.h>
#include <lauxlib.h>
#include <pthread.h>
#include "web_struct.h" 
#include "rs_mmap.h" 
#include "process_req.h" 
#include "mod_mem_used.h" 
#include "extract_name_value.h" 
#include "lua_state.h" 

extern int g_master_interested;
extern int g_webserver_interested;
extern int g_L_status;
extern lua_State *L;  // IMPORTANT: This comes from luajit.c 

int
process_req(
    req_type_t req_type,
    const char *const api,
    const char *args,
    const char *body,
    web_info_t *W,
    char *outbuf, // [sz_outbuf] 
    size_t sz_outbuf,
    char *errbuf, // [sz_outbuf] 
    size_t sz_errbuf,
    img_info_t *ptr_img_info
    )
{
  int status = 0;
  int lua_status = 0;
  if ( W == NULL ) { go_BYE(-1); }
  char *X = NULL; size_t nX = 0;

  //-----------------------------------------
  switch ( req_type ) {
    case Undefined :
      go_BYE(-1);
      break;
      //--------------------------------------------------------
    case Ignore :  
      sprintf(outbuf, "{ \"%s\" : \"OK\" }", api);
      break;
      //--------------------------------------------------------
    case SetDisk :  
      go_BYE(-1); // TODO P2 
      break;
      //--------------------------------------------------------
    case SetMemory :  
      go_BYE(-1); // TODO P2 
      break;
      //--------------------------------------------------------
    case SetMaster :  
      if ( W->is_out_of_band == false ) { go_BYE(-1); }
      {
        char buf[128]; memset(buf, 0, 128);
        status = extract_name_value(args, "Status=", '&', buf, 127); 
        cBYE(status);
        if ( ( strcasecmp(buf, "true") == 0 ) ||  ( strcasecmp(buf, "on") == 0 ) ) {
           int itmp = 1; __atomic_store(&g_master_interested, &itmp, 0);
        }
        else if ( ( strcasecmp(buf, "false") == 0 ) ||  ( strcasecmp(buf, "off") == 0 ) ) {
           int itmp = 0; __atomic_store(&g_master_interested, &itmp, 0);
        }
        else {
          go_BYE(-1);
        }
        sprintf(outbuf, "{ \"%s\" : \"OK\" }", api);
      } 
      break;
      //--------------------------------------------------------
    case Lua :  
      {
        // indicate interest 
        int itmp = 1; __atomic_store(&g_webserver_interested, &itmp, 0);
        status = acquire_lua_state(2); // 2 => webserver
        // Redirect stdout and stderr
        int len; 
        char out_file[128]; len = sizeof(out_file);memset(out_file, 0, len);
        strncpy(out_file, "/tmp/_qjit_stdout_XXXXXX", len-1);
        int fd_out =  mkstemp(out_file); if ( fd_out < 0 ) { go_BYE(-1);}
        close(fd_out); 

        char err_file[128]; len = sizeof(err_file);memset(err_file, 0, len);
        strncpy(err_file, "/tmp/_qjit_stderr_XXXXXX", len-1);
        int fd_err =  mkstemp(err_file); if ( fd_err < 0 ) { go_BYE(-1);}
        close(fd_err); 
        int saved_stdout = dup(STDOUT_FILENO);
        int saved_stderr = dup(STDERR_FILENO);
        fd_out = open(out_file, O_WRONLY, 0666);
        fd_err = open(err_file, O_WRONLY, 0666);
        dup2(fd_out, STDOUT_FILENO); 
        dup2(fd_err, STDERR_FILENO);

        // Do what you need to do 
        lua_status = luaL_dostring(L, args);
        if ( lua_status != 0 ) { 
          fprintf(stderr, "Error executing [%s]\n", args);
        }
        // Close opened files 
        dup2(saved_stdout, STDOUT_FILENO);
        close(saved_stdout);
        close(fd_out);

        dup2(saved_stderr, STDERR_FILENO);
        close(saved_stderr);
        close(fd_err);
        if ( lua_status == 0 ) { 
          status = rs_mmap(out_file, &X, &nX, 0); cBYE(status);
          size_t n = nX;
          if ( n > sz_outbuf ) { n = sz_outbuf; }
          strncpy(outbuf, X, n); 
          mcr_rs_munmap(X, nX); X = NULL; nX = 0;
        }
        else {
          status = rs_mmap(err_file, &X, &nX, 0); cBYE(status);
          size_t n = nX;
          if ( n > sz_errbuf ) { n = sz_errbuf; }
          strncpy(errbuf, X, n); 
          mcr_rs_munmap(X, nX); X = NULL; nX = 0;
        }
        // Delete temporary files 
        unlink(err_file);
        unlink(out_file);
        // TODO P1 Does the order of these 2 operations matter?
        // indicate lack of interest 
        itmp = 0; __atomic_store(&g_webserver_interested, &itmp, 0);
        // release state 
        status = release_lua_state(2); // 2 => slave
        break;
      }
      //--------------------------------------------------------
    case Memory :  
      {
        uint64_t l_mem_allowed = get_mem_allowed();
        uint64_t l_mem_used = get_mem_used();
        sprintf(outbuf, 
            "{ \"Allowed\" : %" PRIu64 ", "
            "     \"Used\" : %" PRIu64 "}",
            l_mem_allowed, l_mem_used);
      }
      break;
      //--------------------------------------------------------
    case Disk :  
      {
        uint64_t l_dsk_allowed = get_dsk_allowed();
        uint64_t l_dsk_used = get_dsk_used();
        sprintf(outbuf, 
            "{ \"Allowed\" : %" PRIu64 ", "
            "     \"Used\" : %" PRIu64 "}",
            l_dsk_allowed, l_dsk_used);
      }
      break;
      //--------------------------------------------------------
    case Halt :  
      sprintf(outbuf, "{ \"%s\" : \"OK\" }", api);
      break;
      //--------------------------------------------------------
    default :
      go_BYE(-1);
      break;
  }
BYE:
  if ( X != NULL ) { mcr_rs_munmap(X, nX); } 
  if ( req_type == Lua ) { status = lua_status; }
  return status ;
}
