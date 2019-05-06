#include <unistd.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#define EXISTS 1
#define MIN 2
#define MAX 3
#define SUM 4
#define MIN_IDX 5
#define MAX_IDX 6
#define AND 7
#define OR 8
#define mcr_max(X, Y)  ((X) > (Y) ? (X) : (Y))
#define mcr_min(X, Y)  ((X) < (Y) ? (X) : (Y))
#define mcr_sum(X, Y)  ((X) + (Y))
/*
 * Note that if join_type == EXISTS, then we don't send in dst_fld.
 * We use nn_dst_fld instead */
/* For join, we will assume all columns ar fully materialized */
int
join(
    uint64_t offset,
    const char *join_type_op,
    int32_t *src_fld,
    uint64_t *nn_src_fld,
    int32_t *src_lnk, // cannot have a nn field 
    uint64_t nR_src,
    int32_t *dst_fld,
    uint64_t *nn_dst_fld,
    int32_t *dst_lnk, // cannot have a nn field 
    uint64_t nR_dst
    )
{
  int status = 0;
  uint64_t src_idx = 0;
  uint64_t dst_idx = 0;
  //int32_t sval = src_fld[src_idx];
  //int32_t dval = dst_fld[dst_idx];
  uint64_t lb = 0;
  uint64_t ub = nR_dst-1;
  //  if ( src_fld == NULL ) { go_BYE(-1); }
  //  if ( src_lnk == NULL ) { go_BYE(-1); }
  //  if ( join_type == EXISTS ) { 
  //    if ( dst_fld != NULL ) { go_BYE(-1); }
  //  }
  //  else {
  //    if ( dst_fld == NULL ) { go_BYE(-1); }
  //  }
  //  if ( dst_lnk == NULL ) { go_BYE(-1); }
  //  if ( nn_dst_fld == NULL ) { go_BYE(-1); }
  //  if ( nR_src == 0 ) { go_BYE(-1); }
  //  if ( nR_dst == 0 ) { go_BYE(-1); }
  uint16_t join_type = 0;
  if ( strcmp(join_type_op, "exists") == 0 ) { join_type = EXISTS; }
  else if ( strcmp(join_type_op, "min") == 0 )  { join_type = MIN; }
  else if ( strcmp(join_type_op, "max") == 0 )  { join_type = MAX; }
  else if ( strcmp(join_type_op, "sum") == 0 )  { join_type = SUM; }
  else if ( strcmp(join_type_op, "min_idx") == 0 )  { join_type = MIN_IDX; }
  else if ( strcmp(join_type_op, "max_idx") == 0 )  { join_type = MAX_IDX; }
  else if ( strcmp(join_type_op, "and") == 0 )  { join_type = AND; }
  else if ( strcmp(join_type_op, "or") == 0 )  { join_type = OR; }
  //else { go_BYE(-1); }
  uint64_t i;
  uint64_t j = src_idx;
  for ( i = lb; i < ub; ) {
    bool first = true;
    nn_dst_fld[i] = 0;
    // If current value same as previous, re-use earlier result
    if ( ( i > 0 ) && ( dst_fld[i] == dst_fld[i-1] ) ) {
      nn_dst_fld[i] = nn_dst_fld[i-1];
      if ( dst_fld != NULL ) { 
        dst_fld[i] = dst_fld[i-1];
      }
      i++;
      continue;
    }
    for ( ; j < nR_src; ) {
      // if dst_lnk's i th value is greater than src_lnk's nR_src(last index) 
      // i.e. dst_lnk's i th value do not exists in whole src_lnk
      if ( dst_lnk[i] > src_lnk[nR_src-1] ) { 
        i++; 
        break;
      }
      if ( src_lnk[j] < dst_lnk[i] ) {
        j++;
      }
      else if ( src_lnk[j] == dst_lnk[i] ) {
        nn_dst_fld[i] = 1;
        if ( first ) {
          if ( ( join_type == MIN_IDX ) || ( join_type == MAX_IDX ) ) {
            dst_fld[i] = offset + j;
          }
          else {
            dst_fld[i] = src_fld[j];
          }
          first = false;
        }
        else {
          if ( join_type == MIN ) { 
            dst_fld[i] = mcr_min(dst_fld[i], src_fld[j]);
          }
          else if ( join_type == MAX ) { 
            dst_fld[i] = mcr_max(dst_fld[i], src_fld[j]);
          }
          else if ( join_type == SUM ) { 
            dst_fld[i] = mcr_sum(dst_fld[i], src_fld[j]);
          }
          else if ( join_type == AND ) {
            dst_fld[i] = dst_fld[i] & src_fld[j];
          }
          else if ( join_type == OR ) {
            dst_fld[i] = dst_fld[i] | src_fld[j];
          }
          else if ( join_type == MAX_IDX ) {
            dst_fld[i] = offset + j;
          }
        }
        j++;
      }
      else {
        i++;
        //setting "first" flag to true for each i th dst_lnk value
        first = true;
      }
    }
    src_idx = j;
  }
//BYE:
  return status;
}

int main() {
int status = 0;
uint64_t src_size = 7;
uint64_t dst_size = 3;
uint64_t offset = 0;
int32_t *src_lnk, *src_fld;
int32_t *dst_lnk, *dst_fld;
uint64_t *nn_dst_fld;
// for checking this program for various join_type (default is sum)
char *join_type = "sum";
// Allocating memory
src_lnk = malloc(src_size * sizeof("int32_t"));
src_fld = malloc(src_size * sizeof("int32_t"));
dst_lnk = malloc(dst_size * sizeof("int32_t"));
dst_fld = malloc(dst_size * sizeof("int32_t"));
nn_dst_fld = malloc(dst_size * sizeof("uint64_t"));

// Initializing inputs and desired buffers
src_lnk[0]=10; src_lnk[1]=10; src_lnk[2]=10; src_lnk[3]=10;
src_lnk[4]=20; src_lnk[5]=20 ; src_lnk[6]=30;

src_fld[0]=1; src_fld[1]=3; src_fld[2]=5; src_fld[3]=3;
src_fld[4]=3; src_fld[5]=2; src_fld[6]=1;

dst_lnk[0]=10; dst_lnk[1]=20; dst_lnk[2]=30;

nn_dst_fld[0] = 0; nn_dst_fld[1] = 0; nn_dst_fld[2] = 0;

// default value initialization of dst_fld
if (strcmp(join_type, "sum") == 0) {  
  dst_fld[0]=0; dst_fld[1]=0; dst_fld[2]=0;
}
else if(strcmp(join_type, "min") == 0) {  
  dst_fld[0]=127; dst_fld[1]=127; dst_fld[2]=127;
}
else if (strcmp(join_type, "max") == 0) {  
  dst_fld[0]=-1; dst_fld[1]=-1; dst_fld[2]=-1;
}
else if (strcmp(join_type, "min_idx") == 0  || strcmp(join_type, "max_idx") ==0 || strcmp(join_type, "and") ==0 ) {
  dst_fld[0]=-1; dst_fld[1]=-1; dst_fld[2]=-1;
}
else if (strcmp(join_type, "or") ==0 ) {
  dst_fld[0]=0; dst_fld[1]=0; dst_fld[2]=0;
}
// Call to join
status = join(offset, join_type, src_fld, NULL, src_lnk , src_size, dst_fld, nn_dst_fld, dst_lnk, dst_size);
// Printing dst_fld results
printf("\n==================================\n");
puts(join_type);
int64_t i;
for ( i = 0; i < dst_size; i++ ) {
  printf("%d\n", dst_fld[i]);
}
return status;
}