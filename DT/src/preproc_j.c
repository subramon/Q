#include "incs.h"
#include "check.h"
#include "preproc_j.h"

extern config_t g_C;

// make a composite key
// Bits [32..63] used for "from" => < 2^32 values in data set 
// Bit 31 used for goal
// Bits [0..30] used for the encoded value (yval, not xval)
uint64_t x_mk_comp_val(
    uint64_t from,
    uint64_t goal,
    uint64_t yval
    )
{
  uint64_t tmp1 = from << 32;
  uint64_t tmp2 = goal << 31;
  uint64_t tmp3 = tmp1 | tmp2; 
  uint64_t tmp4 = tmp3 | yval;
  return tmp4;
}


typedef struct _comp_key_t { 
  float xval;   // this is the actual data value 
  uint32_t idx; // this is the index where it was located
  uint8_t g;    // value of goal attribute for that instance 
} comp_key_t;

static int
sortfn(
    const void *p1, 
    const void *p2
    )
{
  const comp_key_t *r1 = (const comp_key_t *)p1;
  const comp_key_t *r2 = (const comp_key_t *)p2;
  if ( r1->xval < r2->xval ) { 
    return -1;
  }
  else  {
    return 1;
  }
}
int 
preproc_j(
    float *Xj, /* [m][n] */
    uint32_t n,
    uint8_t *g,
    uint64_t **ptr_Yj,
    uint32_t **ptr_to
   )
{
  int status = 0;
  uint32_t *alt_to  = NULL; // [n] for debugging 
  uint64_t *Yj = NULL; // [n]
  uint32_t *to = NULL; // [n]
  comp_key_t *C = NULL; // [n]
  // allocate Y and idx 
  Yj  = malloc(n * sizeof(uint64_t));
  return_if_malloc_failed(Yj);
  to  = malloc(n * sizeof(uint32_t));
  return_if_malloc_failed(to);
  C   = malloc(n * sizeof(comp_key_t));
  return_if_malloc_failed(C);
  for ( uint32_t i = 0; i < n; i++ ) { 
    C[i].idx  = i;
    C[i].g    = g[i];
    C[i].xval = Xj[i];
  }
  // sort X, idx, g
  qsort(C, n, sizeof(comp_key_t), sortfn);
#ifdef DEBUG
  // check sorted order
  for ( uint32_t i = 1; i < n; i++ ) { 
    if ( C[i].xval < C[i-1].xval ) { go_BYE(-1);
    }
  }
#endif
  // create Y. 
  // bits 0 to 30 for yval, bit 31 for goal, bits 32 to 63 for from
  // here is the connection between xval (actual value) and yval (encoded)
  // The insight is that the "actual" value is irrelevant for the purposes
  // of creating a decision tree, what is important is the "relative" value
  // So, the smallest actual value is given the encoded value 1, the next
  // largest actual value is given the encoded value 2 and so on
  // So, if a feature had the actual values 4, 5, 3, 4, 3, 5, 
  // then the corresponding encoded values would be 2, 3, 1, 2, 1, 3
  // IMPORTANT: We assume that there are no more than 2^31 unique values
  // In principle, there is no reason why we could not allocate more bits
  // Its just the assumption that *this* implementation makes.
  uint32_t i = 0;
  float xval      = C[i].xval;
  uint32_t yval   = 1;
  uint32_t from_i = C[i].idx;
  uint8_t  g_i    = C[i].g;
  Yj[i] = x_mk_comp_val(from_i, g_i, yval); 
  //-------------------------------------------
  if ( g_C.is_debug ) { 
    uint32_t chk_yval = get_yval(Yj[i]);
    if ( chk_yval != yval ) { go_BYE(-1); }
    uint8_t  chk_goal = get_goal(Yj[i]);
    if ( chk_goal != g_i ) { go_BYE(-1); }
    uint32_t chk_from = get_from(Yj[i]);
    if ( chk_from != from_i ) { go_BYE(-1); }
  }
  //-------------------------------------------
  for ( i = 1; i < n; i++ ) { 
    g_i    = C[i].g;
    // Notice that every time we encounter a new xval, we make a new yval
    // Also, recall that that xvals are encountered in sorted order (asc)
    if ( C[i].xval != xval ) {
      xval = C[i].xval;
      yval++;
    }
    from_i = C[i].idx;
    Yj[i] = x_mk_comp_val(from_i, g_i, yval);
  }
  free_if_non_null(C);
  //----------------------------------------------------------
  // Create the "to" data structure 
  // to[x] == y => 
  // value in the xth position of Xj is now in the yth position of Yj
  for ( i = 0; i < n; i++ ) { 
    uint32_t pos = get_from(Yj[i]);
    if ( pos >= n ) { go_BYE(-1); }
    to[pos] = i;
  }
  //----------------------------------------------------------
  if ( g_C.is_debug ) { 
    // Check that the values in "to" are 1..n
    alt_to = malloc(n * sizeof(uint32_t));
    for ( uint32_t j = 0; j < n; j++ ) { 
      alt_to[i] = j+1;
    }
    bool is_eq;
    status = chk_set_equality(to, alt_to, n, &is_eq);
    cBYE(status);
    if ( !is_eq ) { go_BYE(-1); }
    free_if_non_null(alt_to);
  }

  //--------------------------------------
  *ptr_Yj = Yj;
  *ptr_to = to;
BYE:
  free_if_non_null(alt_to);
  free_if_non_null(C);
  if ( status < 0 ) { 
    free_if_non_null(Yj);
    free_if_non_null(to);
  }
  return status;
}
