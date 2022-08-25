#include <stdio.h>
#include "foo.h"
extern int g_foobar;

int
foo(
   int x
   )
{
  printf("NEW = %d, OLD = %d \n", x, g_foobar);
  g_foobar = x;
  return 0;
}
