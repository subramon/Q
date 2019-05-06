#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <stdbool.h>
#include "approx_quantile.h"
#include "determine_b_k.h"
#include <stdlib.h>
#include <unistd.h>
#include "string.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <assert.h>
#include <fcntl.h>
#include "constants.h"
#include "macros.h"
#include "mmap.h"

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_RESET   "\x1b[0m"
#define MAX_SZ 200*1048576

int main (
	  int argc,
	  char **argv
	  )
{

  int status = 0;

  int *x = NULL;
  char *X = NULL; size_t nX = 0;
  char *cfld = NULL; size_t nY = 0;

  int * y = NULL;
  double *quantile_percent = NULL;

  if ( argc != 2 && argc != 3 ) { go_BYE(-1); }
  /* argc == 2 would mean just having the input binary file ( cfld will be assumed to be NULL, argc == 3 would mean that a corresponding cfld binary file is also included */

  char * infile = argv[1];
  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  uint64_t siz = nX / sizeof(int);	   
  x = (int *)X;
  if ( x == NULL ) { go_BYE(-1); }
  
  if ( argc == 3 ) { 
    char * cfldfile = argv[2];
    status = rs_mmap(cfldfile, &cfld, &nY, 0); cBYE(status);
    if ( cfld == NULL ) { go_BYE(-1); }
  }

  //----------------------------------------------------------------------
  uint64_t num_quantile = 20;//1000; 
  /* ex: 5 => need 5 quantiles {20%,40%,60%,80%,100%}, choose between 1 & number of elements to be considered */
  if ( num_quantile == 0 ) { cBYE(-1);}

  uint64_t y_siz = num_quantile;
  y = (int *)malloc( y_siz * sizeof(int) );
  return_if_malloc_failed(y);
 
  double eps = 0.001;   /* 0.0001: Ok with +/- 0.01% error in quantile estimations. For ex: 50% -> ok with 50 +/- 0.01 % */ 
  int estimate_is_good = -1; /* default */ 

  AQ_REC_TYPE aqrt;
  bool is_last = false;
  
  int b;
  uint64_t k;
  // MAKING ASSUMPTION THAT cfld is NULL so eff_size = siz TODO FIX
  uint64_t eff_siz = siz;
  status = determine_b_k(eps, eff_siz, &b, &k); cBYE(status);
  if ( b <= 0 || k <= 0 ) {
    estimate_is_good = -1;
    go_BYE(-1) /* Something wrong with the inputs eps or siz */
  }
  else if ( (b+1+10)*k > MAX_SZ ) {
    estimate_is_good = -2;
    go_BYE(0);
    /* Quiting if too much memory needed */
  }
  else {
    estimate_is_good = 1;
  }

  aqrt.b = b;
  aqrt.k = k;

/*-----------------------------------------------------*/
  /* Set buffer and weight  */
  int **buffer;
  int *weight;

  buffer = malloc( b * sizeof(int * ) );
  return_if_malloc_failed(buffer);

  weight = malloc( b * sizeof(int) );
  return_if_malloc_failed(weight);

#ifdef IPP
  ippsZero_32s((int *)weight, b);
#else
  memset(weight, 0, b*sizeof(int));
#endif

  for ( int ii = 0; ii < b; ii++ ) { 
    buffer [ii] = (int *) malloc( k * sizeof(int) );
  }

  for (int ii = 0; ii < b; ii++ ) {
    return_if_malloc_failed(buffer[ii]);
#ifdef IPP
    ippsZero_32s((int *)buffer[ii], k);
#else
    memset(buffer[ii], 0, k*sizeof(int));
#endif
  }

  aqrt.last_packet = (int *)malloc ( k * sizeof(int));
  return_if_malloc_failed(aqrt.last_packet);
  aqrt. num_in_lp = 0;




   /* CALLING APPROX QUANTILE */
  status = approx_quantile(x, cfld, siz, num_quantile, eps, y, y_siz, &estimate_is_good, &aqrt, is_last); cBYE(status);

  quantile_percent = (double *)malloc ( num_quantile * sizeof(double) );
  return_if_malloc_failed(quantile_percent);

  for ( int ii = 0; ii < num_quantile; ii++ ) { 
    quantile_percent[ii] = (double)(ii+1)*100/num_quantile; 
  }
 
  if ( estimate_is_good == 1 ) {

    /* approx_quantile() succeeded in doing the quantile calculations. printing values */
    for ( int ii = 0; ii < num_quantile; ii++ ) {
      printf("%.2f%%: " ANSI_COLOR_GREEN"%d"ANSI_COLOR_RESET"\n", quantile_percent[ii],y[ii]);
    }

  }
  else {

    /* approx_quantile() failed in doing the calculations */
    printf("\n Need too much memory. \n(i) If you are sure you can use more than 800 MB of memory, go and increase MAX_SZ in the approx_quantile() function. \n(ii) Else, just increase eps (approximation) and retry.  \n");

  }
  
BYE:
  rs_munmap(X, nX);
  if ( cfld != NULL ) {
    rs_munmap(cfld, nY);
  }

  free_if_non_null(y);
  free_if_non_null(quantile_percent);

  return(status);
}
