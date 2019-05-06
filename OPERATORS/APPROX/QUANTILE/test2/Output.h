#include <inttypes.h>

int
Output(
       int **src_bufs,      
       int *ptr_weight, 
       int *last_packet,
       int last_packet_incomplete,
       uint64_t last_packet_siz, 
       uint64_t eff_siz, 
       uint64_t num_quantiles,
       int *dst,
       int b,         
       uint64_t k
       );
