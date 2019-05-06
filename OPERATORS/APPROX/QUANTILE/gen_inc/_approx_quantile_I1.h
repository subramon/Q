
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <limits.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "q_macros.h"
#include "_qsort_asc_I1.h"
#include "determine_b_k.h"
#include "_New_I1.h"
#include "_Collapse_I1.h"
#include "_Output_I1.h"

#ifdef IPP
#include "ipp.h"
#include "ippi.h"
#endif

#define MAX_SZ 200*1048576
/* Will not use more than (4*200) MB of RAM, can change if you want */

extern int 
approx_quantile_I1 (
		 int8_t *x, 
		 char * cfld,
		 uint64_t siz, 
		 uint64_t num_quantiles, 
		 double err, 
		 int8_t *y,
		 int *ptr_estimate_is_good
		 );


  
