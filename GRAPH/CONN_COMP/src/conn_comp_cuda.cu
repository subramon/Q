extern "C" {
#include "q_incs.h"
#include "_mmap.h"
}


#define NODE_TYPE int32_t
#define MAXLINE 65535

/*
static __device__ __inline__ uint32_t __mysmid(){
  uint32_t smid;
  asm volatile("mov.u32 %0, %%smid;" : "=r"(smid));
  return smid;}

static __device__ __inline__ uint32_t __mywarpid(){
  uint32_t warpid;
  asm volatile("mov.u32 %0, %%warpid;" : "=r"(warpid));
  return warpid;}

static __device__ __inline__ uint32_t __mylaneid(){
  uint32_t laneid;
  asm volatile("mov.u32 %0, %%laneid;" : "=r"(laneid));
  return laneid;}
*/

__global__
static void
any_change(
    NODE_TYPE *lb,
    NODE_TYPE *ub,
    NODE_TYPE *to,
    NODE_TYPE *lbl,
    uint64_t n_nodes,
    bool *is_any_change
    )
{
  uint64_t index = blockIdx.x * blockDim.x + threadIdx.x;
  uint64_t stride = blockDim.x * gridDim.x;
  for (uint64_t i = index; i < n_nodes; i += stride) {
    // printf("I am thread %d, my SM ID is %d, my warp ID is %d, and my warp lane is %d\n", i, __mysmid(), __mywarpid(), __mylaneid());
    bool l_is_any_change = false;
    if ( ub[i] <= lb[i] ) { continue; }
    NODE_TYPE minval = lbl[i];
    for ( int64_t j = lb[i]; j < ub[i]; j++ ) {
      minval = mcr_min(minval, lbl[to[j]]);
    }
    if ( lbl[i] != minval ) {
      l_is_any_change = true;
      lbl[i] = minval;
    }

    if ( ( l_is_any_change ) && ( *is_any_change == false ) ) {
      // printf("Changed the global is_any_change\n");
      *is_any_change = true;
    }
  }
}


int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  NODE_TYPE *lbl = NULL;
  NODE_TYPE *lb = NULL;
  NODE_TYPE *ub = NULL;
  NODE_TYPE *to = NULL;
  bool *is_any_change = NULL;
  char *lb_X = NULL; size_t lb_nX = 0;
  char *ub_X = NULL; size_t ub_nX = 0;
  char *to_X = NULL; size_t to_nX = 0;

  if ( argc != 1 ) { status = -1; return status; }

  status = rs_mmap("lb.bin", &lb_X, &lb_nX, 0);

  status = rs_mmap("ub.bin", &ub_X, &ub_nX, 0);

  status = rs_mmap("to.bin", &to_X, &to_nX, 0);

  uint64_t n_nodes = lb_nX / sizeof(NODE_TYPE);
  fprintf(stderr, "Working on  %ld nodes \n", n_nodes);

  // Allocate memory for lb, ub, to & lbl using cudaMallocManaged
  cudaMallocManaged(&lbl, lb_nX);
  cudaMallocManaged(&lb, lb_nX);
  cudaMallocManaged(&ub, ub_nX);
  cudaMallocManaged(&to, to_nX);
  cudaMallocManaged(&is_any_change, sizeof(bool));

  if ( lbl == NULL ) { printf("cuda malloc failed for lbl\n"); return -1; }
  if ( lb == NULL ) { printf("cuda malloc failed for lb\n"); return -1; }
  if ( ub == NULL ) { printf("cuda malloc failed for ub\n"); return -1; }
  if ( to == NULL ) { printf("cuda malloc failed for to\n"); return -1; }
  if ( is_any_change == NULL ) { printf("cuda malloc failed for is_any_change\n"); return -1; }

  printf("Memory allocation done\n");

  // Initialize lbl, lb, ub, to, is_any_change
  for ( unsigned int i = 0; i < n_nodes; i++ ) {
    lbl[i] = i;
  }
  memcpy(lb, lb_X, lb_nX);
  memcpy(ub, ub_X, ub_nX);
  memcpy(to, to_X, to_nX);
  *is_any_change = true; // just to get in the first tome

  uint64_t blockSize = 256;
  uint64_t numBlocks = (n_nodes + 256 - 1) / blockSize;

  for ( int iter = 0; *is_any_change == true; iter++ ) {
    // any_change<<<numBlocks, blockSize>>>(lb, ub, to, lbl, n_nodes, &is_any_change);
    for ( int i = 0; i < n_nodes; i++ ) {
      printf("%d\t", lbl[i]);
    }
    printf("\n");
    *is_any_change = false;
    any_change<<<1, 3>>>(lb, ub, to, lbl, n_nodes, is_any_change);
    cudaDeviceSynchronize();
    fprintf(stderr, "Pass %d \n", iter);
  }

  cudaFree(lbl);
  cudaFree(lb);
  cudaFree(ub);
  cudaFree(to);
  cudaFree(is_any_change);
  return status;

}

