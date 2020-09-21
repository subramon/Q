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
  uint32_t *tos = NULL;
  uint32_t *chk_from_i = NULL;
  uint32_t *chk_from_j = NULL;
  uint8_t **goals = NULL;
  if ( ub - lb <= MIN_LEAF_SIZE ) { return status; }
  if ( ub > n ) { go_BYE(-1); }
  chk_from_i = malloc((ub-lb) * sizeof(uint32_t));
  chk_from_j = malloc((ub-lb) * sizeof(uint32_t));

  status = pr_data_i(Y, to, m, lb, ub); cBYE(status);

  // The "froms" for all attributes should be the same 
  // Of course, the order in which they occur might be different
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

  // Check each attribute in sorted order 
  for ( uint32_t j = 0; j < m; j++ ) {
    for ( uint32_t i = lb+1; i < ub; i++ ) { 
      uint32_t yval_i_1 = get_yval(Y[j][i-1]);
      uint32_t yval_i_2 = get_yval(Y[j][i]);
      if ( yval_i_1 > yval_i_2 ) { go_BYE(-1);
      }
    }
  }
    // check uniqueness of from
  for ( uint32_t j = 0; j < m; j++ ) {
    int idx = 0;
    for ( uint32_t i = lb; i < ub; i++ ) { 
      chk_from_i[idx++] = get_from(Y[j][i]);
    }
    bool b_is_unique;
    status = chk_is_unique(chk_from_i, ub-lb, &b_is_unique);
    if ( !b_is_unique ) { go_BYE(-1); }
  }
  // check goal counts for each attribute. Should be same.
  goals = malloc(m * sizeof(uint32_t *));
  for ( uint32_t j = 0; j < m; j++ ) {
    goals[j] = malloc(2 * sizeof(uint32_t)); // goal is either 0 or 1 
    for ( uint32_t k = 0; k < 2; k++ ) {
      goals[j][k] = 0;
    }
  }
  for ( uint32_t j = 0; j < m; j++ ) {
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint8_t goal_i = get_goal(Y[j][i]);
      if ( goal_i > 1 ) { go_BYE(-1); }
      goals[j][goal_i]++;
    }
  }
  for ( uint32_t j1 = 0; j1 < m; j1++ ) {
    for ( uint32_t j2 = j1+1; j2 < m; j2++ ) {
      for ( uint32_t k = 0; k < 2; k++ ) {
        if ( goals[j1][k] != goals[j2][k] ) { go_BYE(-1); }
      }
    }
  }
  // check that from and to match up
  for ( uint32_t j = 0; j < m; j++ ) {
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t from_i = get_from(Y[j][i]);
      uint32_t to_i = to[j][from_i];
      if ( to_i != i ) { go_BYE(-1); }
    }
  }
  // check that from and goal match up
  for ( uint32_t j = 0; j < m; j++ ) {
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t from_i = get_from(Y[j][i]);
      uint8_t  goal_i = get_goal(Y[j][i]);
      if ( g[from_i] != goal_i ) { 
        go_BYE(-1); }
    }
  }
  printf("++++++++++++++++++++++++++\n");
BYE:
  if ( goals != NULL ) { 
    for ( uint32_t j = 0; j < m; j++ ) {
      free_if_non_null(goals[j]);
    }
    free_if_non_null(goals);
  }
  free_if_non_null(tos);
  free_if_non_null(chk_from_i);
  free_if_non_null(chk_from_j);
  return status;
}
