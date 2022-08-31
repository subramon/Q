#include "q_incs.h" 
#include <lua.h>
#include <lauxlib.h>
#include <pthread.h>
#include "web_struct.h" 
#include "rs_mmap.h" 
#include "process_req.h" 

extern int g_webserver_interested;
extern int g_L_status;
extern int g_halt;
extern lua_State *L; 
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
  if ( W == NULL ) { go_BYE(-1); }
  int itmp, expected, desired; bool rslt;
  char *X = NULL; size_t nX = 0;

  // If master calls halt, get out 
  if ( g_halt == 1 ) { 
    strcpy(outbuf, "{ \"Halt\" : \"OK\" }");
    goto BYE;
  }
  //-----------------------------------------
  switch ( req_type ) {
    case Undefined :
      go_BYE(-1);
      break;
      //----------fd_out
    case Ignore :  
      sprintf(outbuf, "{ \"%s\" : \"OK\" }", api);
      break;
      //--------------------------------------------------------
    case Lua :  
      {
        // indicate interest 
        itmp = 1; __atomic_store(&g_webserver_interested, &itmp, 0);
        printf("Slave: Acquiring Lua state \n");
        // acquire Lua state
        for ( ; ; ) { 
          expected = 0; desired = 2;
          rslt = __atomic_compare_exchange(
              &g_L_status, &expected, &desired, false, 0, 0);
          if ( rslt ) { break; }
          // take a short nap for 10 ms
          struct timespec tmspec = {.tv_sec = 0, .tv_nsec = 10 * 1000000};
          nanosleep(&tmspec, NULL);
        }
        printf("Slave: Acquired Lua state\n");
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
        status = luaL_dostring(L, args);
        if ( status != 0 ) { 
          fprintf(stderr, "Error executing [%s]\n", args);
        }
        // Close opened files 
        dup2(saved_stdout, STDOUT_FILENO);
        close(saved_stdout);
        close(fd_out);

        dup2(saved_stderr, STDERR_FILENO);
        close(saved_stderr);
        close(fd_err);
        if ( status == 0 ) { 
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
        // release state 
        expected = 2; desired = 0;
        rslt = __atomic_compare_exchange(
            &g_L_status, &expected, &desired, false, 0, 0);
        if ( !rslt ) { go_BYE(-1); }
        // indicate lack of interest 
        itmp = 0; __atomic_store(&g_webserver_interested, &itmp, 0);
        printf("Slave: Relinquished Lua state\n");
        break;
      }
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
  return status ;
}
