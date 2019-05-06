#include <stdio.h>
#include <stdlib.h>
#include "q_constants.h"
#include "qtypes.h"
#include "macros.h"
#include "mmap.h"
#include "aux_add_fld.h"

//<hdr>
int load_buffer(
    const char *inX, 
    size_t n_inX, 
    size_t *ptr_inidx, 
    char *buf, 
    int *ptr_bufidx,
    int buflen
    )
{
//</hdr>
  int status = 0;
  size_t inidx = *ptr_inidx;
  int bufidx = 0;
  // clean out buffer
  for ( int j = 0; j < buflen; j++ ) { buf[j] = '\0'; }

  if ( inidx == n_inX ) { go_BYE(-1); }
  bool starts_with_dquote = false;
  if ( inX[inidx] == '"' ) { 
    starts_with_dquote = true;
    inidx++;
  }
  for ( ; ; ) {
    if ( inidx == n_inX ) { go_BYE(-1); }
    if ( bufidx > buflen ) { go_BYE(-1); }
    char c = inX[inidx++];
    bool is_escaped = false;
    if ( c == '\\' ) {
      if ( inidx == n_inX ) { go_BYE(-1); } c = inX[inidx++];
      is_escaped = true;
    }
    if ( is_escaped ) { 
      buf[bufidx++] = c;
      continue;
    }
    // Decide whether to terminate buffer
    if ( starts_with_dquote == true ) { 
      if ( c == '"' ) { /* end of buffer */
        if ( inidx == n_inX ) { go_BYE(-1); }
        c = inX[inidx++]; 
        if ( c != '\n' ) { go_BYE(-1); }
        buf[bufidx++] = '\0';
        break;
      }
    }
    else {
      if ( c == '\n' ) {
        buf[bufidx++] = '\0';
        break;
      }
    }
    buf[bufidx++] = c;
  }
  // Remove the trailing eoln
  buf[bufidx] = '\0';
  bufidx--;
  if ( bufidx < 0 ) { go_BYE(-1); }
  *ptr_inidx = inidx;
  *ptr_bufidx = bufidx;
BYE:
    return status;
}
