#include "q_incs.h" 
#include "web_struct.h" 
#include "process_req.h" 

extern int g_webserver_interested;
extern int g_L_status;
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
    case Execute :  
      {
        // indicate interest 
        itmp = 1; __atomic_store(&g_webserver_interested, &itmp, 0);
        // acquire Lua state
        for ( ; ; ) { 
          expected = 0; desired = 2;
          rslt = __atomic_compare_exchange(
              &g_L_status, &expected, &desired, false, 0, 0);
          if ( rslt ) { break; }
          // take a short nap for 1 ms
          struct timespec tmspec = {.tv_sec = 0, .tv_nsec = 1 * 1000000};
          nanosleep(&tmspec, NULL);
        }
        printf("Webserver got Lua state\n");
        // Do what you need to do 
        sprintf(outbuf, "{ \"%s\" : \"OK\" }", args);
        // release state 
        expected = 2; desired = 0;
        rslt = __atomic_compare_exchange(
            &g_L_status, &expected, &desired, false, 0, 0);
        if ( !rslt ) { go_BYE(-1); }
        // indicate lack of interest 
        itmp = 0; __atomic_store(&g_webserver_interested, &itmp, 0);
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
  return status ;
}
