#include <sys/time.h>
#include "q_incs.h"
#include "dnn_types.h"
#include "core_dnn.h"
#include "fstep_a.h"
#include "bstep.h"
#include "update_W_b.h"
#include <malloc.h>

#define BITS_IN_VEC_REG 256
#define MEMALIGN_BATCH 32

#ifdef RASPBERRY_PI
static uint64_t 
get_time_usec(
    void
    )
{
  struct timeval Tps; 
  struct timezone Tpf;
  gettimeofday (&Tps, &Tpf);
  return ((uint64_t )Tps.tv_usec + 10000000* (uint64_t )Tps.tv_sec);
}
#endif
static uint64_t
RDTSC(
    void
    )
//STOP_FUNC_DECL  
{
#ifdef RASPBERRY_PI
  return get_time_usec();
#else
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}
static int 
set_dropout(
    bool *d, /* [num neurons ] */
    float dpl,  /* probability of dropout */
    int n       /* num neurons */
    )
{
  int status = 0;
  if ( d == NULL ) { go_BYE(-1); }
  if ( n <= 0    ) { go_BYE(-1); }
  if ( dpl < 0 ) { go_BYE(-1); }
  if ( dpl >= 1 ) { go_BYE(-1); }
  for ( int i = 0; i < n; i++ ) { d[i] = false; }
  if ( dpl > 0 ) { 
    for ( int i = 0; i < n; i++ ) { 
      double dtemp = drand48();
      if ( dtemp > dpl ) { 
        d[i] = true; // ith neuron will be dropped
      }
    }
  }
  // TODO: Make sure at least one node is alive after dropout
BYE:
  return status;
}

static void
free_da(
    int nl,
    int *npl,
    float ****ptr_z
    )
{
  /*
  float ***z = *ptr_z;
  TODO

  *ptr_z = NULL;
*/
}

//----------------------------------------------------
static void
free_z_a(
    int nl, 
    int *npl,
    float ****ptr_z
    )
{
  /*
  float ***z = *ptr_z;
  TODO

  *ptr_z = NULL;
*/
}
//----------------------------------------------------
static int
check_W_b(
    int nl, 
    int *npl, 
    float ***W,
    float ***Wprime,
    float **b,
    float **bprime
    )
{
  int status = 0;

  if ( W == Wprime ) { go_BYE(-1); }
  if ( b == bprime ) { go_BYE(-1); }
  for ( int i = 1; i < nl; i++ ) {
    for ( int j = 0; j < npl[i-1]; j++ ) { // for neurons in previous layer
      for ( int jprime = 0; jprime < npl[i]; jprime++ )  { // for neurons in current layer
        // printf("W = %f \t Wprime = %f \n", W[i][j][jprime], Wprime[i][j][jprime]);
        if ( ( fabs(W[i][j][jprime] - Wprime[i][j][jprime]) /
               fabs(W[i][j][jprime] + Wprime[i][j][jprime]) ) > 0.0001 ) {
          printf("difference in W at [%d][%d][%d]\n", i, j, jprime);
          printf("expected=%f\t actual=%f\n", W[i][j][jprime], Wprime[i][j][jprime]);
          go_BYE(-1);
        }
      }
    }

    for ( int j = 0; j < npl[i]; j++ ) { // for neurons in current layer
      // printf("b = %f \t bprime = %f \n", b[i][j], bprime[i][j]);
      if ( ( fabs(b[i][j] - bprime[i][j]) /
             fabs(b[i][j] + bprime[i][j]) ) > 0.0001 ) {
        printf("difference in b at [%d][%d]\n", i, j);
        printf("expected=%f\t actual=%f\n", b[i][j], bprime[i][j]);
        go_BYE(-1);
      }
    }
  }
BYE:
  return status;
}
//----------------------------------------------------
static int
check_z_a(
    int nl, 
    int *npl, 
    int bsz, 
    float ***z,
    float ***zprime
    )
{
  int status = 0;
  if ( z == zprime ) { go_BYE(-1); }
  for ( int i = 1; i < nl; i++ ) { 
    for ( int j = 0; j < npl[i]; j++ ) { 
      for ( int k = 0; k < bsz; k++ )  {
        // printf("%f:%f \n", z[i][j][k], zprime[i][j][k]);
        if ( ( fabs(z[i][j][k] - zprime[i][j][k]) /  
               fabs(z[i][j][k] + zprime[i][j][k]) ) > 0.0001 ) { 
          printf("difference [%d][%d][%d]\n", i, j, k); 
          go_BYE(-1); 
        }
      }
    }
  }
BYE:
  return status;
}

static int
init_b(
    int nl,
    int *npl,
    float **ptr_b
    )
{
  int status = 0;
  for ( int l = 1; l < nl; l++ ) {
    for ( int j = 0; j < npl[l]; j++ ) {
      float num = (0.01 - (-0.01)) * ( (float)rand() / (float)RAND_MAX ) + (-0.01);
      ptr_b[l][j] = num;
    }
  }
BYE:
  return status;
}

static int
malloc_b(
    int nl,
    int *npl,
    float ***ptr_b
    )
{
  int status = 0;
  float **b = NULL;
  b = memalign(MEMALIGN_BATCH, nl * sizeof(float *));
  return_if_malloc_failed(b);
  b[0] = NULL;
  for ( int l = 1; l < nl; l++ ) { 
    int L_next = npl[l];
    b[l] = memalign(MEMALIGN_BATCH, L_next * sizeof(float));
    return_if_malloc_failed(b[l]);
  }
  *ptr_b = b;
  status = init_b(nl, npl, *ptr_b);
BYE:
  return status;
}

static int
init_W(
    int nl,
    int *npl,
    float ***ptr_W
    )
{
  int status = 0;
  for ( int l = 1; l < nl; l++ ) {
    for ( int j = 0; j < npl[l-1]; j++ ) {
      for ( int jprime = 0; jprime < npl[l]; jprime++ ) {
        float num = (0.01 - (-0.01)) * ( (float)rand() / (float)RAND_MAX ) + (-0.01);
        ptr_W[l][j][jprime] = num;
      }
    }
  }
BYE:
  return status;
}

static int
malloc_W(
    int nl,
    int *npl,
    float ****ptr_W
    )
{
  int status = 0;
  float *** W = NULL;
  W = memalign(MEMALIGN_BATCH, nl * sizeof(float **));
  return_if_malloc_failed(W);
  W[0] = NULL;
  for ( int l = 1; l < nl; l++ ) { 
    int L_prev = npl[l-1];
    int L_curr = npl[l];
    W[l] = memalign(MEMALIGN_BATCH, L_prev * sizeof(float *));
    return_if_malloc_failed(W[l]);
    for ( int j = 0; j < L_prev; j++ ) { 
      W[l][j] = memalign(MEMALIGN_BATCH, L_curr * sizeof(float));
      return_if_malloc_failed(W[l][j]);
    }
  }
  *ptr_W = W;
  status = init_W(nl, npl, *ptr_W);
BYE:
  return status;
}
//----------------------------------------------------
static int
malloc_z_a(
    int nl, 
    int *npl, 
    int bsz, 
    float ****ptr_z)
{
  int status = 0;
  float ***z = *ptr_z = NULL;
  z = memalign(MEMALIGN_BATCH, nl * sizeof(float **));
  return_if_malloc_failed(z);
  memset(z, '\0', nl * sizeof(float **));

  z[0] = NULL;
  for ( int i = 1; i < nl; i++ ) { 
    z[i] = memalign(MEMALIGN_BATCH, npl[i] * sizeof(float *));
    return_if_malloc_failed(z[i]);
    memset(z[i], '\0', npl[i] * sizeof(float *));
  }
  for ( int i = 1; i < nl; i++ ) {
    // TODO: add pragma omp here
    for ( int j = 0; j < npl[i]; j++ ) { 
      z[i][j] = memalign(MEMALIGN_BATCH, bsz * sizeof(float));
      return_if_malloc_failed(z[i][j]);
      memset(z[i][j], '\0', bsz * sizeof(float));
    }
  }
  *ptr_z = z;
BYE:
  return status;
}

//----------------------------------------------------
int
dnn_check(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;

  if ( ptr_X == NULL ) { go_BYE(-1); }
  int nl = ptr_X->nl;
  int    *npl = ptr_X->npl;
  float  *dpl = ptr_X->dpl;
  float  ***W = ptr_X->W;
  float  **b = ptr_X->b;
  float ***a = ptr_X->z;
  float ***z = ptr_X->z;
  __act_fn_t *A = ptr_X->A;
  //-------------------------
  if ( ( a == NULL ) && ( z != NULL ) ) { go_BYE(-1); }
  if ( ( a != NULL ) && ( z == NULL ) ) { go_BYE(-1); }
  if ( a != NULL ) { 
    if ( a[0] != NULL ) { go_BYE(-1); }
    if ( z[0] != NULL ) { go_BYE(-1); }
    for ( int l = 1; l < nl; l++ ) { 
      if ( a[l] == NULL ) { go_BYE(-1); }
      if ( z[l] == NULL ) { go_BYE(-1); }
      for ( int j = 0; j < npl[l]; j++ ) { 
        if ( a[l][j] == NULL ) { go_BYE(-1); }
        if ( z[l][j] == NULL ) { go_BYE(-1); }
      }
    }
  }

  if ( nl < 3 ) { go_BYE(-1); }
  //-----------------------------------
  if ( npl == NULL ) { go_BYE(-1); }
  for ( int i = 0; i < ptr_X->nl; i++ ) { 
    if ( npl[i] < 1 ) { go_BYE(-1); 
    }
  }
  //-----------------------------------
  if ( dpl == NULL ) { go_BYE(-1); }
  for ( int i = 0; i < ptr_X->nl; i++ ) { 
    if ( dpl[i] > 1 ) { go_BYE(-1); 
    }
  }
  //-----------------------------------
  if ( A == NULL ) { go_BYE(-1); }
  //-----------------------------------
  if ( W == NULL ) { go_BYE(-1); }
  if ( W[0] != NULL ) { go_BYE(-1); }
  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    if ( W[lidx] == NULL ) { go_BYE(-1); }
    int L_prev = npl[lidx-1];
    for ( int j = 0; j < L_prev; j++ ) { 
      if ( W[lidx][j] == NULL ) { go_BYE(-1); }
    }
  }
  //-----------------------------------
  if ( b == NULL ) { go_BYE(-1); }
  if ( b[0] != NULL ) { go_BYE(-1); }
  for ( int lidx = 1; lidx < nl; lidx++ ) { 
    if ( b[lidx] == NULL ) { go_BYE(-1); }
  }
BYE:
  return status;
}
//----------------------------------------------------
int
dnn_delete(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
  status = dnn_free(ptr_X); cBYE(status);
BYE:
  return status;
}
//----------------------------------------------------
int
dnn_test(
    DNN_REC_TYPE *ptr_dnn,
    float ** const cptrs_in,
    float *out
    )
{
  int status = 0;
  int    nl    = ptr_dnn->nl;
  int    *npl  = ptr_dnn->npl;
  float  ***W  = ptr_dnn->W;
  float   **b  = ptr_dnn->b;
  bool     **d = ptr_dnn->d;
  float   *dpl = ptr_dnn->dpl;
  float   ***z = ptr_dnn->z;
  float   ***a = ptr_dnn->a;
  __act_fn_t  *A = ptr_dnn->A;

  if ( W   == NULL ) { go_BYE(-1); }
  if ( b   == NULL ) { go_BYE(-1); }
  if ( a   == NULL ) { go_BYE(-1); }
  if ( d   == NULL ) { go_BYE(-1); }
  if ( dpl == NULL ) { go_BYE(-1); }
  if ( z   == NULL ) { go_BYE(-1); }
  if ( npl == NULL ) { go_BYE(-1); }
  if ( nl  <  3    ) { go_BYE(-1); }

  //========= START - forward propagation =========
  uint64_t t_end = 0, t_start = RDTSC();
  float **in;
  float **out_z;
  float **out_a;
  for ( int l = 1; l < nl; l++ ) { // For each layer
    // Note that loop starts from 1, not 0
    in  = a[l-1];
    out_z = z[l];
    out_a = a[l];
    if ( l == 1 ) {
      in = cptrs_in;
      if ( a[l-1] != NULL ) { go_BYE(-1); }
      if ( z[l-1] != NULL ) { go_BYE(-1); }
    }
    if ( l == 1 ) {
      status = set_dropout(d[l-1], dpl[l-1], npl[l-1]); cBYE(status);
    }
    status = set_dropout(d[l],   dpl[l],   npl[l]); cBYE(status);
    status = fstep_a(in, W[l], b[l],
        d[l-1], d[l], out_z, out_a, 1, npl[l-1], npl[l], A[l]);
    cBYE(status);
  }
  //TODO: handle it properly, for now assuming one neuron in last layer
  *out = a[nl-1][0][0];
  t_end = RDTSC();
  //========= STOP - forward propagation =========
  // fprintf(stdout, "C test cycles  = %" PRIu64 "\n", (t_end-t_start));

BYE:
  return status;
}
//----------------------------------------------------
int
dnn_train(
    DNN_REC_TYPE *ptr_dnn,
    float ** const cptrs_in, /* [npl[0]][nI] */
    float ** const cptrs_out, /* [npl[nl-1]][nI] */
    uint64_t nI // number of instances
    )
{
  int status = 0;
  int batch_size = ptr_dnn->bsz;
  int nl = ptr_dnn->nl;
  int    *npl  = ptr_dnn->npl;
  float  ***W  = ptr_dnn->W;
  float   **b  = ptr_dnn->b;
  float  ***dW = ptr_dnn->dW;
  float   **db = ptr_dnn->db;
  bool     **d = ptr_dnn->d;
  float   *dpl = ptr_dnn->dpl;
  float   ***z = ptr_dnn->z;
  float   ***a = ptr_dnn->a;
  float   ***dz = ptr_dnn->dz;
  float   ***da = ptr_dnn->da;
#ifdef TEST_VS_PYTHON
  float   ***zprime = ptr_dnn->zprime;
  float   ***aprime = ptr_dnn->aprime;
  float   ***Wprime = ptr_dnn->Wprime;
  float    **bprime = ptr_dnn->bprime;
#endif
  __act_fn_t  *A = ptr_dnn->A;
  __bak_act_fn_t  *bak_A = ptr_dnn->bak_A;

  if ( W   == NULL ) { go_BYE(-1); }
  if ( b   == NULL ) { go_BYE(-1); }
  if ( a   == NULL ) { go_BYE(-1); }
  if ( d   == NULL ) { go_BYE(-1); }
  if ( dpl == NULL ) { go_BYE(-1); }
  if ( z   == NULL ) { go_BYE(-1); }
  if ( npl == NULL ) { go_BYE(-1); }
  if ( nl  <  3    ) { go_BYE(-1); }
  if ( batch_size <= 0 ) { go_BYE(-1); }

  int num_batches = nI / batch_size;
  if ( ( num_batches * batch_size ) != (int)nI ) {
    num_batches++;
  }

  srand48(RDTSC());
  t_fstep = 0;
  t_bstep = 0;
  for ( int bidx = 0; bidx < num_batches; bidx++ ) {
    int lb = bidx  * batch_size;
    int ub = lb + batch_size;
    if ( bidx == (num_batches-1) ) { ub = nI; }
    if ( ( ub - lb ) > batch_size ) { go_BYE(-1); }

    //========= START - forward propagation =========
    uint64_t delta = 0, t_start = RDTSC();
    float **in;
    float **out_z;
    float **out_a;
    for ( int l = 1; l < nl; l++ ) { // For each layer
      // Note that loop starts from 1, not 0
      in  = a[l-1];
      out_z = z[l];
      out_a = a[l];
      if ( l == 1 ) { 
        in = cptrs_in;
        if ( bidx != 0 ) {
          for ( int j = 0; j < npl[0]; j++ ) {
            in[j] += batch_size;
          }
        }
        if ( a[l-1] != NULL ) { go_BYE(-1); }
        if ( z[l-1] != NULL ) { go_BYE(-1); }
      }
      // WRONG      if ( l == nl-1 ) { out = cptrs_out; }
      /* the following if condition is important. To see why,
       * A: when l=1, we set dropouts for layer 0, 1 
       * B: when l=2, we set dropouts for layer 1, 2
       * but B would over-write the dropouts we set in A
       * this will cause errors */

      if ( l == 1 ) { 
        status = set_dropout(d[l-1], dpl[l-1], npl[l-1]); cBYE(status);
      }
      status = set_dropout(d[l],   dpl[l],   npl[l]); cBYE(status);
      status = fstep_a(in, W[l], b[l], 
          d[l-1], d[l], out_z, out_a, (ub-lb), npl[l-1], npl[l], A[l]);
      cBYE(status);
    }
    delta = RDTSC() - t_start; if ( delta > 0 ) { t_fstep += delta; }
    //========= STOP - forward propagation =========

#ifdef TEST_VS_PYTHON
    status = check_z_a(nl, npl, batch_size, z, zprime); cBYE(status);
    status = check_z_a(nl, npl, batch_size, a, aprime); cBYE(status);
    printf("SUCCESS for forward pass\n"); 
#endif

#define ALPHA 0.0075 // TODO This is a user supplied parameter

    //========= START - backward propagation =========
    t_start = RDTSC();
    float **da_last = da[nl-1];
    float **a_last  =  a[nl-1];
    float **out = cptrs_out;
    status = compute_da_last(a_last, out, da_last, npl[nl-1], (ub-lb));
    cBYE(status);
    // da for the last layer has been computed

    for ( int l = nl-1; l > 0; l-- ) { // for layer, starting from last
      float **z_l = z[l];
      float **dz_l = dz[l];
      float **da_l = da[l];
      float **W_l = W[l];
      float **dW_l = dW[l];
      float *db_l = db[l];
      float **a_prev_l = a[l-1];
      float **da_prev_l = da[l-1];

      if ( l == 1 ) {
        a_prev_l = cptrs_in; // a[0] is NULL
      }

      status = bstep(z_l, a_prev_l, W_l, da_l, dz_l, 
          da_prev_l, dW_l, db_l, npl[l], npl[l-1], (ub-lb), bak_A[l]);
      cBYE(status);
    }
    delta = RDTSC() - t_start; if ( delta > 0 ) { t_bstep += delta; }
    //========= STOP - backward propagation =========
    //========= START - update 'W' and 'b' =========
    t_start = RDTSC();
    status = update_W_b(W, dW, b, db, nl, npl, d, ALPHA); cBYE(status);
    delta = RDTSC() - t_start; if ( delta > 0 ) { t_bstep += delta; }
    //========= STOP - update 'W' and 'b' =========

    // To get the correct count, comment out all pragma omp
#ifdef COUNT
    printf("num flops forward pass  = %" PRIu64 "\n", num_f_flops);
    printf("num flops backward pass = %" PRIu64 "\n", num_b_flops);
    printf("batch %d completed, [%d, %d]\n", bidx, lb, ub);
#endif
#ifdef TEST_VS_PYTHON
    status = check_W_b(nl, npl, W, Wprime, b, bprime); cBYE(status);
    printf("SUCCESS for backward pass\n"); 
    exit(0);
#endif
  }
#ifdef COUNT
  printf("num flops forward pass  = %" PRIu64 "\n", num_f_flops);
  printf("num flops backward pass = %" PRIu64 "\n", num_b_flops);
  printf("total num flops         = %" PRIu64 "\n", 
        (num_f_flops+num_b_flops));
#endif

  fprintf(stdout, "fcycles  = %" PRIu64 "\n", t_fstep);
  fprintf(stdout, "bcycles  = %" PRIu64 "\n", t_bstep);
  fprintf(stdout, "tcycles  = %" PRIu64 "\n", (t_fstep+t_bstep));
  fprintf(stdout, " time    = %lf \n", (t_fstep+t_bstep) / (2.5 * 1000 * 1000));
BYE:
  return status;
}

//----------------------------------------------------
int
dnn_free(
    DNN_REC_TYPE *ptr_X
    )
{
  int status = 0;
  if ( ptr_X == NULL ) { go_BYE(-1); }
  if ( ptr_X->nl < 3 ) { go_BYE(-1); }
  int nl = ptr_X->nl;
  int *npl    = ptr_X->npl;
  float  ***W = ptr_X->W;
  float   **b = ptr_X->b;
  bool **d = ptr_X->d;

  //---------------------------------------
  if ( W != NULL ) { 
    for ( int lidx = 1; lidx < nl; lidx++ ) { 
      int L_prev = npl[lidx-1];
      for ( int j = 0; j < L_prev; j++ ) { 
        free_if_non_null(W[lidx][j]);
      }
      free_if_non_null(W[lidx]);
    }
    free_if_non_null(W);
  }
  //---------------------------------------
  if ( b != NULL ) { 
    for ( int lidx = 1; lidx < nl; lidx++ ) { 
      free_if_non_null(b[lidx]);
    }
    free_if_non_null(b);
  }
  //---------------------------------------
  if ( d != NULL ) { 
    for ( int lidx = 0; lidx < nl; lidx++ ) { 
      free_if_non_null(d[lidx]);
    }
    free_if_non_null(d);
  }
  //---------------------------------------
  free_if_non_null(ptr_X->npl);
  free_if_non_null(ptr_X->dpl);
  // fprintf(stderr, "garbage collection done\n");

BYE:
  return status;
}
//----------------------------------------------------
int dnn_unset_bsz(
    DNN_REC_TYPE *ptr_dnn
    )
{
  int status = 0;
  float ***z = ptr_dnn->z;
  float ***a = ptr_dnn->a;
  float ***dz = ptr_dnn->dz;
  float ***da = ptr_dnn->da;
  int nl = ptr_dnn->nl;
  int *npl = ptr_dnn->npl;
  free_z_a(nl, npl, &z); 
  free_z_a(nl, npl, &a);
  free_z_a(nl, npl, &dz);
  free_da(nl, npl, &da); 
#ifdef TEST_VS_PYTHON
  z = ptr_dnn->zprime;
  a = ptr_dnn->aprime;
  free_z_a(nl, npl, &z); 
  free_z_a(nl, npl, &a); 
#endif
  return status;
}
//----------------------------------------------------
int dnn_set_bsz(
    DNN_REC_TYPE *ptr_dnn, 
    int bsz
    )
{
  int status = 0;
  float ***z = NULL;
  float ***a = NULL;

  float ***dz = NULL;
  float ***da = NULL;

  int nl = ptr_dnn->nl;
  int *npl = ptr_dnn->npl;
  ptr_dnn->bsz = bsz;
  status = malloc_z_a(nl, npl, bsz, &z); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &a); cBYE(status);
  ptr_dnn->z = z;
  ptr_dnn->a = a;

  status = malloc_z_a(nl, npl, bsz, &dz); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &da); cBYE(status);
  ptr_dnn->dz = dz;
  ptr_dnn->da = da;

#ifdef TEST_VS_PYTHON
  z = a = NULL; // not necessary but to show we are re-initializing
  status = malloc_z_a(nl, npl, bsz, &z); cBYE(status);
  status = malloc_z_a(nl, npl, bsz, &a); cBYE(status);
#include "../test/_set_Z.c" // FOR TESTING 
#include "../test/_set_A.c" // FOR TESTING 
  ptr_dnn->zprime = z;
  ptr_dnn->aprime = a;
#endif
BYE:
  if ( status < 0 ) { 
    free_z_a(nl, npl, &z); 
    free_z_a(nl, npl, &a);
    free_z_a(nl, npl, &dz);
    free_da(nl, npl, &da);
  }
  return status;
}
//----------------------------------------------------

int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int nl,
    int *npl,
    float *dpl,
    const char * const afns
    )
{
  int status = 0;
  float   ***W = NULL;
  float   **b  = NULL;
  bool **d  = NULL;
  __act_fn_t  *A = NULL;
  __bak_act_fn_t  *bak_A = NULL;

  memset(ptr_X, '\0', sizeof(DNN_REC_TYPE));
  //--------------------------------------
  if ( nl < 3 ) { go_BYE(-1); }
  ptr_X->nl  = nl;
  //--------------------------------------
  for ( int i = 0; i < nl; i++ ) { 
    if ( npl[i] < 1 ) { go_BYE(-1); }
  }
  // TODO P1: Current implementation assumes last layer has 1 neuron
  if ( npl[nl-1] != 1 ) { go_BYE(-1); }
  int *itmp = memalign(MEMALIGN_BATCH, nl * sizeof(int));
  return_if_malloc_failed(itmp);
  memcpy(itmp, npl, nl * sizeof(int));
  ptr_X->npl = itmp;
  //--------------------------------------
  /* CAN HAVE DROPOUT IN INPUT LAYER  Hence following is commented
   * if ( dpl[0]    != 0 ) { go_BYE(-1); }
   */
  /* Cannot have dropout in output layer  Hence following check */
  if ( dpl[nl-1] != 0 ) { go_BYE(-1); }
  for ( int i = 1; i < nl-1; i++ ) { 
    if ( ( dpl[i] < 0 ) || ( dpl[i] >= 1 ) ) { go_BYE(-1); }
  }
  float *ftmp = memalign(MEMALIGN_BATCH, nl * sizeof(float));
  return_if_malloc_failed(ftmp);
  memcpy(ftmp, dpl, nl * sizeof(float));
  ptr_X->dpl = ftmp;
  //--------------------------------------
  A = memalign(MEMALIGN_BATCH, nl * sizeof(__act_fn_t));
  memset(A, '\0',  (nl * sizeof(__act_fn_t)));

  bak_A = memalign(MEMALIGN_BATCH, nl * sizeof(__bak_act_fn_t));
  memset(bak_A, '\0',  (nl * sizeof(__bak_act_fn_t)));

  for ( int i = 0; i < nl; i++ ) { 
    char *cptr;
    if ( i == 0 ) {
      cptr = strtok((char *)afns, ":");
    }
    else {
      cptr = strtok(NULL, ":");
    }
    if ( i == 0 ) { /* input layer has no activation function */
      if ( strcmp(cptr, "NONE") != 0 ) { go_BYE(-1); }
      A[0] = identity;
      continue; 
    }
    if ( strcmp(cptr, "sigmoid") == 0 ) {
      A[i]     = sigmoid;
      bak_A[i] = sigmoid_bak;
    }
    else if ( strcmp(cptr, "relu") == 0 ) {
      A[i]     = relu;
      bak_A[i] = relu_bak;
    }
    else if ( strcmp(cptr, "leaky_relu") == 0 ) {
      go_BYE(-1);
    }
    else if ( strcmp(cptr, "tanh") == 0 ) {
      go_BYE(-1);
    }
    else {
      go_BYE(-1);
    }
  }
  ptr_X->A  = A;
  ptr_X->bak_A  = bak_A;
  //--------------------------------------
  status = malloc_W(nl, npl, &W); cBYE(status);
  ptr_X->W  = W;
#ifdef TEST_VS_PYTHON
#include "../test/_set_W.c" // FOR TESTING 
#endif
  W = NULL;
  status = malloc_W(nl, npl, &W); cBYE(status);
  ptr_X->dW  = W;
  //--------------------------------------
  status = malloc_b(nl, npl, &b); cBYE(status);
  ptr_X->b  = b;
#ifdef TEST_VS_PYTHON
#include "../test/_set_B.c" // FOR TESTING 
#endif
  b = NULL;
  status = malloc_b(nl, npl, &b); cBYE(status);
  ptr_X->db  = b;
  //--------------------------------------
#ifdef TEST_VS_PYTHON
  W = NULL; 
  status = malloc_W(nl, npl, &W); cBYE(status);
  ptr_X->Wprime  = W;
#include "../test/_set_Wprime.c" // FOR TESTING 
  //--------------------------------------
  b = NULL;
  status = malloc_b(nl, npl, &b); cBYE(status);
  ptr_X->bprime  = b;
#include "../test/_set_Bprime.c" // FOR TESTING 
#endif
  //--------------------------------------
  d = memalign(MEMALIGN_BATCH, nl * sizeof(bool *));
  return_if_malloc_failed(d);
  for ( int l = 0; l < nl; l++ ) { 
    d[l] = memalign(MEMALIGN_BATCH, npl[l] * sizeof(bool));
    return_if_malloc_failed(d[l]);
  }
  ptr_X->d  = d;
  //--------------------------------------

BYE:
  if ( status < 0 ) { WHEREAMI; /* need to handle this better */ }
  return status;
}
