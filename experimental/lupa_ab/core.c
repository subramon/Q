#include "incs.h" 
#include "core.h"

int
init_ab(
    const char *conf_file,
    int size,
    AB_ARGS_TYPE **ptr_rslt
    )
{
  int status = 0;
  AB_ARGS_TYPE *rslt = NULL;
  rslt = malloc(sizeof(AB_ARGS_TYPE));
  return_if_malloc_failed(rslt);

  // Initialize structure
  rslt->size = size;
  rslt->values = malloc(sizeof(float)*size);
  for ( int i = 0; i < size; i++ ) {
    rslt->values[i] = i + 1;
  }
  memcpy(rslt->conf_file, conf_file, 100);
  *ptr_rslt = rslt;
BYE:
  return status;
}

int
sum_ab(
   void *in_ptr_args,
   int factor,
   int *ptr_sum
   )
{
  int status = 0;
  *ptr_sum = 0;
  AB_ARGS_TYPE *ptr_ab_args;
  ptr_ab_args = (AB_ARGS_TYPE *)in_ptr_args;
  printf("SIZE = %d\n", ptr_ab_args->size);
  int sum = 0;
  for ( int i = 0; i < ptr_ab_args->size; i++ ) {
    sum = sum + ( factor * ptr_ab_args->values[i] );
  }
  *ptr_sum = sum;
BYE:
  return status;
}

void
print_ab(
     void *in_ptr_args
     )
{
  AB_ARGS_TYPE *ptr_ab_args;
  ptr_ab_args = (AB_ARGS_TYPE *)in_ptr_args;
  printf("=============================================\n");
  printf("Config file name = %s\n", ptr_ab_args->conf_file);
  printf("=============================================\n");
  for ( int i = 0; i < ptr_ab_args->size; i++ ) {
    printf("%f ", ptr_ab_args->values[i]);
  }
  printf("\n");
  printf("=============================================\n");
}

int
free_ab(
    void *in_ptr_args
    )
{
  int status = 0;
  AB_ARGS_TYPE *ptr_ab_args;
  ptr_ab_args = (AB_ARGS_TYPE *)in_ptr_args;
  free(ptr_ab_args->values);
  free(ptr_ab_args);
  printf("Freed up AB structure memory\n");
  return status;
}

int
main()
{
  int status = 0;
  AB_ARGS_TYPE *X = NULL;
  int sum_of_ab;
  status = init_ab("my_config", 20, &X); cBYE(status);
  status = sum_ab(X, 2, &sum_of_ab); cBYE(status);
  printf("Sum = %d\n", sum_of_ab);
  print_ab(X);
  free_ab(X);
BYE:
  return status;
}
