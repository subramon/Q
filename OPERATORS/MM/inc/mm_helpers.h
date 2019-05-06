extern void 
print_matrix(
    double** m, 
    int rows, 
    int cols
    );
extern int 
alloc_matrix(
    int num_rows, 
    int num_cols,
    double ***ptr_x
    );
extern void
free_matrix(
    double **m,
    int num_cols
    );
extern int
set_matrix(
    double **m, 
    int num_rows, 
    int num_cols
    );
extern bool
cmp_matrix(
    double **x,
    double **y,
    int m,
    int n,
    double threshold
    );
extern uint64_t 
RDTSC(void);
