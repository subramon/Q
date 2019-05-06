#include "macros.h"
#include "q2json.h"
#include "lex.yy.c"

// START FUNC DECL
int 
q2json(
    char *in,
    char *out,
    unsigned  sz_out
    )
// START FUNC DECL
{
  int status = 0;
  YY_BUFFER_STATE b = NULL;
  // b->yy_input_file = NULL;
  // b->yy_ch_buf     = NULL;
  // b->yy_buf_pos    = NULL;

  if ( in == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }

  yy_scan_string(in);
  status = yyparse(); cBYE(status);
  yylex_destroy();
  // yy_delete_buffer(b);
BYE:
  return status;
}
