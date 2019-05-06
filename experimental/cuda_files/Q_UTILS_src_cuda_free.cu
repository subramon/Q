extern "C" {
//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "_cuda_free.h"
}

//START_FUNC_DECL
int
cuda_free(
    void *ptr
    )
//STOP_FUNC_DECL
{
  int status = 0;
  // CUDA: free memory allocated using cudaMallocManaged
  cudaFree(ptr);
  return status;
}

