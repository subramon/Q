#include <sys/time.h>
#include "q_incs.h"
#include "dnn_types.h"
#include "core_dnn.h"
#include "fstep_a.h"
#include "bstep.h"

#ifdef RASPBERRY_PI
static uint64_t 
get_time_usec(
    void
    )
{
  struct timeval Tps; 
  struct timezone Tpf;
  gettimeofday (&Tps, &Tpf);
  return ((uint64_t )Tps.tv_usec + 1000000* (uint64_t )Tps.tv_sec);
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
    uint8_t *d, /* [num neurons ] */
    float dpl,  /* probability of dropout */
    int n       /* num neurons */
    )
{
  int status = 0;
  if ( d == NULL ) { go_BYE(-1); }
  if ( n <= 0    ) { go_BYE(-1); }
  if ( dpl < 0 ) { go_BYE(-1); }
  if ( dpl >= 1 ) { go_BYE(-1); }
  memset(d, '\0', (sizeof(uint8_t) * n)); // nobody dropped out
  if ( dpl > 0 ) { 
    for ( int i = 0; i < n; i++ ) { 
      double dtemp = drand48();
      if ( dtemp > dpl ) { 
        d[i] = 1; // ith neuron will be dropped
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

//----------------------------------------------------
// 'da' malloc is not same as z, a or dz
// 'da' is pointing to previous layer in back propagation
// so for 10, 4, 2, 1 case
// da[0] = NULL, da[1] = 10 * 3
// da[2] = 4 * 3, da[3] = 2 * 3
static int
malloc_da(
    int nl,
    int *npl,
    int bsz,
    float ****ptr_z)
{
  int status = 0;
  float ***z = *ptr_z = NULL;

  z = malloc(nl * sizeof(float **));
  return_if_malloc_failed(z);
  memset(z, '\0', nl * sizeof(float **));

  z[0] = NULL;
  for ( int i = 1; i < nl; i++ ) {
    z[i] = malloc(npl[i-1] * sizeof(float *));
    return_if_malloc_failed(z[i]);
    memset(z[i], '\0', npl[i] * sizeof(float *));
  }
  for ( int i = 1; i < nl; i++ ) {
    for ( int j = 0; j < npl[i]; j++ ) {
      z[i][j] = malloc(bsz * sizeof(float));
      return_if_malloc_failed(z[i][j]);
    }
  }
  *ptr_z = z;
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
  z = malloc(nl * sizeof(float **));
  return_if_malloc_failed(z);
  memset(z, '\0', nl * sizeof(float **));

  z[0] = NULL;
  for ( int i = 1; i < nl; i++ ) { 
    z[i] = malloc(npl[i] * sizeof(float *));
    return_if_malloc_failed(z[i]);
    memset(z[i], '\0', npl[i] * sizeof(float *));
  }
  for ( int i = 1; i < nl; i++ ) { 
    for ( int j = 0; j < npl[i]; j++ ) { 
      z[i][j] = malloc(bsz * sizeof(float));
      return_if_malloc_failed(z[i][j]);
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
dnn_train(
    DNN_REC_TYPE *ptr_dnn,
    float **cptrs_in, /* [npl[0]][nI] */
    float **cptrs_out, /* [npl[nl-1]][nI] */
    uint64_t nI // number of instances
    )
{
  int status = 0;
  int batch_size = ptr_dnn->bsz;
  int nl = ptr_dnn->nl;
  int    *npl  = ptr_dnn->npl;
  float  ***W  = ptr_dnn->W;
  float   **b  = ptr_dnn->b;
  uint8_t  **d = ptr_dnn->d;
  float   *dpl = ptr_dnn->dpl;
  float   ***z = ptr_dnn->z;
  float   ***a = ptr_dnn->a;
  float   ***dz = ptr_dnn->dz;
  float   ***da = ptr_dnn->da;
  float   ***zprime = ptr_dnn->zprime;
  float   ***aprime = ptr_dnn->aprime;
  __act_fn_t  *A = ptr_dnn->A;
  __bak_act_fn_t  *bak_A = ptr_dnn->bak_A;
  float **da_temp = NULL;

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

  // allocate space for da_temp (used in back propagation
  da_temp = malloc(npl[nl-1] * sizeof(float*));
  return_if_malloc_failed(da_temp);
  for ( int l = 0; l < npl[nl-1]; l++ ) {
    da_temp[l] = malloc(batch_size * sizeof(float));
    return_if_malloc_failed(da_temp[l]);
  }

  srand48(RDTSC());
  for ( int i = 0; i < num_batches; i++ ) {
    int lb = i  * batch_size;
    int ub = lb + batch_size;
    if ( i == (num_batches-1) ) { ub = nI; }
    if ( ( ub - lb ) > batch_size ) { go_BYE(-1); }

    float **in;
    float **out_z;
    float **out_a;
    for ( int l = 1; l < nl; l++ ) { // Note that loop starts from 1, not 0
      in  = a[l-1];
      out_z = z[l];
      out_a = a[l];
      if ( l == 1 ) { 
        in = cptrs_in; 
        /* Advance the pointers to get to the appropriate batch */
        for ( int j = 0; j < npl[0]; j++ ) { 
          in[j] += lb;
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
#ifdef TEST_VS_PYTHON
    status = check_z_a(nl, npl, batch_size, z, zprime); cBYE(status);
    status = check_z_a(nl, npl, batch_size, a, aprime); cBYE(status);
    printf("SUCCESS\n"); 
    //exit(0);
#endif

    
    // da = - (np.divide(y, y_hat) - np.divide(1 - y, 1 - y_hat))
    // da = Q.sub(Q.div(Q.sub(1, y), Q.sub(1, yhat)), Q.div(y/ yhat))
    //
    // s = 1 / (1 + np.exp(-z))
    // dz = da * s * (1 - s)

    // s = Q.reciprocal(Q.vsadd(Q.exp(Q.vsmul(z, -1)), 1))
    // dz = Q.vvmul(da, Q.vvmul(s, Q.vssub(1, s)))
#define ALPHA 0.0075 // TODO This is a user supplied parameter

    // populate da_temp using a[nl-1] and Xout
    // da_temp is a input in the back propagation
    float **out;
    out = cptrs_out;
    for ( int p = 0; p < npl[nl-1]; p++ ) {
      float *x_out = out[p];
      float *a_out = a[nl-1][p];
      float *da_temp_p = da_temp[p];
      for ( int q = 0; q < batch_size; q++ ) {
        da_temp_p[q] = - ( ( x_out[q] / a_out[q] ) - ( ( 1 - x_out[q] ) / ( 1 - a_out[q] ) ) );
      }
    }
    printf("Generated da_temp\n");

    // Use this da_temp, a, z, to prepare da, dz, dw & db
    float **f_z; /* f_z is z created in forward pass */
    float **f_a;
    float **out_dz;
    float **out_da;
    for ( int l = nl-1; l > 0; l-- ) { // back prop through the layers
      in = da[l+1]; /* input to second last layer stored in da[3], refer malloc_da() */
      out_dz = dz[l];
      out_da = da[l];
      f_z = z[l];
      f_a = a[l];
      if ( l == ( nl - 1 ) ) {
        in = da_temp;
      }
      status = bstep(in, f_a, f_z, d[l-1], d[l], out_dz, out_da, (ub-lb), npl[l], npl[l-1], bak_A[l]);
      cBYE(status);
      // TODO: remove below exit()
      exit(0);
    }
    // update W and b
    for ( int l = nl-1; l > 0; l-- ) { // back prop through the layers
      // dot product of x, y 
      // dw = (1. / m) * np.dot(dz, a_prev.T)
      // dw = Q.sum(Q.vvmul(dz, XXXX)):eval():to_number() / x:length()
    }
    // compare W with Wprime, b with bprime
  }
BYE:
  // free da_temp
  if ( da_temp != NULL ) {
    for ( int l = 0; l < npl[nl-1]; l++ ) {
      free_if_non_null(da_temp[l]);
    }
    free_if_non_null(da_temp);
  }

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
  uint8_t **d = ptr_X->d;

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
  status = malloc_da(nl, npl, bsz, &da); cBYE(status);
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
  uint8_t **d  = NULL;
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
  int *itmp = malloc(nl * sizeof(int));
  return_if_malloc_failed(itmp);
  memcpy(itmp, npl, nl * sizeof(int));
  ptr_X->npl = itmp;
  //--------------------------------------
  // CAN HAVE DROPOUT IN INPUT LAYER  if ( dpl[0]    != 0 ) { go_BYE(-1); }
  if ( dpl[nl-1] != 0 ) { go_BYE(-1); }
  for ( int i = 1; i < nl-1; i++ ) { 
    if ( ( dpl[i] < 0 ) || ( dpl[i] >= 1 ) ) { go_BYE(-1); }
  }
  float *ftmp = malloc(nl * sizeof(float));
  return_if_malloc_failed(ftmp);
  memcpy(ftmp, dpl, nl * sizeof(float));
  ptr_X->dpl = ftmp;
  //--------------------------------------
  A = malloc(nl * sizeof(__act_fn_t));
  memset(A, '\0',  (nl * sizeof(__act_fn_t)));

  bak_A = malloc(nl * sizeof(__bak_act_fn_t));
  memset(bak_A, '\0',  (nl * sizeof(__bak_act_fn_t)));

  for ( int i = 0; i < nl; i++ ) { 
    char *cptr;
    if ( i == 0 ) {
      cptr = strtok((char *)afns, ":");
      if ( strcmp(cptr, "NONE") != 0 ) { go_BYE(-1); }
      // TODO: do we require below line?
      A[i] = identity;
      continue;
    }
    else {
      cptr = strtok(NULL, ":");
    }
    if ( strcmp(cptr, "sigmoid") == 0 ) {
      A[i] = sigmoid;
      bak_A[i] = sigmoid_bak;
    }
    else if ( strcmp(cptr, "relu") == 0 ) {
      A[i] = relu;
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
  //--------------------------------------
  W = malloc(nl * sizeof(float **));
  return_if_malloc_failed(W);
  W[0] = NULL;
  for ( int l = 1; l < nl; l++ ) { 
    int L_prev = npl[l-1];
    int L_curr = npl[l];
    W[l] = malloc(L_prev * sizeof(float *));
    return_if_malloc_failed(W[l]);
    for ( int j = 0; j < L_prev; j++ ) { 
      W[l][j] = malloc(L_curr * sizeof(float));
      return_if_malloc_failed(W[l][j]);
    }
  }
#ifdef TEST_VS_PYTHON
#include "../test/_set_W.c" // FOR TESTING 
#endif
  ptr_X->W  = W;
  //--------------------------------------
  b = malloc(nl * sizeof(float *));
  return_if_malloc_failed(b);
  b[0] = NULL;
  for ( int l = 1; l < nl; l++ ) { 
    int L_next = npl[l];
    b[l] = malloc(L_next * sizeof(float));
    return_if_malloc_failed(b[l]);
  }
#ifdef TEST_VS_PYTHON
#include "../test/_set_B.c" // FOR TESTING 
#endif
  ptr_X->b  = b;
  //--------------------------------------
  d = malloc(nl * sizeof(uint8_t *));
  return_if_malloc_failed(d);
  for ( int l = 0; l < nl; l++ ) { 
    d[l] = malloc(npl[l] * sizeof(uint8_t));
    return_if_malloc_failed(d[l]);
  }
  ptr_X->d  = d;
  //--------------------------------------

BYE:
  if ( status < 0 ) { WHEREAMI; /* need to handle this better */ }
  return status;
}
