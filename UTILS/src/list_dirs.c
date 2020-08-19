/*
 * C Program to List Files in Directory
 */
#include <dirent.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdio.h>
#include "q_macros.h"
#include "list_dirs.h"
 
int 
list_dirs(
    const char * const root,
    char ***ptr_dirs,
    int *ptr_n_dirs
    )
{
  int status = 0;
  char **dirs = NULL;
  DIR *d = NULL;
  struct dirent *dir = NULL;

  int n_dirs;
  if ( root == NULL ) { go_BYE(-1); }
  for ( int iter = 0; iter < 2; iter++ ) { 
    if ( iter == 1 ) { 
      if ( n_dirs == 0 ) { break; } 
      dirs = malloc(n_dirs * sizeof(char *));
      return_if_malloc_failed(dirs);
    }
    n_dirs = 0;
    d = opendir(root);
    if ( d == NULL ) { go_BYE(-1); }
    while ((dir = readdir(d)) != NULL) {
      struct stat buf;
      const char *dir_name = dir->d_name;
      // directory must not start with period 
      if ( ( *dir_name != '.' ) && ( dir->d_type == DT_DIR ) ) { 
        if ( iter == 0 ) { 
          n_dirs++;
        }
        else {
          dirs[n_dirs++] = strdup(dir_name);
        }
      }
      else {
        printf("Rejecting %s \n", dir_name);
      }
    }
    closedir(d); d = NULL;
  }
  *ptr_dirs = dirs;
  *ptr_n_dirs = n_dirs;
BYE:
  return status;
}
#undef STAND_ALONE
#ifdef STAND_ALONE
int main(void) {
  int status = 0;
  char **X = NULL; int nX = 0;
  status = list_dirs(getenv("HOME"), &X, &nX); cBYE(status);
  for ( int i = 0; i < nX; i++ ) { 
    fprintf(stderr, "%d:%s\n", i, X[i]);
  }
BYE:
  if ( X != NULL ) { 
    for ( int i = 0; i < nX; i++ ) { 
      free_if_non_null(X[i]);
    }
  }
  free_if_non_null(X);
  return status;
}
#endif
