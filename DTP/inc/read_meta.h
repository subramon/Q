extern int
read_meta(
    const char * const meta_file, 
    int num_features, 
    int num_interior_nodes, 
    meta_t **ptr_meta,
    node_t **ptr_tree
    );
extern void
free_meta(
    int num_interior_nodes, 
    meta_t *meta // [num_interior_nodes]
    );
