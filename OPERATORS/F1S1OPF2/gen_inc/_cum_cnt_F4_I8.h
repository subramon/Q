
#include "q_incs.h"

typedef struct _cum_cnt_F4_I8_args {
  float prev_val;
  int64_t prev_cnt;
  float max_val;
  int64_t max_cnt;
  } CUM_CNT_F4_I8_ARGS;
  
extern int
cum_cnt_F4_I8(  
      const float * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_F4_I8_ARGS *ptr_args,
      int64_t * restrict out,
      void *dummy2
      ) 
;

   
