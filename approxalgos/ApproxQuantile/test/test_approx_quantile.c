#include "q_incs.h"
#include "approx_quantile.h"

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_RESET   "\x1b[0m"

int 
main(
    int argc,
    char **argv
    )
{
#ifdef XXX
  int status = 0;

  int *x = NULL;
  char *X = NULL; size_t nX = 0;

  int * y = NULL;
  double *quantile_percent = NULL;

  // Generate data 
  //----------------------------------------------------------------------

  long long num_quantile = 1000; 
  /* ex: 5 => need 5 quantiles {20%,40%,60%,80%,100%}, choose between 1 & number of elements to be considered */
  if ( num_quantile == 0 ) { cBYE(-1);}

  long long y_siz = num_quantile;
  y = (int *)malloc( y_siz * sizeof(int) );
  return_if_malloc_failed(y);
 
  double eps = 0.001;   /* 0.0001: Ok with +/- 0.01% error in quantile estimations. For ex: 50% -> ok with 50 +/- 0.01 % */ 
  int estimate_is_good; 

  status = approx_quantile(x, cfld, siz, num_quantile, eps, y, y_siz, &estimate_is_good); cBYE(status);

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
  free_if_non_null(y);
  free_if_non_null(quantile_percent);
  return(status);
#endif
}
