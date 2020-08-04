//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "isfile.h"

//START_FUNC_DECL
bool 
isfile (
    const char * const filename
    )
//STOP_FUNC_DECL
{
  struct stat buf;
  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { return false; }
  int status = stat(filename, &buf );
  if ( ( status == 0 ) && ( S_ISREG( buf.st_mode ) ) ) { /* Path found, check for regular file */
    return true;
  }
  else {
    return false;
  }
}
