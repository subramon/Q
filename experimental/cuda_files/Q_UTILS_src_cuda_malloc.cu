extern "C" {
//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "_cuda_malloc.h"
}

//START_FUNC_DECL
int
cuda_malloc(
    void **ptr,
    int64_t N
    )
//STOP_FUNC_DECL
{
  int status = 0;
  // CUDA: malloc using cudaMallocManaged
  cudaMallocManaged(ptr, N);
BYE:
  return status;
}
