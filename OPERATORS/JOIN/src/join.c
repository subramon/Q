#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>
#include<inttypes.h>
#define mcr_max(X, Y)  ((X) > (Y) ? (X) : (Y))
#define mcr_min(X, Y)  ((X) < (Y) ? (X) : (Y))

void operation(const int32_t *s_lnk, const int32_t *s_fld, int64_t start_idx, int64_t s_size, int32_t d_lnk_val, int32_t *d_fld, uint64_t d_idx, const char *op)
{
  int64_t i;
  for (i = start_idx; i < s_size; i++) { 
    if(s_lnk[i] == d_lnk_val) { 
      if (strcmp(op, "sum") == 0) {
        d_fld[d_idx] = d_fld[d_idx] + s_fld[i];
      }
      else if (strcmp(op, "max") == 0) {
        d_fld[d_idx] = mcr_max(d_fld[d_idx], s_fld[i]);
      }
      else if (strcmp(op, "min") == 0) {
        d_fld[d_idx] = mcr_min(d_fld[d_idx], s_fld[i]);
      }
      else if (strcmp(op, "max_idx") == 0) {
        d_fld[d_idx] = i;
      }
      else if (strcmp(op, "and") == 0) {
        d_fld[d_idx] = d_fld[d_idx] & s_fld[i];
      }
      else if (strcmp(op, "or") == 0) {
        d_fld[d_idx] = d_fld[d_idx] | s_fld[i];
      }
      else {
        printf("op not supported");
      }
    }
    else {
      break;
    }
    //printf("\n$$$%ld %d\n", i, d_lnk_val);
  }
}

int get_index(const int32_t *src_link, uint64_t src_size, int32_t dst_lnk_search ) { 
  //printf("\nchecking last element%d\n", src_link[src_size-1]);
  int64_t idx = -1;
  if(src_link[src_size-1] < dst_lnk_search || src_link[src_size-src_size] > dst_lnk_search) {
    return idx;
  }
  int64_t low, high, mid;
	low = 0;
	high = src_size-1;
	while(low <= high) {
		mid = (low+high)/2;
		if(src_link[mid]<dst_lnk_search) {
    // move to right
      low = mid+1;
    }
		else if(src_link[mid]>dst_lnk_search) {
    // move to left
			high = mid-1; 
    }
		else if(src_link[mid]==dst_lnk_search) {
		 	idx = mid; 
      high = mid-1;
      //printf("\n%ld\n", high);
    }
	}
	return idx; 
}
  
int join(      
      const int32_t * src_lnk,
      const int32_t * src_fld,
      uint64_t src_nR,
      const int32_t * dst_lnk,
      int32_t * dst_fld,
      uint64_t dst_nR,
      const char *join_type)
{
  int status = 0;
  //if ( src_val == NULL ) { go_BYE(-1); }
  //if ( src_drag == NULL ) { go_BYE(-1); }
  //if ( src_nR == 0 ) { go_BYE(-1); }
  //if ( dst_val == NULL ) { go_BYE(-1); }
  //if ( dst_drag == NULL ) { go_BYE(-1); }
  //if ( dst_nR == 0 ) { go_BYE(-1); }
  int i;
  for ( i = 0; i < dst_nR; i++ ) {
    int64_t start_idx = get_index(src_lnk, src_nR, dst_lnk[i]);
    printf("\n processing %d found at index%ld\n", dst_lnk[i], start_idx);
    //printf("%ld\n", start_idx);
    if ( start_idx != -1 ) {
      if (strcmp(join_type, "min_idx") ==0) {
        dst_fld[i] = start_idx;
      }
      else { 
        operation(src_lnk, src_fld, start_idx, src_nR, dst_lnk[i], dst_fld, i, join_type);
      }
    }
    else if( start_idx == -1) {
      //dst_fld[i] = 0; // default value of respective operation
    }
  }
//BYE:
  return status;
}
int main() {
int status = 0;
int src_size = 7;
int dst_size = 3;
int32_t *src_lnk, *src_fld;
int32_t *dst_lnk, *dst_fld;
uint64_t *num_in_out, *aidx;
char *join_type = "max_idx";
// Allocate memory for
src_lnk = malloc(src_size * sizeof("int32_t"));
src_fld = malloc(src_size * sizeof("int32_t"));
dst_lnk = malloc(dst_size * sizeof("int32_t"));
dst_fld = malloc(dst_size * sizeof("int32_t"));

// Initialize inputs and desired buffers
src_lnk[0]=10; src_lnk[1]=10; src_lnk[2]=10; src_lnk[3]=10;
src_lnk[4]=20; src_lnk[5]=20 ; src_lnk[6]=30;

src_fld[0]=1; src_fld[1]=3; src_fld[2]=5; src_fld[3]=3;
src_fld[4]=3; src_fld[5]=2; src_fld[6]=1;

dst_lnk[0]=10; dst_lnk[1]=20; dst_lnk[2]=30;

// default value initialization
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
status = join(src_lnk, src_fld, src_size, dst_lnk, dst_fld, dst_size, join_type);
printf("\n==================================\n");
int64_t i;
for ( i = 0; i < dst_size; i++ ) {
  printf("%d\n", dst_fld[i]);
}
return status;
}
