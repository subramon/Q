//START_INCLUDES
#include <stdio.h>
#include <string.h>
#include "q_macros.h"
#include "_get_file_size.h"
//STOP_INCLUDES
#include "_get_num_elements.h"
//START_FUNC_DECL
int64_t 
get_num_elements(
	const char * const file_name,
	const char * const qtype
	)
//STOP_FUNC_DECL
{
  int64_t file_size = get_file_size(file_name);
  if ( file_size <= 0 ) { WHEREAMI; return -1; }
  if ( strcmp(qtype, "I1") == 0 )  {
    return file_size / 1; 
  }
  else if ( strcmp(qtype, "I2") == 0 ) {
    return file_size / 2; 
  }
  else if ( strcmp(qtype, "I4") == 0 ) {
    return file_size / 4; 
  }
  else if ( strcmp(qtype, "I8") == 0 ) {
    return file_size / 8; 
  }
  else if ( strcmp(qtype, "F4") == 0 ) {
    return file_size / 4; 
  }
  else if ( strcmp(qtype, "F8") == 0 ) {
    return file_size / 8; 
  }
  else {
    WHEREAMI; return -1; 
  }
}
