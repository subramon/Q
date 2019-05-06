
#include "q_incs.h"

typedef struct _cum_cnt_F4_I4_args {
  float prev_val;
  int32_t prev_cnt;
  float max_val;
  int32_t max_cnt;
  } CUM_CNT_F4_I4_ARGS;
  
extern int
cum_cnt_F4_I4(  
      const float * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_F4_I4_ARGS *ptr_args,
      int32_t * restrict out,
      void *dummy2
      ) 
;

   
