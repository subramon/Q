#include "q_incs.h" 
#include <lua.h>
#include <lauxlib.h>
#include <pthread.h>
#include "web_struct.h" 
#include "get_file_size.h" 
#include "process_req.h" 
#include "mod_mem_used.h" 
#include "extract_name_value.h" 
#include "lua_state.h" 

extern int g_master_halt;
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
    web_response_t *ptr_web_response
    )
{
  int status = 0;
  int lua_status = 0;
  if ( W == NULL ) { go_BYE(-1); }
  char *out_file = NULL, *err_file = NULL; 

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
    case Favicon :  
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
        // Redirect stdout 
        const char * const out_tmpl = "/tmp/_qjit_stdout_XXXXXX";
        out_file = strdup(out_tmpl); 
        int fd_out =  mkstemp(out_file); if ( fd_out < 0 ) { go_BYE(-1);}
        close(fd_out); 
        int saved_stdout = dup(STDOUT_FILENO);
        fd_out = open(out_file, O_WRONLY, 0666);
        dup2(fd_out, STDOUT_FILENO); 
        // Redirect stderr
        const char * const err_tmpl = "/tmp/_qjit_stderr_XXXXXX";
        err_file = strdup(err_tmpl); 
        int fd_err =  mkstemp(err_file); if ( fd_err < 0 ) { go_BYE(-1);}
        close(fd_err); 
        int saved_stderr = dup(STDERR_FILENO);
        fd_err = open(err_file, O_WRONLY, 0666);
        dup2(fd_err, STDERR_FILENO);
        // Do what you need to do 
        if ( body == NULL ) { 
          lua_status = luaL_dostring(L, args);
        }
        else {
          lua_status = luaL_dostring(L, body);
        }
        if ( lua_status != 0 ) { 
          if ( body == NULL ) { 
          fprintf(stderr, "Error executing [%s]\n", args);
          }
          else {
          fprintf(stderr, "Error executing [%s]\n", body);
          }
        }
        // Close opened files 
        dup2(saved_stdout, STDOUT_FILENO);
        close(saved_stdout);
        close(fd_out);

        dup2(saved_stderr, STDERR_FILENO);
        close(saved_stderr);
        close(fd_err);

        ptr_web_response->is_set = true;
        if ( lua_status == 0 ) { 
          ptr_web_response->is_err = false;
          // return out file and delete err file 
          ptr_web_response->file_name = out_file; 
          unlink(err_file);
          free_if_non_null(err_file);
        }
        else { 
          ptr_web_response->is_err = true;
          // return err  and delete out file 
          ptr_web_response->file_name = err_file; 
          unlink(out_file);
          free_if_non_null(out_file);
        }
        int64_t out_size = get_file_size(ptr_web_response->file_name);
        if ( out_size == 0 ) {
          unlink(ptr_web_response->file_name);
          free_if_non_null(ptr_web_response->file_name);
          ptr_web_response->is_set = false;
        }
        else {
          ptr_web_response->num_headers =  2;
          ptr_web_response->header_key = malloc(2 * sizeof(char *));
          ptr_web_response->header_val = malloc(2 * sizeof(char *));
          ptr_web_response->header_key[0] = strdup("Content-Length");
          char buf[32]; sprintf(buf, "%" PRIi64 "", out_size);
          ptr_web_response->header_val[0] = strdup(buf); 

          // TODO P2 This needs to improve
          ptr_web_response->header_key[1] = strdup("Content-Type");
          ptr_web_response->header_val[1] = 
            strdup("text/html; charset=UTF-8");
        }

        // Does the order of these 2 operations matter? No.
        // The "interested" variable is just a guidance to the master
        // to sleep for a bit and give the webserver a chance to "ghiss" in
        // webserver indicates lack of interest 
        itmp = 0; __atomic_store(&g_webserver_interested, &itmp, 0);
        // release state 
        status = release_lua_state(2); // 2 => webserver
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
    case HaltMaster :  
      {
      int itmp = 1; __atomic_store(&g_master_halt, &itmp, 0);
      sprintf(outbuf, "{ \"%s\" : \"OK\" }", api);
      }
      break;
      //--------------------------------------------------------
    default :
      go_BYE(-1);
      break;
  }
BYE:
  if ( req_type == Lua ) { status = lua_status; }
  return status ;
}
