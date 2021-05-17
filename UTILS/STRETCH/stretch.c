#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "macros.h"
#include "rs_mmap.h"
#include "get_file_size.h"

#define N 4 
int
main(
    int argc,
    char **argv
    ) 
{ 
  int status = 0;
  FILE *fp = NULL;
  off_t o2;
  int fd = -1;
  char *X = NULL; size_t nX = 0;
  if ( argc != 2 ) { go_BYE(-1); } 
  const char * const file_name = argv[1]; 

  int Y[N];
  for ( int i = 0;  i < N; i++ ) { Y[i] = i+1; }
  fp = fopen(file_name, "wb");
  return_if_fopen_failed(fp,  file_name, "wb");
  int nw = fwrite(Y, sizeof(int), N, fp);
  if ( nw != N ) { go_BYE(-1); } 
  fclose_if_non_null(fp); 
  int filesz = get_file_size(file_name); 
  printf("file size = %d \n", filesz);

  fd = open(file_name, O_RDWR);
  if ( fd < 0 ) { go_BYE(-1); }
  // o2 = lseek(fd, 0, SEEK_END);
  o2 = lseek(fd, filesz, SEEK_CUR);

  for ( int i = 0;  i < N; i++ ) { Y[i] *= 10; }
  write(fd, Y, N * sizeof(int));
  close(fd);
  filesz = get_file_size(file_name); 
  printf("file size = %d \n", filesz);



BYE:
  if ( fd >= 0 ) { close(fd); fd = -1; } 
  rs_munmap(X, nX); 
  return status;
}
