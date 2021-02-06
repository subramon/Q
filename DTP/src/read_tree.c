#include "incs.h"
#include "read_tree.h"

int
read_tree(
    const char * const tree_file, 
    int num_features, 
    int num_nodes, 
    node_t **ptr_tree
    )
{
  int status = 0;
  node_t *tree = NULL;
  FILE *fp = NULL;
#define MAXLINE 1048576-1
  char line[MAXLINE+1]; // TODO P4 Fix assumption

  if ( num_nodes <= 0 ) { go_BYE(-1); }
  if ( num_features <= 0 ) { go_BYE(-1); }
  if ( tree_file == NULL ) { go_BYE(-1); }

  tree = malloc(num_nodes * sizeof(node_t));
  return_if_malloc_failed(tree);
  memset(tree, 0, (num_nodes * sizeof(node_t)));

  fp = fopen(tree_file, "r");
  return_if_fopen_failed(fp, tree_file, "r");
  char * cptr = NULL;
  // read node index
  memset(line, 0, MAXLINE+1); 
  fgets(line, MAXLINE, fp); 
  if ( line == '\0' ) { go_BYE(-1); }
  for ( int i = 0; i < num_nodes; i++ ) { 
    if ( i == 0 ) { 
      cptr = strtok(line, ",");
    }
    else { 
      cptr = strtok(NULL, ",");
    }
    if ( cptr == NULL ) { go_BYE(-1); }
    if ( atoi(cptr) != i ) { go_BYE(-1); } 
  }
  // read left child 
  memset(line, 0, MAXLINE+1); 
  fgets(line, MAXLINE, fp); 
  if ( line == '\0' ) { go_BYE(-1); }
  for ( int i = 0; i < num_nodes; i++ ) { 
    if ( i == 0 ) { 
      cptr = strtok(line, ",");
    }
    else { 
      cptr = strtok(NULL, ",");
    }
    if ( cptr == NULL ) { go_BYE(-1); }
    tree[i].lchild_idx = atoi(cptr); 
  }
  // read right child 
  memset(line, 0, MAXLINE+1); 
  fgets(line, MAXLINE, fp); 
  if ( line == '\0' ) { go_BYE(-1); }
  for ( int i = 0; i < num_nodes; i++ ) { 
    if ( i == 0 ) { 
      cptr = strtok(line, ",");
    }
    else { 
      cptr = strtok(NULL, ",");
    }
    if ( cptr == NULL ) { go_BYE(-1); }
    tree[i].rchild_idx = atoi(cptr); 
  }
  // read feature index 
  memset(line, 0, MAXLINE+1); 
  fgets(line, MAXLINE, fp); 
  if ( line == '\0' ) { go_BYE(-1); }
  for ( int i = 0; i < num_nodes; i++ ) { 
    if ( i == 0 ) { 
      cptr = strtok(line, ",");
    }
    else { 
      cptr = strtok(NULL, ",");
    }
    if ( cptr == NULL ) { go_BYE(-1); }
    tree[i].feature_idx = atoi(cptr); 
  }
  // read threshold 
  memset(line, 0, MAXLINE+1); 
  fgets(line, MAXLINE, fp); 
  if ( line == '\0' ) { go_BYE(-1); }
  for ( int i = 0; i < num_nodes; i++ ) { 
    if ( i == 0 ) { 
      cptr = strtok(line, ",");
    }
    else { 
      cptr = strtok(NULL, ",");
    }
    if ( cptr == NULL ) { go_BYE(-1); }
    tree[i].threshold = atof(cptr); 
  }
  //initialize meta offset to -1 for all nodes
  for ( int i = 0; i < num_nodes; i++ ) {
    tree[i].meta_offset = -1;
  }
  *ptr_tree = tree;
BYE:
  fclose_if_non_null(fp);
  return status;
}
