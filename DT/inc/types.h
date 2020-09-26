#ifndef __DT_TYPES
#define __DT_TYPES
typedef struct _four_nums_t {  
  uint32_t n_T_L;
  uint32_t n_H_L;
  uint32_t n_T_R;
  uint32_t n_H_R;
} four_nums_t; 
/* had to switch from AOS to SOA 
typedef struct _metrics_t {  
  uint32_t yval;
  uint32_t yidx;
  uint32_t cnt[2];
  double metric;
} metrics_t; 
*/
typedef struct _metrics_t {  
  uint32_t yval[BUFSZ];
  uint32_t yidx[BUFSZ];
  uint32_t nT[BUFSZ];
  uint32_t nH[BUFSZ];
  double metric[BUFSZ];
} metrics_t; 

#endif
