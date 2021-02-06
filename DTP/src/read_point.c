#include "incs.h"
#include "read_point.h"

int
read_point(
        float **ptr_point,
        int num_features,
        bool *ptr_all_done
        )
{
  int status = 0; 
  float * point = NULL; 
#define MAXLINE 1024-1
  char line[MAXLINE+1];

  *ptr_all_done = false;
  char *cptr;
  memset(line, 0, MAXLINE+1);
  fgets(line, MAXLINE, stdin);
  // decide if you need to stop
  if ( ( *line == '\0' ) || ( *line == '\n' ) ) { 
    *ptr_all_done = true; return status; 
  }
  point = malloc(num_features * sizeof(float));
  return_if_malloc_failed(point);
  bool invalid = false;
  for ( int i = 0; i < num_features; i++ ) { 
    if ( i == 0 ) { 
      cptr = strtok(line, ",");
    }
    else {
      cptr = strtok(NULL, ",");
    }
    if ( cptr == NULL ) { invalid = true; break; }
    point[i] = atof(cptr);
  }
  // if bad point, delete it 
  if ( invalid ) { 
    free_if_non_null(point); 
    printf("Bad point.. Try again\n"); return -1; 
  }
  // print point to be deleted 
  for ( int i = 0; i < num_features; i++ ) { 
    printf("%f,", point[i]);
  }
  printf("]\n");
  *ptr_point = point;
BYE:
  return status;
}
