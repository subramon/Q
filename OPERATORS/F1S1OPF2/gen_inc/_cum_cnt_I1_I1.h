
#include "q_incs.h"

typedef struct _cum_cnt_I1_I1_args {
  int8_t prev_val;
  int8_t prev_cnt;
  int8_t max_val;
  int8_t max_cnt;
  } CUM_CNT_I1_I1_ARGS;
  
extern int
cum_cnt_I1_I1(  
      const int8_t * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_I1_I1_ARGS *ptr_args,
      int8_t * restrict out,
      void *dummy2
      ) 
;

   
