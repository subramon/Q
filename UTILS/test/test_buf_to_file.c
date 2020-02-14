#include "q_incs.h"
#include "_mix_UI8.h"
#include "_rand_file_name.h"
#include "_buf_to_file.h"

int
main()
{
  int status = 0;
#define MAX_FILE_NAME 63
  char fname[MAX_FILE_NAME+1];
  memset(fname, '\0', MAX_FILE_NAME+1);

#define BUFLEN 1048576
  int *Y = NULL;
  Y = malloc(BUFLEN * sizeof(int));
  for ( int i = 0; i < BUFLEN; i++ ) { 
    Y[i] = i+1;
  }

  int num_trials = 4;
  for ( int i = 0; i < num_trials; i++ ) { 
    status = rand_file_name(fname, MAX_FILE_NAME); cBYE(status);
    fprintf(stderr, "i = %d, fname = %s \n", i, fname);
    status = buf_to_file((const char * const)Y, sizeof(int), BUFLEN, fname); 
    cBYE(status);
    remove(fname);
  }

BYE:
  free_if_non_null(Y);
  return status;
}
