#include "incs.h"
#include <pthread.h>
#include "preproc_j.h"
#include "reorder.h"
#include "reorder_isp.h"
#include "get_time_usec.h"

#define REORDER     1
#define REORDER_ISP 2

typedef struct _task_info_t {
  int tid;
  uint64_t t_start;
  uint64_t t_stop;
  int what_work_to_do; // 1 => reorder 2=> reorder_isp 
  int n; // problem size
  int nT; // number of threads
} task_info_t;

typedef struct _composite_t { 
  float val;
  uint8_t goal;
} composite_t;

static int sortfn(
    const void *X, 
    const void *Y
    )
{
  const composite_t *a = (const composite_t *)X;
  const composite_t *b = (const composite_t *)Y;
  if ( a->val < b->val ) {
    return 1;
  }
  else {
    return 0;
  }
}

static void *
hammer(
  void *targs
    )
{
  int status = 0;
  task_info_t *tinfo = (task_info_t *)targs;
  float *X = NULL; // for re-sort timing comparison
  uint8_t *g = NULL; // for re-sort timing comparison

  uint64_t *Y    = NULL;
  uint64_t *tmpY = NULL;
  uint64_t *isp_tmpY = NULL;

  uint32_t *yval = NULL;
  uint8_t  *goal = NULL;
  uint32_t *from = NULL;
  
  uint32_t *pre_yval = NULL;
  uint8_t  *pre_goal = NULL;
  uint32_t *pre_from = NULL;
  
  uint32_t *post_yval = NULL;
  uint8_t  *post_goal = NULL;
  uint32_t *post_from = NULL;
  
  uint32_t *to   = NULL;
  uint32_t *isp_to   = NULL;

  uint32_t *to_split = NULL;

  uint32_t n = tinfo->n;
  uint32_t lb = 0; 
  uint32_t ub = n;

  //-----------------------------------------
  Y    = malloc(n * sizeof(uint64_t));
  tmpY = malloc(n * sizeof(uint64_t));
  isp_tmpY = malloc(n * sizeof(uint64_t));

  yval = malloc(n * sizeof(uint32_t));
  from = malloc(n * sizeof(uint32_t));
  goal = malloc(n * sizeof(uint8_t));

  pre_yval = malloc(n * sizeof(uint32_t));
  pre_from = malloc(n * sizeof(uint32_t));
  pre_goal = malloc(n * sizeof(uint8_t));

  post_yval = malloc(n * sizeof(uint32_t));
  post_from = malloc(n * sizeof(uint32_t));
  post_goal = malloc(n * sizeof(uint8_t));

  to   = malloc(n * sizeof(uint32_t));
  isp_to   = malloc(n * sizeof(uint32_t));

  to_split   = malloc(n * sizeof(uint32_t));
  // Initialization
  for ( uint32_t i = 0; i < n; i++ ) { yval[i] = i+1; }
  for ( uint32_t i = 0; i < n; i++ ) { from[i] = (n-1) - i; }
  for ( uint32_t i = 0; i < n; i++ ) { goal[i] = i % 2 ; } 
  for ( uint32_t i = 0; i < n; i++ ) { 
    Y[i] = x_mk_comp_val(from[i], goal[i], yval[i]); 
  }
  for ( uint32_t i = 0; i < n; i++ ) { tmpY[i] = 0; }
  // We decree that half the points go left, and other half go right
  uint32_t lidx = 0;
  uint32_t ridx = n / 2;
  uint32_t split_yidx = n / 2;
  uint32_t p1 = 0, p2 = n - 1;
  for ( uint32_t i = 0; i < n; ) { 
    to_split[i++] = p1++;
    to_split[i++] = p2--;
  }
  //-----------------------------------------
  if ( tinfo->what_work_to_do == REORDER ) { 
    tinfo->t_start = get_time_usec();
    reorder(Y, tmpY, to, to_split, lb, ub, split_yidx, &lidx, &ridx);
    tinfo->t_stop = get_time_usec();
  }
  //--- run ISP version
  lidx = 0;
  ridx = n / 2;
  if ( tinfo->what_work_to_do == REORDER_ISP ) { 
    tinfo->t_start = get_time_usec();
    reorder_isp(Y, isp_tmpY, isp_to, to_split, lb, ub, split_yidx, 
        &lidx, &ridx, &status);
    cBYE(status);
    tinfo->t_stop = get_time_usec();
  }
BYE:
  // Free stuff so that we have space for re-sort test 
  free(Y);
  free(tmpY);
  free(isp_tmpY);

  free(yval);
  free(goal);
  free(from);
  
  free(pre_yval);
  free(pre_goal);
  free(pre_from);
  
  free(post_yval);
  free(post_goal);
  free(post_from);
  
  free(to);
  free(isp_to);

  free(to_split);
  //-------------------------------
  return NULL;
}

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  task_info_t *tinfo = NULL;
  pthread_t *threads = NULL;
  uint32_t n = 1048576;
  int nT = 4;
  int what_work_to_do = 1;

  if ( argc >= 2 ) { 
    n  = atoi(argv[1]); 
  }
  else {
    n = 1048576; // default 
  }
  //---------------------
  if ( argc >= 3 ) { 
    nT = atoi(argv[2]); 
  }
  else {
    nT = 1; // default
  }
  //---------------------
  if ( argc >= 4 ) { 
    if ( strcmp(argv[3], "scalar") == 0 ) { 
      what_work_to_do = 1; // default 
    }
    else if ( strcmp(argv[3], "vector") == 0 ) { 
      what_work_to_do = 2;
    }
    else {
      go_BYE(-1);
    }
  }
  else {
      what_work_to_do = 1;
  }
  //---------------------

  threads = malloc(nT * sizeof(pthread_t));
  memset(threads, '\0', nT * sizeof(pthread_t));

  tinfo = malloc(nT * sizeof(task_info_t));
  for ( int i = 0; i < nT; i++ ) { 
    memset(&(tinfo[i]), 0, sizeof(task_info_t));
    tinfo[i].tid  = i;
    tinfo[i].nT  = nT;
    tinfo[i].n  = n;
    tinfo[i].what_work_to_do  = what_work_to_do;
  }
  //--------------------------------
  uint64_t t_start = get_time_usec();
  for ( int tid = 0; tid < nT; tid++ ) { // spawn threads 
    pthread_create(&(threads[tid]), NULL, hammer, (void *)(tinfo+tid));
  }
  // fprintf(stderr, "forked all threads\n");
  for ( int tid = 0; tid < nT; tid++ ) { 
    pthread_join(threads[tid], NULL);
  }
  // fprintf(stderr, "joined all threads\n");
  uint64_t t_stop = get_time_usec();
  double secs = (t_stop - t_start) / 1000000.0;
  uint64_t t_actual = 0;
  for ( int tid = 0; tid < nT; tid++ ) { 
    t_actual += (tinfo[tid].t_stop - tinfo[tid].t_start);
  }
  // fprintf(stderr, "Total  Time = %lf seconds\n", secs);
  // fprintf(stderr, "Actual Time = %lf seconds\n", t_actual/1000000.0);
  fprintf(stdout, "n=%d,", n);
  fprintf(stdout, "nT=%d,", nT);
  switch ( what_work_to_do ) { 
    case REORDER     : fprintf(stdout, "mode=scalar");  break;
    case REORDER_ISP : fprintf(stdout, "mode=vector"); break; 
    default : exit(1); break;
  }
  fprintf(stdout, ",time=%lf\n", t_actual/1000000.0);

  //--------------------------------------------
BYE:
  free(tinfo);
  free(threads);
  return status;
}
