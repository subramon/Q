#include "q_incs.h"
#include "rconnect.h"
#include <errno.h>
#include <arpa/inet.h>
#include <ctype.h>
#include <inttypes.h>
#include <linux/tcp.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

static int
get_buf_from_sock(
    int sock,
    char *buf,
    int buflen,
    int *ptr_num_read
    )
{
  int status = 0;
  if ( sock < 0 ) { go_BYE(-1); }
  if ( buflen < 0 ) { go_BYE(-1); }
  if ( buf == NULL ) { go_BYE(-1); }
  if ( buflen == 0 ) { WHEREAMI; return status; } // Nothing to do 

  int num_to_read = buflen;
  int total_num_read = 0;
  for ( ; ; ) { 
    int num_read = read(sock, buf, buflen);
    if ( num_read == 0 ) { return -2; } 
    /* zero indicates end of file. See 
     * https://man7.org/linux/man-pages/man2/read.2.html */
    if ( num_read < 0 ) { go_BYE(-3); } // server error 
    total_num_read += num_read;
    if ( total_num_read >= num_to_read ) { break; } // all done 
    buf    += num_read;
    buflen -= num_read;
  }
  if ( total_num_read != num_to_read ) { // TODO Assert?
    printf("WARNING! total_num_read, num_to_read = %d, %d \n", 
    total_num_read, num_to_read);
  }
  *ptr_num_read = total_num_read;
BYE:
  return status;
}
//-------------------------------------------------------------
int
rconnect(
    const char * const server, 
    int portnum, 
    int snd_timeout_sec,
    int rcv_timeout_sec,
    int *ptr_sock
    )
{
  int status = 0;
  int sock = 0;
  char hdr[32]; int num_read;
  struct sockaddr_in serv_addr; 
  memset(&serv_addr, 0, sizeof(struct sockaddr_in));

  if ( server == NULL ) { go_BYE(-1); } 
  if ( portnum <= 0 ) { go_BYE(-1); } 
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if ( sock < 0 ) { 
    printf("Socket creation error  %s %d\n", __FILE__, __LINE__); 
    status = -1; goto BYE;
  }
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(portnum);
  // Convert IPv4 and IPv6 addresses from text to binary form
  status = inet_pton(AF_INET, server, &serv_addr.sin_addr); cBYE(status);

  // Establish connection to socket
  status = connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr));
  cBYE(status);
#define CAN_TCP_NODELAY
#ifdef CAN_TCP_NODELAY
  int flag = 1;
  int result = setsockopt(sock,            /* socket affected */
      IPPROTO_TCP,     /* set option at TCP level */
      TCP_NODELAY,     /* name of option */
      (char *) &flag,  /* the cast is historical cruft */
      sizeof(int));    /* length of option value */
  if ( result < 0 )  { go_BYE(-1); }
#endif
  // set timeouts for receiving
  if ( rcv_timeout_sec > 0 ) { 
    struct timeval timeout = { .tv_sec = rcv_timeout_sec };
    status = setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout,
                sizeof(timeout));
    cBYE(status);
  }
  // set timeouts for sending 
  if ( snd_timeout_sec > 0 ) { 
    struct timeval timeout = { .tv_sec = snd_timeout_sec };
    status = setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &timeout,
                sizeof(timeout));
    cBYE(status);
  }
  memset(hdr, 0, 32);
  status = get_buf_from_sock(sock, hdr, 32, &num_read); cBYE(status);
  /* After connection is established, the server sends 32 bytes 
   * representing the ID-string defining the capabilities of the server. 
   * */
  if ( num_read != 32 ) { go_BYE(-1); }
  if ( strncmp(hdr, "Rsrv0103QAP1", strlen("Rsrv0103QAP1")) != 0 ) {
    go_BYE(-1);
  }
  *ptr_sock = sock;
BYE:
  if ( status < 0 ) { 
    fprintf(stderr, "Unable to connect to [%s] on %d \n", server, portnum);
  }
  return status;
}
