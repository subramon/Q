// gcc -g test_F2.c qtypes.c -I../inc/ -o test_F2 && ./test_F2
#include "q_incs.h"
#include "q_macros.h"
#include "qtypes.h"
int
main()
{
  int status = 0;
  uint8_t *a;
  float x = -63;
  a = &x;
  bfloat16 y = F4_to_F2(x);
  printf("y = %u \n", y);
  float z = F2_to_F4(y);
  a = &z;

  printf("x = %f \n", x);
  printf("z = %f \n", z);
  if ( x != z ) { go_BYE(-1); } 
  printf("Test F4 to F2 to F4 succeeded \n");
BYE:
  return status;
}
