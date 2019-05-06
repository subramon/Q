#include <stdio.h>
#include <stdlib.h>
#include "file_cleanup_struct.h"
#include "_file_cleanup.h"
//START_FUNC_DECL
int
file_cleanup(
    file_cleanup_struct* data 
)
//STOP_FUNC_DECL
{
  int status=0;
  if (data->clean == 0) {
    status = remove(data->file_name);
  }
  free(data);
  return status;
}
