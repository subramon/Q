
#include "q_incs.h"

typedef struct _cum_cnt_F8_I2_args {
  double prev_val;
  int16_t prev_cnt;
  double max_val;
  int16_t max_cnt;
  } CUM_CNT_F8_I2_ARGS;
  
extern int
cum_cnt_F8_I2(  
      const double * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_F8_I2_ARGS *ptr_args,
      int16_t * restrict out,
      void *dummy2
      ) 
;

   
