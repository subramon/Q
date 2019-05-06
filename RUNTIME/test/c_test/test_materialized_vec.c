#include "q_incs.h"
#include "mmap_types.h"
#include "core_vec.h"
#include <math.h>

#define NUM_TRIALS   1
#define NUM_ELEMENTS 1024*64+3
#define CHUNK_SIZE   1024*64

int check_elements(VEC_REC_TYPE *X);
int set_element(VEC_REC_TYPE *X, int index, int value);
int get_element(VEC_REC_TYPE *X, int index, int len);

int 
check_elements(VEC_REC_TYPE *X) 
{
  int status = 0;
  // Validate number of elements in vector
  printf("Number of elements in vector are %d\n", X->num_elements);
  if ( X->num_elements != NUM_ELEMENTS ) { go_BYE(-1) }
  
  for ( int j = 0; j < NUM_ELEMENTS; j++ ) {
  
  /*
    // Read from vector
    status = vec_get(X, j, 1); cBYE(status);
    status = vec_check(X); cBYE(status);
    
    char *ret_addr = X->ret_addr;
    int32_t ret_len = X->ret_len;
    if ( ret_addr == NULL ) { go_BYE(-1); }
    if ( ret_len  != 1 ) { go_BYE(-1); }
    int32_t *iptr = (int32_t *)ret_addr;
  */
    int32_t iptr = get_element(X, j, 1);
    if ( iptr != (j+1)*10 ) { printf("Mismatched index=%d, value=%d\n", j, iptr); go_BYE(-1); }
    status = vec_check(X); cBYE(status);
  }
BYE:
  return status;
}

int
get_element(VEC_REC_TYPE *X, int index, int len)
{
  int status = 0;
  // Read from vector
  status = vec_get(X, index, len); cBYE(status);
  status = vec_check(X); cBYE(status);
  
  char *ret_addr = X->ret_addr;
  int32_t ret_len = X->ret_len;
  if ( ret_addr == NULL ) { go_BYE(-1); }
  if ( ret_len  != len ) { go_BYE(-1); }
  int32_t *iptr = (int32_t *)ret_addr;    
BYE:
  return *iptr;    
}

int
set_element(VEC_REC_TYPE *X, int index, int value)
{
  int status = 0;
  int32_t *addr = NULL;
  addr = malloc(sizeof(int32_t));
  addr[0] = value;
  
  // Write to vector
  status = vec_set(X, (char *)addr, index, 1); cBYE(status);
  status = vec_check(X); cBYE(status);
BYE:
  return status;  
}

int
main()
{
  int status = 0;
  for ( int i = 0; i < NUM_TRIALS; i++ ) {
    VEC_REC_TYPE *X = malloc(sizeof(VEC_REC_TYPE));
    status =  vec_new(X, "I4", sizeof(int32_t), CHUNK_SIZE, true); cBYE(status);
    status = vec_materialized(X, "I4_vec.bin", false); cBYE(status);
    status = vec_check(X); cBYE(status);
    
    status = check_elements(X); cBYE(status);
    
    status = set_element(X, 256, 135); cBYE(status);
    
    int32_t iptr = get_element(X, 256, 1);
    
    if ( iptr != 135 ) { go_BYE(-1); }
    
    status = vec_persist(X, true); cBYE(status);
    status = vec_check(X); cBYE(status);
    
    status = vec_free(X); cBYE(status);
    free_if_non_null(X);
  }
BYE:
  if ( status == 0 ) {
    fprintf(stderr, "SUCCESS\n");
  }
  else {
    fprintf(stderr, "FAILUER\n");
  }
  return status;
}
