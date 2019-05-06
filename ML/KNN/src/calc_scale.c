#include <math.h>
#include "q_incs.h"
#include "calc_scale.h"

int 
sort_asc_F4(
    const void *ii, 
    const void *jj
    )
{ 
  float val1, val2;
  float *ptr1, *ptr2;
  ptr1 = (float *)ii;
  ptr2 = (float *)jj;
  val1 = *ptr1;
  val2 = *ptr2;

  /* Output in asc order */
  if ( val1 > val2 )  {
    return (1);
  }
  else if ( val1 < val2 ) {
    return (-1);
  }
  else {
    return(0);
  }
}
int calc_scale(
    float **d, /* [m][n] */
    int m,
    int n
    )
{
  int status = 0;
  float *temp = NULL; 

  int n_temp = n * n;
  temp = malloc(n_temp * sizeof(float));
  for ( int i = 0; i < m; i++ ) { 
    int tidx = 0;
    float sum_dist = 0;
    float max_dist = -1;
    for ( int k1 = 0; k1 < n; k1++ ) { 
      for ( int k2 = 0; k2 < n; k2++ ) { 
        float x = (d[i][k1] - d[i][k2]);
        x = x * x;
        sum_dist += x;
        temp[tidx++] = x;
        max_dist = mcr_max(max_dist, x);
      }
    }
    qsort(temp, n_temp, sizeof(float), sort_asc_F4);
    for ( int k1 = 1; k1 < n; k1++ ) { 
      if ( temp[k1] < temp[k1-1] ) {
        printf("hello world\n");
      }
    }
    fprintf(stderr, "avg/max/5/95 distance for %d = %lf,%lf,%lf,%lf\n",i,
        sum_dist/(n*n), max_dist, 
        temp[(int)(0.95 * n_temp)],
        temp[(int)(0.05 * n_temp)]);
  }
BYE:
  free_if_non_null(temp);
  return status;
}
/*
int
main()
{
  calc_scale(NULL, 5, 6580);
}
*/
