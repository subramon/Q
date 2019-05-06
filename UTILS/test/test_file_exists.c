#include <stdio.h>
#include "_file_exists.h"

int main(int argc, char** argv) {
  int status = 0;
  char *path = NULL;
  path = argv[1];
  printf("Input path = %s\n", path);
  
  status = file_exists(path);
  if ( status ) {
    printf("Path Exists\n");
    return 0;
  }
  else {
    printf("Path Doesn't Exists\n");
    return -1;
  }
}
