
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <inttypes.h>
#include "q_macros.h"
#include <math.h>


extern int
Output_I2(
       int16_t **src_bufs,      
       int *ptr_weight, 
       int16_t *last_packet,
       int last_packet_incomplete,
       uint64_t last_packet_siz, 
       uint64_t eff_siz, 
       uint64_t num_quantiles,
       int16_t *ptr_y,
       uint32_t b,         
       uint32_t k
       );

  
