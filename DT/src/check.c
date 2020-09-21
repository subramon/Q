#include "incs.h"
#include "check.h"
#include "pr_data.h"

int 
chk_is_unique(
    uint32_t *X,
    uint32_t n,
    bool *ptr_is_unique
    )
{
  int status = 0;
  // make this n log n instead of n^2
  for ( uint32_t i = 0; i < n; i++ ) {
    uint32_t x_i = X[i];
    for ( uint32_t j = i+1; j < n; j++ ) {
      if ( X[j] == x_i ) { *ptr_is_unique = false; return status; }
    }
  }
  *ptr_is_unique = true;
BYE:
  return status;
}
int 
chk_set_equality(
    uint32_t *X,
    uint32_t *Y,
    uint32_t n,
    bool *ptr_is_eq
    )
{
  int status = 0;
  // make this n log n instead of n^2
  for ( uint32_t i = 0; i < n; i++ ) {
    uint32_t x_i = X[i];
    bool found = false;
    for ( uint32_t j = 0; j < n; j++ ) {
      if ( Y[j] == x_i ) { found = true; break; }
    }
    if ( !found ) { *ptr_is_eq = false; return status; }
  }
  *ptr_is_eq = true;
BYE:
  return status;
}

int 
check(
    uint32_t **to, /* [m][n] */
    uint8_t *g, // for debugging 
    uint32_t lb,
    uint32_t ub,
    uint32_t n,
    uint32_t m,
    uint64_t **Y /* [m][n] */
   )
{
  int status = 0;
  bool *pos_seen = NULL;
  uint32_t *tos = NULL;
  uint32_t *chk_from_i = NULL;
  uint32_t *chk_from_j = NULL;
  if ( ub - lb <= MIN_LEAF_SIZE ) { return status; }
  if ( ub > n ) { go_BYE(-1); }
  pos_seen = malloc(n * sizeof(bool));
  chk_from_i = malloc((ub-lb) * sizeof(uint32_t));
  chk_from_j = malloc((ub-lb) * sizeof(uint32_t));

  status = pr_data_i(Y, to, m, n, lb, ub); cBYE(status);
  // some checking 
  /*
  for ( uint32_t j = 1; j < m; j++ ) {
    bool is_eq = false;
    status = chk_set_equality(to[j-1], to[j], lb, ub, n, &is_eq); cBYE(status);
    if ( !is_eq ) { go_BYE(-1);
    }
  }
  */
  for ( uint32_t j1 = 0; j1 < m; j1++ ) {
    int idx = 0;
    for ( unsigned int i = lb; i < ub; i++ ) { 
      chk_from_i[idx++] = get_from(Y[j1][i]);
    }
    for ( uint32_t j2 = 0; j2 < m; j2++ ) {
      idx = 0;
      for ( unsigned int i = lb; i < ub; i++ ) { 
        chk_from_j[idx++] = get_from(Y[j2][i]);
      }
    }
    bool is_eq = false;
    status = chk_set_equality(chk_from_i, chk_from_j, ub-lb, &is_eq); 
    cBYE(status);
    if ( !is_eq ) { go_BYE(-1);
    }
  }

  for ( uint32_t j = 0; j < m; j++ ) {
    for ( uint32_t i = lb+1; i < ub; i++ ) { 
      uint32_t yval_i_1 = get_yval(Y[j][i-1]);
      uint32_t yval_i_2 = get_yval(Y[j][i]);
      if ( yval_i_1 > yval_i_2 ) { go_BYE(-1);
      }
    }
    // check uniqueness of from
    int idx = 0;
    for ( uint32_t i = lb; i < ub; i++ ) { 
      chk_from_i[idx++] = get_from(Y[j][i]);
    }
    bool b_is_unique;
    status = chk_is_unique(chk_from_i, ub-lb, &b_is_unique);
    if ( !b_is_unique ) { go_BYE(-1); }
    // check uniqueness of tos
    // TODO 
  }
  printf("++++++++++++++++++++++++++\n");
BYE:
  free_if_non_null(pos_seen);
  free_if_non_null(tos);
  free_if_non_null(chk_from_i);
  free_if_non_null(chk_from_j);
  return status;
}
