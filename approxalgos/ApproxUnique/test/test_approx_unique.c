#include "q_incs.h"
#include "approx_unique.h"

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_RESET   "\x1b[0m"

int 
main(
    int argc,
    char ** argv
    )
{

  int status = 0;
  approx_unique_state_t state;
  int sizeof_key = sizeof(int);
  double accuracy; int estimate; int is_good;
  /* Case 1: All unique values */
  int n = 1048576;
  status = approx_unique_make(&state, 0, 0, sizeof_key); cBYE(status);
  for ( int i = 0; i < n; i++ ) { 
    status = approx_unique_add(&state, (char *)&i); cBYE(status);
    if ( ( i % 1024 ) == 0 ) {  printf("i = %d \n", i); }
  }
  status = approx_unique_final(&state, &estimate, &accuracy, &is_good);
  printf("estimate = %d \n", estimate);
  printf("accuracy = %f \n", accuracy);
  printf("is_good  = %d \n", is_good);
  status = approx_unique_free(&state); cBYE(status);
BYE:
  return status;
}
