#include "q_incs.h"
#include "mink.h"

int 
main(
    int argc,
    char **argv
    ) 
{
  int status = 0;
  int32_t *val = NULL, *drag = NULL;
  REDUCE_mink_ARGS args;
  args.n = 0;
  args.k = 0;
  args.val  = NULL;
  args.drag = NULL;

  int size, k, block_size; // modify these for testing 
  if ( argc == 1 ) { 
    size = 20; 
    k = 6;
    block_size = 4;
  }
  else {
    if ( argc != 4 ) { go_BYE(-1); }
    size = atoi(argv[1]); if ( size < 1 ) { go_BYE(-1); }
    k    = atoi(argv[2]); if ( k < 1 ) { go_BYE(-1); }
    block_size    = atoi(argv[3]); if ( block_size < 1 ) { go_BYE(-1); }
  }

  val = malloc(size * sizeof(int32_t));
  drag = malloc(size * sizeof(int32_t));
  for ( int i = 0; i < size; i++ ) {
    val[i] = i+1;
    drag[i] = -1*(i+1);
  }
  /*
  printf("Inputs are \n");
  for ( int i = 0; i < size; i++ ) {
    printf("%d\t%d\n", val[i], drag[i]);
  }
  */

  // Struct initialization
  args.val  = malloc(k * sizeof(int32_t));
  args.drag = malloc(k * sizeof(int32_t));
  
  // Initialize struct
  args.n = 0;
  args.k = k;
  for ( int i = 0; i < k; i++ ) {
    args.val[i]  = INT_MAX;
    args.drag[i] = INT_MIN; // any "junk" value
  }

  // Call mink
  int num_blocks = size / block_size;
  if ( ( num_blocks * block_size ) != size ) { num_blocks++; } 
  for ( int i = 0; i < 2; i++ ) {
    int lb = i * block_size;
    int ub = lb + block_size;
    if ( ub > size ) { ub = size; }
    status = mink(val+lb, (ub-lb), drag+lb, &args);
    cBYE(status);
  }
  printf("k distances and respective goals are\n");
  for ( int i = 0; i < k; i++ ) {
    printf("%d\t%d\n", args.val[i], args.drag[i]);
  }
BYE:
  free_if_non_null(args.val);
  free_if_non_null(args.drag);
  free_if_non_null(val);
  free_if_non_null(drag);
  return status;
}
