//START_INCLUDES
#include<stdio.h>
#include <stdbool.h>
#include <sys/stat.h>
//STOP_INCLUDES
#include "_make_dir.h"

//START_FUNC_DECL
bool 
make_dir (
    const char * const path
    )
//STOP_FUNC_DECL
{
   if ( ( path == NULL ) || ( *path == '\0' ) ) { return false; }
   int status = mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
   if ( status == 0 ) { /* File deleted */
     return true;
   }
   else {
     return false;
   }
}
