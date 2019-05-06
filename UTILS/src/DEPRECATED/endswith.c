//START_INCLUDES
#include<stdio.h>
#include<stdbool.h>
#include<string.h>
//STOP_INCLUDES
#include "_endswith.h"

//START_FUNC_DECL
bool 
endswith (
    const char * const path,
    const char * const val
    )
//STOP_FUNC_DECL
{
   if ( ( path == NULL ) || ( *path == '\0' ) ) { return false; }
   const int len = strlen(path);
   if ( len > 0 && path[len-1] == *val ) { 
       return true;
   }
   else {
       return false;
   }
}



