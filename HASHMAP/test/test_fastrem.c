#include "fastdiv.h"
#include "get_time_usec.h"
int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  uint32_t a, b;
  srandom(get_time_usec());
  b = random() % (1<<20);
  uint64_t divinfo = fast_div32_init(b);
  for ( int i = 1; i < 1000; i++ ) { 
    a = random();
    uint32_t r1 = fast_rem32(a, b, divinfo);
    uint32_t r2 = a % b;
    uint32_t q1 = fast_div32(a, b, divinfo);
    uint32_t q2 = a / b;
    if ( r1 != r2 ) { 
      go_BYE(-1);
    }
    if ( q1 != q2 ) { 
      go_BYE(-1);
    }
  }
  fprintf(stdout, "%s Completed successfully \n", argv[0]);
BYE:
  return status;
}
