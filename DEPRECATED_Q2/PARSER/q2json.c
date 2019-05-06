#include "macros.h"
#include <stdint.h>
#include <inttypes.h>
#include "q2json.h"
#include "parse_consts.h"
#include "lex.yy.c"

extern char *g_err; 
// START FUNC DECL
int 
q2json(
    char *in
    )
// START FUNC DECL
{
  int status = 0;
  // YY_BUFFER_STATE b = NULL;
  // b->yy_input_file = NULL;
  // b->yy_ch_buf     = NULL;
  // b->yy_buf_pos    = NULL;

  if ( ( in == NULL ) || ( *in == '\0' ) ) { 
    sprintf(g_err, "Null input\n"); go_BYE(-1); 
  }
  int too_long = 0, len = 0;
  for ( char *cptr = in; *cptr != '\0'; cptr++, len++ ) {
    if ( len >= MAX_LEN_Q_COMMAND ) {
      too_long = 1;
      break;
    }
  }
  if ( too_long == 1 ) {
    sprintf(g_err, "Q Command too long. FIshy... \n"); go_BYE(-1); 
  }

  // fprintf(stderr, "About to parse %s \n", in);
  yy_scan_string(in);
  status = yyparse(); cBYE(status);
  yylex_destroy();
  // yy_delete_buffer(b);
BYE:
  return status;
}
