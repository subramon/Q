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
  int niters = 2;
  int val;
  for ( int iter = 0; iter < niters; iter++ ) { 
  status = approx_unique_make(&state, 0); cBYE(status);
  switch ( iter ) { 
    case 0 : /* all distinct values */
      val = 0;
      for ( int i = 0; i < n; i++ ) { 
        status = approx_unique_exec(&state, (char *)&val, sizeof(int)); 
        cBYE(status);
        val++;
      }
      break;
    case 1 : 
      //-- Case 2: half are unique values */
      val = 0;
      for ( int i = 0; i < n; i++ ) { 
        status = approx_unique_exec(&state, (char *)&val, sizeof(int)); 
        cBYE(status);
        val++;
        if ( val == n/2 ) { val = 0; }
      }
      break;
    default : 
      go_BYE(-1);
      break;
  }

  status = approx_unique_final(&state, &estimate, &accuracy, &is_good);
  printf("estimate = %d \n", estimate);
  printf("accuracy = %f \n", accuracy);
  printf("is_good  = %d \n", is_good);
  status = approx_unique_free(&state); cBYE(status);
  }
BYE:
  return status;
}
