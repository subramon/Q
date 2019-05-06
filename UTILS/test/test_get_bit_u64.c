#include "q_incs.h"
#include "_rdtsc.h"
#include "_get_bit_u64.h"

int
main()
{
  int status = 0;
#define N 10
  uint64_t X[N];

  srand48(RDTSC());

  for ( int i = 0; i < N; i++ ) { 
    X[i] = lrand48();
  }
  int ctr = 0; int xidx = 0;
  uint64_t l = X[0];
  int tmp1 = X[0] & 0xFF;
  printf("tmp1 = %d \n", tmp1);

  for ( int i = 0; i < N*64; i++ ) { 
    if ( i == 64 ) {
      printf("hello world\n");
    }
    int t1 = get_bit_u64(X, i);
    int t2 = l & 0x1;
    if ( t1 != t2 ) { 
      printf("t1 = %d t2 = %d, i= %d, xidx = %d \n", t1, t2, i, xidx);
      go_BYE(-1);  
    }
    l = l >> 1; 
    ctr++; if ( ctr == 64 ) { l = X[++xidx]; ctr = 0; }
  }
BYE:
  return status;
}
