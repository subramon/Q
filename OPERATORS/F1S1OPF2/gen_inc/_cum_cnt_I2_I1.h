
#include "q_incs.h"

typedef struct _cum_cnt_I2_I1_args {
  int16_t prev_val;
  int8_t prev_cnt;
  int16_t max_val;
  int8_t max_cnt;
  } CUM_CNT_I2_I1_ARGS;
  
extern int
cum_cnt_I2_I1(  
      const int16_t * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_I2_I1_ARGS *ptr_args,
      int8_t * restrict out,
      void *dummy2
      ) 
;

   
