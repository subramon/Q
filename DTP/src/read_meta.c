#include "incs.h"
#include "read_meta.h"

int
read_meta(
    const char * const meta_file, 
    int num_features, 
    int num_interior_nodes, 
    meta_t **ptr_meta,
    node_t **ptr_tree
    )
{
  int status = 0;
  meta_t *meta = NULL;
  FILE *fp = NULL;
#define MAXLINE 1048576-1
  char line[MAXLINE+1]; // TODO P4 Fix assumption

  if ( num_interior_nodes <= 0 ) { go_BYE(-1); }
  if ( num_features <= 0 ) { go_BYE(-1); }
  if ( meta_file == NULL ) { go_BYE(-1); }

  meta = malloc(num_interior_nodes * sizeof(meta_t));
  return_if_malloc_failed(meta);
  memset(meta, 0, (num_interior_nodes * sizeof(meta_t)));

  for ( int i = 0; i < num_interior_nodes; i++ ) { 
    meta[i].start_feature = malloc(num_features * sizeof(int));
    return_if_malloc_failed(meta[i].start_feature);
    memset(meta[i].start_feature, 0,  (num_features * sizeof(int)));

    meta[i].stop_feature = malloc(num_features * sizeof(int));
    return_if_malloc_failed(meta[i].start_feature);
    memset(meta[i].stop_feature, 0,  (num_features * sizeof(int)));
  }

  int num_lines = 0;
  fp = fopen(meta_file, "r");
  return_if_fopen_failed(fp, meta_file, "r");
  for ( int i = 0; !feof(fp); i++, num_lines++ ) {
    memset(line, 0, MAXLINE+1); 
    char * cptr = fgets(line, MAXLINE, fp); 
    if ( feof(fp) ) { break; } 
    if ( cptr == NULL ) { go_BYE(-1);  }
    if ( i >= num_interior_nodes ) { go_BYE(-1); } 
    //-----------------------------
    cptr = strtok(line, ",");
    if ( cptr == NULL ) { go_BYE(-1); } 
    meta[i].node_idx = atoi(cptr); 
    //-----------------------------
    for ( int j = 0; j < num_features; j++ ) { 
      meta[num_lines].start_feature[j] = atoi(strtok(NULL, ","));
    }
    for ( int j = 0; j < num_features; j++ ) { 
      meta[num_lines].stop_feature[j] = atoi(strtok(NULL, ","));
    }
    meta[num_lines].count0 = atoi(strtok(NULL, ","));
    meta[num_lines].count1 = atoi(strtok(NULL, ","));
  }
  if ( num_lines != num_interior_nodes ) { go_BYE(-1); } 
  *ptr_meta = meta;
BYE:
  if ( status < 0 ) { 
    free_meta(num_interior_nodes, meta); *ptr_meta = NULL; 
  }
  fclose_if_non_null(fp);
  return status;
}

void
free_meta(
    int num_interior_nodes, 
    meta_t *meta // [num_interior_nodes]
    )
{
  if ( num_interior_nodes <= 0  ) { return; } 
  if ( meta == NULL ) { return; } 
  for ( int i = 0; i < num_interior_nodes; i++ ) {
    free_if_non_null(meta[i].start_feature);
    free_if_non_null(meta[i].stop_feature);
  }
  free(meta);

}
