#include <stdio.h>
#include "_isdir.h"

int main(int argc, char** argv) {
  int status = 0;
  char *path = NULL;
  path = argv[1];
  printf("Input path = %s\n", path);
  
  status = isdir(path);
  if ( status ) {
    printf("%s is a directory\n", path);
    return 0;
  }
  else {
    printf("%s is not a directory\n", path);
    return -1;
  }
}
