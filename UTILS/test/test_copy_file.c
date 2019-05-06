#include<stdio.h>
#include<stdlib.h>
#include<inttypes.h>
#include "_copy_file.h"
#include "_get_file_size.h"

int main(int argc, char** argv) {
  int status = 0;
  if ( argc != 3 ) {
    printf("Please provide appropriate argument\nArgs: src_file, dest_file\n");
    status = -1;
    goto BYE;
  }
  
  char *src_file = argv[1];
  char *dst_file = argv[2];
  printf("Copying %s to %s\n", src_file, dst_file);

  status = copy_file(src_file, dst_file);
  if ( status != 0 ) {
    printf("Failed to copy file %s to %s, status=%d\n", src_file, dst_file, status);
    goto BYE;
  }
  else {
    printf("Successfully copied %s to %s\n", src_file, dst_file);
  }

  // Compare file size
  int64_t expected_fsz = get_file_size(src_file);
  int64_t actual_fsz = get_file_size(dst_file);
  if ( expected_fsz != actual_fsz ) {
    printf("File size match failed\n");
    status = -1;
    goto BYE;
  }
  else {
    printf("File size is proper\n");
  }

BYE:
  return status;
}
