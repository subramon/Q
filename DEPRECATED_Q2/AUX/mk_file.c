#include <stdio.h>
#include "q_constants.h"
#include "macros.h"
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include "mk_file.h"
/* Creates a file of size "filesize" in directory "dir" */

// START FUNC DECL
int
mk_file(
    const char *filename,
    size_t filesize
    )
// STOP FUNC DECL
{
  int status= 0;
  int result, fd;

  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { go_BYE(-1); }
  if ( filesize <= 0 ) { go_BYE(-1); }

  /* Open a file for writing.  - Creating the file if it doesn't
   *  exist.  - Truncating it to 0 size if it already exists. (not
   *  really needed)
   *
   * Note: "O_WRONLY" mode is not sufficient when mmaping.
   */
  fd = open(filename, O_RDWR | O_CREAT | O_TRUNC, (mode_t)0600);
  if (fd == -1) {
    fprintf(stderr, "Error opening %s file for writing\n", filename);
    go_BYE(-1);
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
  return(status);
}
