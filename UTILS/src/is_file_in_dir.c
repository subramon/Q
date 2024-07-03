//START_INCLUDES
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "isfile.h"
#include "isdir.h"
#include "is_file_in_dir.h"

//START_FUNC_DECL
bool 
is_file_in_dir (
    const char * const file_name,
    const char * const dir_name
    )
//STOP_FUNC_DECL
{
  char *buf = NULL;
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { return false; }
  if ( (  dir_name == NULL ) || ( *dir_name == '\0' ) ) { return false; }
  if ( !isdir(dir_name) ) { return false; }
  size_t len = strlen(file_name) + strlen(dir_name) + 32;
  buf = malloc(len); 
  sprintf(buf, "%s/%s", dir_name, file_name);
  bool rslt = isfile(buf);
  free_if_non_null(buf);
  return rslt;
}
