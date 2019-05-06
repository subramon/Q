
#include "_cum_cnt_F4_I2.h"

int
cum_cnt_F4_I2(  
      const float * restrict val,
      void *dummy1,
      uint64_t nR,  
      CUM_CNT_F4_I2_ARGS *ptr_args,
      int16_t * restrict cnt,
      void *dummy2
      )

{
  int status = 0;
  if ( val == NULL ) { go_BYE(-1); }
  if ( cnt == NULL ) { go_BYE(-1); }
  if ( dummy1 != NULL ) { go_BYE(-1); }
  if ( dummy2 != NULL ) { go_BYE(-1); }
  if ( ptr_args == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }

  float prev_val = ptr_args->prev_val;
  int16_t prev_cnt = ptr_args->prev_cnt;
  if ( prev_cnt < 0 ) {  // very first time through
    cnt[0] = 1;
    prev_val = val[0];
  }
  else {
    if ( val[0] == prev_val ) { 
      cnt[0] = prev_cnt + 1;
    }
    else {
      cnt[0] = 1;
    }
  }
  prev_val = val[0];
  prev_cnt = cnt[0];
  for ( uint64_t i = 1; i < nR; i++ ) { 
    if ( val[i] == prev_val ) {
      cnt[i] = ++prev_cnt;
    }
    else {
      cnt[i] = prev_cnt = 1;
      prev_val = val[i];
    }
  } 
  ptr_args->prev_val = prev_val;
  ptr_args->prev_cnt = prev_cnt;
BYE:
  return status;
}
   
