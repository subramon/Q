#include <stdio.h>
#include <sys/mman.h>
#include "q_incs.h"
#include "_mmap.h"
#include "_rdtsc.h"
#include "qsort_asc_I4.h"

int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  char *infile = NULL;
  char *opfile1 = NULL;
  char *opfile2 = NULL;
  int max_id;
  char *X = NULL; size_t nX = 0;
  int *degree = NULL;
  int **p_degree = NULL; /* [nT] */ int nT = 0;
  FILE *ofp1 = NULL;
  FILE *ofp2 = NULL;

  if ( argc != 5 ) { go_BYE(-1); }
  infile  = argv[1];
  opfile1 = argv[2];
  opfile2 = argv[3];
  if ( strcmp(infile, opfile1) == 0 ) { go_BYE(-1); }
  if ( strcmp(opfile1, opfile2) == 0 ) { go_BYE(-1); }
  max_id = atoi(argv[4]); 
  if ( max_id <= 0 ) { go_BYE(-1); }
  int nV = max_id + 1;
  degree = malloc(nV * sizeof(int));
  return_if_malloc_failed(degree);
  memset(degree, 0, nV * sizeof(int));
  nT = omp_get_num_threads();
  p_degree = malloc(nT * sizeof(int *));
  return_if_malloc_failed(p_degree);
  for ( int tid = 0; tid < nT; tid++ ) { 
    p_degree = malloc(nV * sizeof(int));
    return_if_malloc_failed(p_degree);
    memset(p_degree, 0, nV * sizeof(int));
  }
  //-----------------------
  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  uint64_t n = nX / sizeof(int);
  int *E = (int *)X;
  uint64_t t_start = RDTSC();
  uint64_t block_size = n / nT;
  fprintf(stderr, "Starting %d threads\n", nT);
#pragma omp parallel for schedule(static)
  for ( int tid = 0; tid < nT; tid++ ) { 
    uint64_t lb = tid * block_size;
    uint64_t ub = lb + block_size;
    if ( tid == (nT-1) ) { ub = n; }
    for ( uint64_t i = lb; i < ub; i++ ) {
      int node_id = E[i];
#ifdef DEBUG
      if ( ( node_id < 0 ) || ( node_id >= max_id ) ) { 
        fprintf(stderr, "node_id = %d \n", node_id);
        go_BYE(-1);
      }
      if ( ( i % 10000000 ) == 0 ) { 
        fprintf(stderr, "Processed %lf \n", (double)i);
      }
#endif
// EXPERIMENTAL #pragma omp atomic update
      p_degree[node_id]++;
    }
  }
  uint64_t t_stop = RDTSC();
  fprintf(stderr, "Successfully calculated degrees in time %lf\n",
      (t_stop - t_start)/(2500.0*1000000.0));
  ofp1 = fopen(opfile1, "wb");
  return_if_fopen_failed(ofp1, opfile1, "wb");

  ofp2 = fopen(opfile2, "wb");
  return_if_fopen_failed(ofp2, opfile2, "wb");

  int real_nV = 0;
  for ( int i = 0; i < nV; i++ ) { 
    if ( degree[i] > 0 ) {
      fwrite(&i,       sizeof(int), 1,  ofp1);
      fwrite(degree+i, sizeof(int), 1,  ofp2);
      real_nV++;
    }
  }
  fclose_if_non_null(ofp1);
  fclose_if_non_null(ofp2);
  mcr_rs_munmap(X, nX);
  fprintf(stderr, "Wrote %d degrees \n", real_nV);

  status = rs_mmap(opfile2, &X, &nX, 1);
  int *x_degree = (int *)X;
  t_start = RDTSC();
  qsort_asc_I4(x_degree, real_nV, sizeof(int), NULL);
  t_stop = RDTSC();
  mcr_rs_munmap(X, nX);
  fprintf(stderr, "Sorted in %lf  \n", 
      (t_stop - t_start)/(2800.0*1000000.0));
BYE:
  mcr_rs_munmap(X, nX);
  free_if_non_null(degree);
  if ( p_degree != NULL ) { 
    for ( int tid = 0; tid < nT; tid++ ) { 
      free_if_non_null(p_degree[tid]);
    }
  }
  free_if_non_null(p_degree);
  fclose_if_non_null(ofp1);
  fclose_if_non_null(ofp2);
  return status;
}
