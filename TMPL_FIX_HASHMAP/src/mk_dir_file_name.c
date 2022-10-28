#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "q_macros.h"
#include "mk_dir_file_name.h"

char *
mk_dir_file_name(
    const char * const d,
    const char * const f
    )
{
  int status = 0;
  char *fname = NULL; 

  if ( ( f == NULL ) || ( *f == '\0' ) ) { go_BYE(-1); }
  int len = strlen(f) + 8; // +8 for kosuru
  if ( ( d != NULL ) && ( *d != '\0' ) ) {
    len += strlen(d);
  }
  fname = malloc(len); memset(fname, 0, len);
  if ( ( d != NULL ) && ( *d != '\0' ) ) {
    sprintf(fname, "%s/%s", d, f);
  }
  else {
    strcpy(fname, f);
  }
BYE:
  if ( status != 0 ) { return NULL; } else { return fname; }
}
