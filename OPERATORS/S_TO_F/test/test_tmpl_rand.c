#include <stdio.h>
#include <stdlib.h>
//#include "../src/tmpl_rand.h"
#include "../gen_inc/_rand_I4.h"
//#include <stdbool.h>
//#include <stdint.h>

int
main()
{
  int status = 0;
  /*int status = 0;
  uint64_t n = 10;
  double *vec = (double*) malloc(n * sizeof(double));
  double lb = 1.3;
  double ub = 4.5;

  RANDOM_F8_REC_TYPE args;
  args.seed = 0;
  args.lb = lb;
  args.ub = ub;
  status = random_F8(vec, n, &args, true);
  for ( uint64_t i = 0; i < n; i++ ) {
    if ( vec[i] < lb || vec[i] > ub) {
      printf("FAILURE\n");
      return status;
    }
  }
  printf("SUCCESS\n");
  free(vec);*/
  //---------------------------------
//#ifdef LATER
  RAND_I4_REC_TYPE argsy;
  uint32_t n = 1024;
  uint32_t len = 10240000;
  int ctr[n]; 
  int lb = 0;
  int ub = n - 1;

  argsy.seed = 0;

  int32_t *y = malloc(len * sizeof(int32_t));
  return_if_malloc_failed(y);

  argsy.lb = lb;
  argsy.ub = ub;
  status = rand_I4(y, len, &argsy, 0);
  for ( unsigned int i = 0; i < n; i++ ) { ctr[i]= 0; }
  for ( uint64_t i = 0; i < len; i++ ) {
    if ( y[i] < lb || y[i] > ub ) {
      printf("FAILURE\n");
      return status;
    }
    ctr[y[i]] += 1;
  }
/*
  for ( uint64_t i = 0; i < n; i++ ) {
    printf("%d ", y[i]);
    printf("count %d\n", ctr[i]);
  }*/
  printf("\n");

  bool print_warning = false;
  int num_bad = 0;
  for ( unsigned int i = 0; i < n; i++ ) {
    if ( ctr[i] < (0.9*len)/n || ctr[i] > (1.1*len)/n ) {
      print_warning = true;
      num_bad += 1;
    }
  }
  if(print_warning) {
    printf("WARNING: uniformity is a bit off\n");
    printf("Num bad is %d\n", num_bad);
  }
  else {
    printf("Uniformity is good");
  }
  printf("\n");
  //---------------------------------
//#endif
BYE:
  free_if_non_null(y);
  return status;
}
