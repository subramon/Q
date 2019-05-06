#include <stdlib.h>

int 
compare_fn (
const void *a, 
const void *b
)
{
  const int *ia = (const int *)a; // casting pointer types 
  const int *ib = (const int *)b;
  return *ia  - *ib; 
}

int
qsort_asc_I4(
    int *X,
    int n
    )
{
  qsort(X, n, sizeof(int), compare_fn);
  return 0;
}
