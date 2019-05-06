/* START HDR FILES  */
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
/* STOP HDR FILES  */
#include "constants.h"
#include "macros.h"
#include "mmap.h"
#include "assign_I1.h"

#ifdef IPP
#include "ipp.h"
#include "ippi.h"
#endif

//START_FUNC_DECL
int
rs_mmap(
		      const char *file_name,
		      char **ptr_mmaped_file,
		      size_t *ptr_file_size,
		      bool is_write
		      )
//STOP_FUNC_DECL
{
  int status = 0;
  int fd;
  struct stat filestat;
  uint64_t len;
  char cwd[1024];
  

  if ( is_write == true ) { 
    fd = open(file_name, O_RDWR);
  }
  else {
    fd = open(file_name, O_RDONLY);
  }
  if ( fd <= 0 ) {
     if ( getcwd(cwd, 1024) == NULL ) { go_BYE(-1); }
    fprintf(stderr, "Could not open file [%s] \n", file_name);
    fprintf(stderr, "Currently in Directory %s \n", cwd);
    go_BYE(-1); 
  }
  fstat(fd, &filestat);
  len = filestat.st_size;
  /* It is okay for file size to be 0 */
  *ptr_file_size = -1;
  if ( len < 0 ) { go_BYE(-1); }
  if ( len == 0 ) { 
    *ptr_mmaped_file = NULL;
    *ptr_file_size = 0;
  }
  else {
    if ( is_write == TRUE ) { 
    *ptr_mmaped_file = (void *)mmap(NULL, (size_t) len, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
     }
     else {
    *ptr_mmaped_file = (void *)mmap(NULL, (size_t) len, PROT_READ, MAP_SHARED, fd, 0);
     }
     /* fprintf(stderr, "WARNING. Not checking mmap \n"); 
     if ( (int)*ptr_mmaped_file <= 0 ) { 
     fprintf(stderr, "mmap failed. return val is %d \n", (int)*ptr_mmaped_file);
     go_BYE(-1);
     }
  */
    close(fd);
    *ptr_file_size = filestat.st_size;
  }
 BYE:
  return(status);
}
