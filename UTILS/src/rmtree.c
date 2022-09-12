#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// POSIX dependencies
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

#include "q_incs.h"
#include "rmtree.h"
int
rmtree(
    const char path[]
    )
{
  int status = 0;
  size_t path_len;
  char *full_path = NULL;
  DIR *dir = NULL;
  struct stat stat_path, stat_entry;
  struct dirent *entry;

  // stat for the path
  stat(path, &stat_path);

  // if path does not exists or is not dir - exit with status -1
  if (S_ISDIR(stat_path.st_mode) == 0) {
    fprintf(stderr, "%s: %s\n", "Is not directory", path);
    go_BYE(-2);  // This may be an acceptable error 
  }

  // if not possible to read the directory for this user
  if ((dir = opendir(path)) == NULL) {
    fprintf(stderr, "%s: %s\n", "Can`t open directory", path);
    go_BYE(-1); 
  }

  // the length of the path
  path_len = strlen(path);

  // iteration through entries in the directory
  while ((entry = readdir(dir)) != NULL) {

    // skip entries "." and ".."
    if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) {
      continue;
    }

    free_if_non_null(full_path);
    // determinate a full path of an entry
    full_path = calloc(path_len + strlen(entry->d_name) + 4, sizeof(char));
    strcpy(full_path, path);
    strcat(full_path, "/");
    strcat(full_path, entry->d_name);

    // stat for the entry
    stat(full_path, &stat_entry);

    // recursively remove a nested directory
    if (S_ISDIR(stat_entry.st_mode) != 0) {
      status = rmtree(full_path); cBYE(status); 
      continue;
    }

    // remove a file object
    if (unlink(full_path) == 0) {
      // printf("Removed a file: %s\n", full_path);
    }
    else {
      printf("Can`t remove a file: %s\n", full_path);
    }
  }

  // remove the devastated directory and close the object of it
  if (rmdir(path) == 0) {
    // printf("Removed a directory: %s\n", path);
  }
  else {
    printf("Can`t remove a directory: %s\n", path);
  }
  status = closedir(dir); cBYE(status);
BYE:
  free_if_non_null(full_path);
  return status;
}

#define UNIT_TEST
#ifdef UNIT_TEST
int
main(
    const int argc, 
    char const *argv[]
    )
{
  int status = 0;
  if (argc != 2) {
    fprintf(stderr, "Missing single operand: path\n"); go_BYE(-1); 
  }

  status = rmtree(argv[1]); cBYE(status); 
BYE:
  return status;
}
#endif // UNIT_TEST
