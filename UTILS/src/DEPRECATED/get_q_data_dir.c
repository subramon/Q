//START_INCLUDES
#include <stdio.h>
#include <stdbool.h>
#include <fcntl.h>
#include <sys/stat.h>
//STOP_INCLUDES
#include "_get_q_data_dir.h"
#include "_isdir.h"

//START_FUNC_DECL
char *
get_q_data_dir (
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *data_dir = NULL;

  data_dir = malloc(Q_MAX_LEN_DIR+1);
  return_if_malloc_failed(data_dir);
  memset(data_dir, '\0', Q_MAX_LEN_DIR+1);

  char *x = getenv("Q_DATA_DIR");
  if ( x == NULL ) { go_BYE(-1); }
  int len = 0;
  for ( char *cptr = x; *cptr != '\0'; len++, cptr++ ) {
    if ( len >= Q_MAX_LEN_DIR ) { go_BYE(-1); }
    data_dir[len] = *cptr;
  }
  if ( data_dir[len-1] != '/' ) {
    data_dir[len] = '/';
  }
  if ( !isdir(data_dir) ) { go_BYE(-1); }
BYE:
  if ( status < 0 ) { return NULL; }
  return data_dir;
}
