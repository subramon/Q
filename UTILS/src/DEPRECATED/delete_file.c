//START_INCLUDES
#include<stdio.h>
#include <stdbool.h>
//STOP_INCLUDES
#include "_delete_file.h"

//START_FUNC_DECL
bool 
delete_file (
    const char * const filename
    )
//STOP_FUNC_DECL
{
   if ( ( filename == NULL ) || ( *filename == '\0' ) ) { return false; }
   int status = remove(filename);
   if ( status == 0 ) { /* File deleted */
     return true;
   }
   else {
     return false;
   }
}
