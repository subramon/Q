
#include "q_incs.h"

typedef struct _cum_cnt_F4_I1_args {
  float prev_val;
  int8_t prev_cnt;
  float max_val;
  int8_t max_cnt;
  } CUM_CNT_F4_I1_ARGS;
  
extern int
cum_cnt_F4_I1(  
      const float * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_F4_I1_ARGS *ptr_args,
      int8_t * restrict out,
      void *dummy2
      ) 
;

   
