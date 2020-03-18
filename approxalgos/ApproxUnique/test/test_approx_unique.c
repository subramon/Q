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
  double accuracy; int estimate; int is_good;
  int n = 1048576;
  int niters = 12;
  int denom = 1; 
  for ( int iter = 0; iter < niters; iter++ ) {
    int max_val = n  / denom;
    status = approx_unique_make(&state, 0); cBYE(status);
    int val = 0;
    for ( int i = 0; i < n; i++ ) { 
      status = approx_unique_exec(&state, (char *)&val, sizeof(int)); 
      cBYE(status);
      val++;
      if ( val == max_val ) { val = 0; } 
    }
    status = approx_unique_final(&state, &estimate, &accuracy, &is_good);
    printf("estimate = %d \n", estimate);
    printf("accuracy = %f \n", accuracy);
    printf("is_good  = %d \n", is_good);
    status = approx_unique_free(&state); cBYE(status);
    denom = denom * 2;
  }
BYE:
  return status;
}
