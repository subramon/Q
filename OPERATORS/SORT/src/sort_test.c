// gcc -O4 sort_test.c -fopenmp -lgomp
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

#define THREADS 4


int cmpfunc (const void * a, const void * b) {
     return ( *(int *) a - *(int *) b );
}

void print_arr(int * arr, int num_elem) {
  for ( int i = 0; i < num_elem; i++ ) {
    printf("%d ", arr[i]);
  }
  printf("\n");
}

void copy_arr(int *src, int *dest, int num_elem) {
  for ( int i = 0; i < num_elem; i++ ) {
    dest[i] = src[i];
  }
}

void print_info(int ** info) {
  int num_partitions = 4;
  printf("info begin\n");
  for ( int i = 0; i < num_partitions; i++ ) {
    print_arr(info[i], 4);
  }
  printf("info end\n");
}


/* sorts an array of ints arr in parallel*/
int parallel_sort(int ** arr, int num_elem, int ** info, int num_partitions) {
  int * vals = *arr;
  /*first linear scan to determine count of num elem in each partition*/
  // printf("first linear scan\n");
// #pragma omp parallel for schedule(static) num_threads(THREADS)
#pragma omp parallel for 
  for ( int i = 0; i < num_partitions; i++ ) {
    for ( int j = 0; j < num_elem; j++ ) {
      if ( (vals[j] >= info[i][0]) && (vals[j] < info[i][1]) ) {
        info[i][2] += 1;
      }
    }
  }
  // print_info(info);

  /* set up info with appropriate pointers*/
  // printf("set up pointers in info\n");
  info[0][3] = 0;
#pragma omp parallel for schedule(static) num_threads(THREADS)
  for ( int i = 1; i < num_partitions; i++ ) {
    info[i][3] = info[i-1][2] + info[i-1][3];
  }
  // print_info(info);

  /* second linear scan to put elements in their appropriate buckets */
  // printf("second linear scan\n");
  int * bucketed_vals = (int *) malloc(num_elem * sizeof(int));
#pragma omp parallel for schedule(static) num_threads(THREADS)
  for ( int i = 0; i < num_partitions; i++ ) {
    for ( int j = 0; j < num_elem; j++ ) {
      if ( (vals[j] >= info[i][0]) && (vals[j] < info[i][1]) ) {
        bucketed_vals[(int) info[i][3]] = vals[j];
        info[i][3] += 1;
      }
    }
  }
  // print_arr(bucketed_vals, num_elem);
  // print_info(info);
  
  // printf("last bit of sorting\n");
  clock_t start = clock();
#pragma omp parallel for schedule(static) num_threads(THREADS)
  for ( int i = 0; i < num_partitions; i++ ) {
    int loc = (int) (info[i][3] - info[i][2]);
    qsort(&bucketed_vals[loc], info[i][2], sizeof(int), cmpfunc);
  }
  clock_t stop = clock();
  printf("core time = %d \n", stop - start);

  free(*arr);
  *arr = bucketed_vals; /*now bucketed_vals is fully sorted*/
  // print_arr(bucketed_vals, num_elem);
  // printf("arr sorted is at %p\n", *arr);
  return 1; /* indicates success */

}

int arr_equal(int * a, int * b, int num_elem) {
  for ( int i = 0; i < num_elem; i++ ) {
    if (a[i] != b[i]) {
      return 1;
    }
  }
  return 0;
}

int main() {
  printf("begin\n");
  int num_elem = 100000000;
  int * values = (int *) malloc(num_elem * sizeof(int));
  // printf("before sorting, values is located at %p\n", values);
  int * values2 = (int *) malloc(num_elem * sizeof(int));
  for ( int i = 0; i < num_elem; i++ ) {
    values[i] = rand();
  }
  // printf("values is : ");
  // print_arr(values, num_elem);
  copy_arr(values, values2, num_elem);
  // printf("values2 is : ");
  // print_arr(values2, num_elem);
  int num_partitions = 4; //must be at least 2
  int ** info = (int **) malloc(num_partitions * sizeof(int *));
  for ( int i = 0; i < 4; i++ ) {
    info[i] = (int *) malloc(4 * sizeof (int));
  }
  for ( int i = 0; i < num_partitions; i++ ) {
    int partition_size = RAND_MAX / num_partitions;
    info[i][0] = i * partition_size;
    info[i][1] = (i+1) * partition_size;
    info[i][2] = 0;
    info[i][3] = 0;
  }
  info[num_partitions - 1][1] = RAND_MAX; //added to avoid any issues with integer division
  // printf("info set up\n");


  /* parallel sort */
  printf("parallel sort\n");
  clock_t start = clock();
  parallel_sort(&values, num_elem, info, num_partitions);
  clock_t diff = clock() - start;
  int psort_msec = diff * 1000 / CLOCKS_PER_SEC; // should be 1000 for msec TODO
  printf("after sorting, values is located at %p\n", values);
  // print_arr(values, num_elem);
  /*standard lib sort*/
  printf("standard sort\n");
  start = clock();
  qsort(values2, num_elem, sizeof(int), cmpfunc);
  diff = clock() - start;
  int qsort_msec = diff * 1000 / CLOCKS_PER_SEC;
  // print_arr(values2, num_elem);
  printf("psort took %d and qsort took %d\n", psort_msec, qsort_msec);
  if (arr_equal(values, values2, num_elem) == 0) {
    printf("SUCCESS\n");
  } else {
    printf("FAILURE, arrays not equal\n");
  }
  printf("end\n");

  free(values);
  free(values2);
  for ( int i = 0; i < num_partitions; i++ ) {
    free(info[i]);
  }
  free(info);
  return 0;
}
