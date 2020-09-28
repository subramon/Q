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
  uint32_t *yval;
  uint32_t *yidx;
  uint32_t *nT;
  uint32_t *nH;
  double   *metric;
} metrics_t; 

typedef struct _node_t { 
  int lchild_id;
  int rchild_id;
  int parent_id;
  int yidx;
  uint32_t yval; // remember this is position-encoded value
  float xval;
  uint32_t nH;
  uint32_t nT;
} node_t;

#endif
