#include "q_incs.h"
#include <evhttp.h>
#include <pthread.h>
#include "handler.h"
#include "web_struct.h"
#include "webserver.h"

// globals 
_Noreturn void *
webserver(
    void *arg
    )
{
  int status;
  if ( arg == NULL ) { go_BYE(-1); }
  web_info_t *web_info = (web_info_t *)arg;
  int port = web_info->port; 
  struct evhttp *httpd = NULL;
  struct event_base *base = NULL;
  if ( port <= 0 )  { go_BYE(-1); } 

  base = event_base_new();
  httpd = evhttp_new(base);
  evhttp_set_max_headers_size(httpd, 4096); // TODO P4 FIX 
  evhttp_set_max_body_size(httpd, 4096); // TODO P4 FIX 
  if ( web_info->is_out_of_band ) { 
    fprintf(stdout, "Out-of-band Server starting up\n");
  }
  else {
    fprintf(stdout, "Web Server starting up\n");
  }

  /* 
   *  Services will only receive packets from interfaces they listen to. You can commonly specify 0.0.0.0 as listen address in the service, to make it listen on all interfaces.
   *  https://askubuntu.com/questions/1136377/why-is-port-not-open-not-ufw-service-is-running
   *  */
  // Can talk to out of band server only from server where qjit is running
  if ( web_info->is_out_of_band ) { 
    status = evhttp_bind_socket(httpd, "127.0.0.1", port);
  }
  else {
    status = evhttp_bind_socket(httpd, "0.0.0.0", port);
  }
  if ( status < 0 ) {
    fprintf(stderr, "Port %d busy \n", port); go_BYE(-1);
  }
  //---------------------
  web_info->base = base;
  evhttp_set_gencb(httpd, handler, web_info);
  event_base_dispatch(base);
  evhttp_free(httpd);
  event_base_free(base);

BYE:
  fprintf(stdout, "Web Server terminating\n");
  pthread_exit(NULL);
}
