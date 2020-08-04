#include "q_incs.h"
#include "_cum_cnt_I8_I2.h"
int
main(
    )
{
  int status = 0;
  //-- Initialization
#define N 100
#if N > 32767 
#error
#endif
  CUM_CNT_I8_I2_ARGS args;
  args.prev_val = 0; // any value is okay since disregarded if cnt < 0
  args.prev_cnt = -1;
  int64_t val[N];
  int16_t cnt[N];
  int64_t lval = 99; int period = 4;
  for ( int i = 0; i < N; i++ ) { 
    if ( ( i % period ) == 0 ) { 
      lval++;
    }
    val[i] = lval;
  }
  //-- Testing starts
  int nB = 3; // num blocks
  int block_size = N/nB; 
  if ( block_size == 0 ) { go_BYE(-1); }
  for ( int b = 0; b < nB; b++ ) { 
    int lb = b * block_size;
    int ub = lb + block_size;
    if ( b == (nB-1)  ) { ub = N; }
    int lN = ub - lb;
    status = cum_cnt_I8_I2(val+lb, NULL, lN, &args, cnt+lb, NULL);
    cBYE(status);
  }
  //--- Verification
  int16_t lcnt = 1; 
  for ( int i = 0; i < N; i++ ) { 
    if ( ( i % period ) == 0 ) { 
      lcnt = 1;
    }
    if ( cnt[i] != lcnt ) { 
      fprintf(stderr, "FAILURE, i = %d \n", i);
      go_BYE(-1); 
    }
    lcnt++;
  }
  printf("SUCCESS\n");
BYE:
  return status;
}
