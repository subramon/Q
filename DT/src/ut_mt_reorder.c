#include "incs.h"
#include <pthread.h>
#include "preproc_j.h"
#include "check.h"
#include "reorder.h"
#include "reorder_isp.h"
#include "get_time_usec.h"
#include "qsort_asc_val_F4_idx_I1.c"

#define REORDER     1
#define REORDER_ISP 2
#define RE_SORT     3


typedef struct _task_info_t {
  int tid;
  uint64_t t_start;
  uint64_t t_stop;
  int what_work_to_do; // 1 => reorder 2=> reorder_isp 3=> re-sort
  int n; // problem size
  int nT; // number of threads
} task_info_t;

config_t g_C;

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
  composite_t *tmpXg = NULL; // for re-sort timing comparison
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

#ifdef SEQUENTIAL
  g_num_swaps = 0;
#endif
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
    status=reorder(Y, tmpY, to, to_split, lb, ub, split_yidx, &lidx, &ridx);
    cBYE(status);
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
  X = malloc(n * sizeof(float));
  return_if_malloc_failed(X);
  tmpXg = malloc(n * sizeof(composite_t));
  return_if_malloc_failed(tmpXg);
  g = malloc(n * sizeof(uint8_t));
  return_if_malloc_failed(g);
  // set some random values for X
  for ( uint32_t i = 0; i < n; i++ ) { 
    X[i] = random();
    g[i] = random() & 0x1; // randomly set to 0 or 1 
  }
  if ( tinfo->what_work_to_do == RE_SORT ) {
    tinfo->t_start = get_time_usec();
    // Using a buffer, tmpXg
    // move the left points to one side and the right points to the other
    lidx = 0;
    ridx = n/2;
    bool is_left = true;
    for ( uint32_t i = 0; i < n; i++ ) { 
      if ( is_left ) { 
        tmpXg[lidx].val  = X[i];
        tmpXg[lidx].goal = g[i];
        lidx++;
        is_left = false;
      }
      else {
        tmpXg[ridx].val  = X[i];
        tmpXg[ridx].goal = g[i];
        ridx++;
        is_left = true;
      }
    }
    // sort the buffer
    qsort (tmpXg, n, sizeof(composite_t), sortfn);
    // move the points back from the buffer
    for ( uint32_t i = 0; i < n; i++ ) { 
      X[i] = tmpXg[i].val;
      g[i] = tmpXg[i].goal;
    }
    tinfo->t_stop = get_time_usec();
  }

BYE:
  free_if_non_null(X);
  free_if_non_null(g);
  free_if_non_null(tmpXg);

  // Free stuff so that we have space for re-sort test 
  free_if_non_null(Y);
  free_if_non_null(tmpY);
  free_if_non_null(isp_tmpY);

  free_if_non_null(yval);
  free_if_non_null(goal);
  free_if_non_null(from);
  
  free_if_non_null(pre_yval);
  free_if_non_null(pre_goal);
  free_if_non_null(pre_from);
  
  free_if_non_null(post_yval);
  free_if_non_null(post_goal);
  free_if_non_null(post_from);
  
  free_if_non_null(to);
  free_if_non_null(isp_to);

  free_if_non_null(to_split);
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
  uint32_t n = 65536;
  int nT = 2;
  int what_work_to_do = 1;

  if ( argc >= 2 ) { n  = atoi(argv[1]); }
  if ( argc >= 3 ) { nT = atoi(argv[2]); }
  if ( argc >= 4 ) { what_work_to_do = atoi(argv[3]); }

  printf("n=%d,", n);
  printf("nT=%d,", nT);
  switch ( what_work_to_do ) { 
    case REORDER : printf("reorder\n");  break;
    case REORDER_ISP : printf("reorder_isp\n"); break; 
    case RE_SORT : printf("re_sort\n");  break;
    default : go_BYE(-1); break;
  }

  if ( argc == 2 ) { nT = atoi(argv[1]); }

  threads = malloc(nT * sizeof(pthread_t));
  return_if_malloc_failed(threads);
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
  fprintf(stderr, "Total  Time = %lf seconds\n", secs);
  fprintf(stderr, "Actual Time = %lf seconds\n", t_actual/1000000.0);
  //--------------------------------------------
BYE:
  free_if_non_null(tinfo);
  free_if_non_null(threads);
  return status;
}
