#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include "q_incs.h"
#include "_get_file_size.h"

int
main()
{
  int status = 0;
  char *X = NULL;
  char *file_name = "_xxx.bin";
  for ( int i = 1; i < 100; i++ ) { 
    FILE *fp = NULL;
    X = malloc(i*sizeof(int));
    return_if_malloc_failed(X);
    for ( int j = 0; j < i; j++ ) { 
      X[j] = i+1;
    }
    fp = fopen(file_name, "wb");
    return_if_fopen_failed(fp,  file_name, "wb");
    int nw = fwrite(X, sizeof(int), i, fp);
    fclose(fp);
    ssize_t len = 0;
    status = get_file_size(file_name, &len);
    if ( len != (sizeof(int) * i) ) { 
      go_BYE(-1);
    }
    free(X); X = NULL;
  }
BYE:
  unlink(file_name);
  free_if_non_null(X);
  return status;
}
