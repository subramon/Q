#include "q_incs.h"
#include "_mmap.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  if ( argc != 2 ) { go_BYE(-1); }
  char *file_name = argv[1];
  status = rs_mmap(file_name, &X, &nX, 0);  cBYE(status);
  if ( ( ( nX / 8 ) * 8 )  != nX ) { go_BYE(-1); }
  int n = nX / 8;
  uint64_t sum = 0;
  for ( int i = 0; i < n; i++ ) { 
    sum += __builtin_popcountll(X[i]);
    if ( i % 65536 == 0 ) {
      printf("%d:%d \n", i, actual_cnt);
    }
  }
  printf("n = %d, sum = %llu\n", n, sum);
BYE:
  return  status;
}

