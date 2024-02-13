//START_INCLUDES
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mman.h>
#include "q_macros.h"
//START_INCLUDES
#include "mk_file.h"

/* Creates a file of size "filesize" in directory "dir" */

//START_FUNC_DECL
int
mk_file(
    const char * const dir,
    const char * const filename,
    size_t filesize
    )
//STOP_FUNC_DECL
{
  int status= 0;
  int result, fd;
  char *full_name = NULL;

  if ( filename == NULL ) { go_BYE(-1); }
  // if ( filesize == 0 ) { go_BYE(-1); } // okay to create 0 sized file 

  /* Check that directory is accessible */
  if ( dir != NULL ) { 
#define MAX_LEN_DIR_NAME 255
    char cwd[MAX_LEN_DIR_NAME+1];
    memset(cwd, 0, MAX_LEN_DIR_NAME+1);
    if ( getcwd(cwd, MAX_LEN_DIR_NAME) == NULL ) { go_BYE(-1); }
    status = chdir(dir);  cBYE(status);
    status = chdir(cwd);  cBYE(status);
  }
  /* Open a file for writing.  - Creating the file if it doesn't
   *  exist.  - Truncating it to 0 size if it already exists. (not
   *  really needed)
   *
   * Note: "O_WRONLY" mode is not sufficient when mmaping.
   */
  // create fully qualified file name 
  if ( dir != NULL ) {
    int len = strlen(filename) + strlen(dir) + 4;
    full_name = malloc(len); return_if_malloc_failed(full_name);
    sprintf(full_name, "%s/%s", dir, filename); 
  }
  else {
    full_name = strdup(filename);
  }
  fd = open(full_name, O_RDWR | O_CREAT | O_TRUNC, (mode_t)0600);
  if (fd == -1) {
    fprintf(stderr, "Error opening %s file for writing\n", filename);
    go_BYE(-1);
  }
  if ( filesize == 0 ) { 
    close(fd);
    return status;
  }
  /* Stretch the file size to the size of the (mmapped) array of ints */
  result = lseek(fd, filesize - 1, SEEK_SET);
  if (result == -1) {
    close(fd);
    fprintf(stderr, "Error calling lseek() to 'stretch' file [%s]\n", filename);
    go_BYE(-1);
  }
				      
  /* Something needs to be written at the end of the file to have the
   * file actually have the new size.  Just writing an empty string at
   * the current file position will do.
   *
   * Note: - The current position in the file is at the end of the
   * stretched file due to the call to lseek().  - An empty string is
   * actually a single '\0' character, so a zero-byte will be written
   * at the last byte of the file.
   */
  result = write(fd, "", 1);
  close(fd);
  if (result != 1) {
    fprintf(stderr, "Error writing last byte of file \n");
    go_BYE(-1);
  }
BYE:
  free_if_non_null(full_name);
  return(status);
}
