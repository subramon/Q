typedef struct aq_rec_type {
  int b;
  uint64_t k;
  int **buffers;
  int *weight;
  int *last_packet;
  int num_in_lp;
} AQ_REC_TYPE;

int 
approx_quantile (
		 int *x, 
		 char * cfld,
		 uint64_t siz, 
		 uint64_t num_quantiles, 
		 double err, 
		 int *y,
		 uint64_t y_siz,
		 int *ptr_estimate_is_good,
                 AQ_REC_TYPE *aqrt,
                 bool is_last
		 );

