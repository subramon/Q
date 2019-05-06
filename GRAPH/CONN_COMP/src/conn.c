#include <omp.h>
#include <stdio.h>
#include <sys/mman.h>
#include "q_incs.h"
#include "_mmap.h"
#include "_rdtsc.h"

#define MAX_CHAIN_LENGTH 1024
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
  int *new_E = NULL;
  char *X = NULL; size_t nX = 0;
  int *rep = NULL; // representative
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
  // Make this a multiple of 2
  if ( ( nV % 2 ) != 0 ) { nV++; }
  if ( ( nV % 2 ) != 0 ) { go_BYE(-1); }
  rep = malloc(nV * sizeof(int));
  return_if_malloc_failed(rep);
#pragma omp parallel for
  for ( int i = 0; i < nV; i++ ) { 
    rep[i] = i;
  }
  //-----------------------
  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  uint64_t nE = nX / sizeof(int);
  // Note that nE is a multiple of 2 and TWICE the number of edges
  int *E = (int *)X;
  uint64_t t_start = RDTSC();
  omp_set_num_threads(4);
  int nT = omp_get_num_threads();
  uint64_t num_changes = 1; // to get into loop
  for ( int iter = 1; num_changes != 0 ; iter++ ) {
    int n_blocks = ( nE / nV ) / 4 ; // TODO: We are going to vary the 4
    uint64_t block_size = nE / n_blocks;
    uint64_t loop1 = 0, loop2 = 0;
    num_changes = 0;
    uint64_t l_num_changes = 0;
    uint64_t t1;
    uint64_t t_start = RDTSC();
    uint64_t num_dead_edges = 0;
    uint64_t num_exst_edges = 0;
    uint64_t num_live_edges = 0;
    fprintf(stderr, "Iteration %d \n", iter);
    for ( uint64_t b = 0; b < n_blocks; b++ ) {
      uint64_t lb = b  * block_size;
      uint64_t ub = lb + block_size;
      if ( b == (n_blocks-1) ) { ub = nE; }
      t1 = RDTSC();
      for ( uint64_t e = lb; e < ub; e += 2 ) {
        num_exst_edges++;
        int from = E[e];
        int to   = E[e+1];
        int from_rep = rep[from];
        int to_rep   = rep[to];
        if ( from_rep < to_rep ) {
          rep[to] = from_rep;
          num_changes++;
          num_live_edges++;
        }
        else if ( to_rep < from_rep ) {
          rep[from] = to_rep;
          num_changes++;
          num_live_edges++;
        }
        else {
          if ( ( from_rep != from ) && ( to_rep != to ) ) {
            num_dead_edges++;
          }
        }
      }
      loop1 += RDTSC() - t1;
      int x_n_blocks = nT;
      int x_block_size = nV / x_n_blocks;
      t1 = RDTSC();
// #pragma omp parallel for schedule(static, 1)
      for ( int xb = 0; xb < x_n_blocks; xb++ ) {
        int x_lb = xb    * x_block_size;
        int x_ub = x_lb + x_block_size;
        if ( xb == (x_n_blocks-1) ) { x_ub = nV; }
        // fprintf(stderr, "starting jumping loop\n");
        for ( int i = x_lb; i < x_ub; i++ ) {
          int chain[MAX_CHAIN_LENGTH];
#undef V1
#ifdef V1
          int parent = rep[i];
          if ( i != parent ) { 
            int grand_parent = rep[parent];
            if ( parent != grand_parent ) { 
              rep[i] = grand_parent;
              l_num_changes++;
            }
          }
#else
          int me = i;
          int parent = rep[i];
          int chain_idx = 0;
          while ( me != parent ) { 
            if ( chain_idx < MAX_CHAIN_LENGTH ) { 
              chain[chain_idx++] = parent;
            }
            me = parent, parent = rep[parent];
          }
          if ( parent != i ) { 
            l_num_changes++;
            rep[i] = parent;
            for ( int j = 0; j < chain_idx; j++ ) { 
              rep[chain[j]] = parent;
            }
          }
#endif
        }
        // fprintf(stderr, "stopping jumping loop\n");
      }
      loop2 += RDTSC() - t1;
    }
    fprintf(stderr, "num_dead_edges     = %lf \n", (double)num_dead_edges);
    fprintf(stderr, "num_live_edges     = %lf \n", (double)num_live_edges);
    fprintf(stderr, "num_exst_edges     = %lf \n", (double)num_exst_edges);
    fprintf(stderr, "Time loop1         = %lf \n", (double)loop1);
    fprintf(stderr, "Time loop2         = %lf \n", (double)loop2);
    fprintf(stderr, "Loop 1 num_changes = %lf \n", (double)num_changes);
    fprintf(stderr, "Loop 2 num_changes = %lf \n", (double)l_num_changes);
    uint64_t t_stop = RDTSC();
    fprintf(stderr, "Time               = %lf \n", 
        (t_stop - t_start)/(2800.0*1000000.0));
    fprintf(stderr, "==============================\n");
    if ( ( (double)num_live_edges / (double)num_exst_edges ) < 0.1 ) {
      fprintf(stderr, "Condensing\n");
      free_if_non_null(new_E);
      int *new_E = malloc(num_live_edges * 2 * sizeof(int));
      uint64_t eidx = 0;
      uint64_t num_ignore = 0;
      for ( uint64_t i = 0; i < nE; i += 2 ) { 
        int from = E[i];
        int to   = E[i+1];
        int from_rep = rep[from];
        int to_rep   = rep[to];
        if ( (from_rep == to_rep ) && ( from_rep != from ) && 
            ( to_rep != to ) ) {
          /* ignore this edge */
          num_ignore++;
        }
        else {
          new_E[eidx++] = from;
          new_E[eidx++] = to;
        }
      }
      free_if_non_null(new_E); // TODO Should actually use it 
      fprintf(stderr, "num_ignore = %lf \n", (double)num_ignore);
      fprintf(stderr, "new_nE     = %lf \n", (double)eidx);
    }
  }
  uint64_t t_stop = RDTSC();
  fprintf(stderr, "Successfully calculated reps in time %lf\n",
      (t_stop - t_start)/(2800.0*1000000.0));
  ofp1 = fopen(opfile1, "wb");
  return_if_fopen_failed(ofp1, opfile1, "wb");

  ofp2 = fopen(opfile2, "w");
  return_if_fopen_failed(ofp2, opfile2, "w");

  for ( int i = 0; i < nV; i++ ) { 
    if ( rep[i] > 0 ) {
      fwrite(&i,       sizeof(int), 1,  ofp1);
      fprintf(ofp2, "%d\n", rep[i]);
      /*
      fwrite(rep+i, sizeof(int), 1,  ofp2);
      */
    }
  }
  fprintf(stderr, "Wrote answer \n");
BYE:
  mcr_rs_munmap(X, nX);
  free_if_non_null(rep);
  free_if_non_null(new_E);
  fclose_if_non_null(ofp1);
  fclose_if_non_null(ofp2);
  return status;
}
