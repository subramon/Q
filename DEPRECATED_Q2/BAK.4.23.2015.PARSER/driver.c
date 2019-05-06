#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <inttypes.h>
#include <stdlib.h>
#include "constants.h"
#include "macros.h"
#include "mmap.h"
#include <sys/mman.h>
#include "q2json.h"
#include "parse_consts.h"

char *g_op  ; // [MAX_LEN_PARSED_JSON+1];
char *g_in  ; // [MAX_LEN_Q_COMMAND+1];
char *g_buf ; // [MAX_LEN_PARSED_JSON+1];

int 
main(
    int argc,
    char **argv
    ) 
{
  int status = 0;
  int read_from_file = FALSE;
  FILE *ifp = NULL;

  g_op  = NULL; // [MAX_LEN_PARSED_JSON+1];
  g_in  = NULL; // [MAX_LEN_Q_COMMAND+1];
  g_buf = NULL; // [MAX_LEN_PARSED_JSON+1];

/* Once you have compiled the program with trace facilities, the way 
to request a trace is to store a nonzero value in the variable yydebug. 
You can do this by making the C code do it (in main, perhaps), or you 
can alter the value with a C debugger. 
 */
  if ( argc != 3 ) { go_BYE(-1); }
  char *infile = argv[1];
  char *opfile = argv[2];

  g_op  = malloc(MAX_LEN_PARSED_JSON+1);
  return_if_malloc_failed(g_op);
  g_in  = malloc(MAX_LEN_Q_COMMAND+1);
  return_if_malloc_failed(g_in);
  g_buf = malloc(MAX_LEN_PARSED_JSON+1);
  return_if_malloc_failed(g_buf);

  for ( int i = 0; i < MAX_LEN_PARSED_JSON+1; i++ ) { g_op[i]  = '\0'; }
  for ( int i = 0; i < MAX_LEN_PARSED_JSON+1; i++ ) { g_buf[i] = '\0'; }
  for ( int i = 0; i < MAX_LEN_Q_COMMAND  +1; i++ ) { g_in[i]  = '\0'; }

  ifp = fopen(infile, "r");
  return_if_fopen_failed(ifp, infile, "r");
  for ( ; ; ) { 
    char *cptr = fgets(g_in, MAX_LEN_Q_COMMAND, ifp);
    if ( cptr == NULL ) { break; }
    if ( ( *g_in == '\0' ) || ( *g_in == '\n' ) ) { continue; }
    printf("INPUT  to parser = %s \n", g_in);
    status = q2json(g_in, g_op, MAX_LEN_PARSED_JSON); cBYE(status);
    printf("Output of parser = %s \n", g_op);
    for ( char *xptr = g_in;  *xptr != '\0'; xptr++ ) { *xptr = '\0'; }
    for ( char *xptr = g_op;  *xptr != '\0'; xptr++ ) { *xptr = '\0'; }
    for ( char *xptr = g_buf; *xptr != '\0'; xptr++ ) { *xptr = '\0'; }
  }
BYE:
  fclose_if_non_null(ifp);
  free_if_non_null(g_op);
  free_if_non_null(g_in);
  free_if_non_null(g_buf);
  return status;
}
