#include <stdio.h>
#include "_isfile.h"

int main(int argc, char** argv) {
  int status = 0;
  char *path = NULL;
  path = argv[1];
  printf("Input path = %s\n", path);
  
  status = isfile(path);
  if ( status ) {
    printf("%s is a regular file\n", path);
    return 0;
  }
  else {
    printf("%s is not a regular file\n", path);
    return -1;
  }
}
