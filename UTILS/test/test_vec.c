#include "q_incs.h"
#include "mmap_types.h"
#include "vec.h"

int
main()
{
  int status = 0;
  int32_t *addr = NULL;
  addr = malloc(sizeof(int32_t));
#define NUM_TRIALS   1024
#define NUM_ELEMENTS 65537
#define CHUNK_SIZE   8192
  for ( int i = 0; i < NUM_TRIALS; i++ ) { 
    VEC_REC_TYPE *X = malloc(sizeof(VEC_REC_TYPE));
    status =  vec_new(X, "I4", sizeof(int32_t), CHUNK_SIZE); cBYE(status);
    status = vec_nascent(X); cBYE(status);
    status = vec_check(X); cBYE(status);
    for ( int j = 0; j < NUM_ELEMENTS; j++ ) { 
      addr[0] = (j+1)*10;
      status = vec_set(X, (char *)addr, 0, 1); cBYE(status);
      status = vec_get(X, j, 1); cBYE(status);
      char *ret_addr = X->ret_addr;
      int32_t ret_len = X->ret_len;
      if ( ret_addr == NULL ) { go_BYE(-1); }
      if ( ret_len  != 1 ) { go_BYE(-1); }
      int *iptr = (int *)ret_addr;
      if ( *iptr != (j+1)*10 ) { go_BYE(-1); }
      status = vec_check(X); cBYE(status);
    }
    status = vec_eov(X, false); cBYE(status);
    status = vec_check(X); cBYE(status);
    for ( int j = 0; j < NUM_ELEMENTS; j++ ) { 
      addr[0] = (j+1)*100;
      status = vec_set(X, (char *)addr, j, 1); cBYE(status);
      status = vec_check(X); cBYE(status);
    }
    status = vec_free(X); cBYE(status);
    fprintf(stderr, "Iter = %d \n", i);
  }
BYE:
  if ( status == 0 ) { 
    fprintf(stderr, "SUCCESS\n"); 
  }
  else { 
    fprintf(stderr, "FAILUER\n"); 
  }
  free_if_non_null(addr);
  return status;
}
