#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "_I4_to_txt.h"

#define BUFLEN 1024

int main() {
  int len = 2;

  // Prepare input buffer
  int32_t *X = NULL;
  X = malloc(len * sizeof(int32_t));
  X[0] = -2;
  X[1] = 2;
  
  printf("################################\n");
  printf("Printing input buffer contents\n");
  for ( int i = 0; i < len; i++ ) {
    printf("%d\n", X[i]);
  }
  printf("################################\n");

  // Prepare output buf
  char * buf = NULL;
  buf = malloc(BUFLEN);

  // Call I4_to_txt
  int status = 0;
  printf("Converted values are\n");
  for ( int i = 0; i < len; i ++ ) {
    memset(buf, '\0', BUFLEN);
    status = I4_to_txt(X + i, NULL, buf, BUFLEN-1);
    // printf("I4_to_txt execution status = %d\n", status);
    if ( status == 0 ) {
      printf("%s\n", buf);
    }
    else {
      printf("Error\n");
    }
  }
  printf("################################\n");
  free(X);
  free(buf);
  return 0;
}
