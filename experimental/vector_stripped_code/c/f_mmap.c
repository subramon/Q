//START_INCLUDES
#include <stdio.h>
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
#include <ctype.h>
#include <errno.h>
#include <malloc.h>
#include "q_incs.h"
#include "mmap_types.h"
//STOP_INCLUDES
#include "_f_mmap.h"
//START_FUNC_DECL

MMAP_REC_TYPE *
f_mmap(
   char * const file_name,
   bool is_write
)
//STOP_FUNC_DECL
{
  int status = 0;
  MMAP_REC_TYPE *ptr_mmap = NULL;
  ptr_mmap = (MMAP_REC_TYPE *)malloc(sizeof(MMAP_REC_TYPE));
  memset(ptr_mmap, '\0', sizeof(MMAP_REC_TYPE));

  errno = 0;
  if ( ( file_name == NULL) || ( *file_name == '\0' ) ) { go_BYE(-1); }
  if ( strlen(file_name) >= Q_MAX_LEN_FILE_NAME ) { go_BYE(-1); }
  for (  char *cptr = file_name; *cptr != '\0'; cptr++ ) { 
    if ( !isascii(*cptr) ) { go_BYE(-1); }
  }
  if ( ptr_mmap == NULL ) { go_BYE(-1); }
  ptr_mmap->status = -1;
  ptr_mmap->map_addr = NULL;
  ptr_mmap->map_len = 0;
  // TODO: Change 255 to q #define CONSTANT
  if ( strlen(file_name) > 255 ) { go_BYE(-1); }

  int fd, flags;
  struct stat filestat;
  size_t len;

  //---------------------
  if ( is_write ) {
    fd = open(file_name, O_RDWR);
  } 
  else {
    fd = open(file_name, O_RDONLY);
  }
  if ( fd < 0 ) { go_BYE(-1); }
  status = fstat(fd, &filestat); cBYE(status);
  len = filestat.st_size;
  if ( len == 0 ) {  go_BYE(-1); }
  if ( is_write ) {
    flags = PROT_READ | PROT_WRITE;
  }
  else {
    flags = PROT_READ;
  }
  ptr_mmap->map_addr = (void*)mmap(NULL, (size_t)len, flags, 
      MAP_SHARED, fd, 0);
  close(fd);
  ptr_mmap->map_len = filestat.st_size;
  ptr_mmap->status  = 0;
  ptr_mmap->is_persist = false;
  strcpy(ptr_mmap->file_name, file_name);
BYE:
  if ( status < 0 ) { return NULL; } else { return ptr_mmap; }
}
