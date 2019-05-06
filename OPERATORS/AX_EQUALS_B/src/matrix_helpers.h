extern void
free_matrix(
      double **A,
      int n
      );

extern double
index_symm_matrix(
      double ** A,
      int i,
      int j
      );

extern void multiply_symm_matrix_vector(
    double **A,
    double *x,
    int n,
    double *b
    );

extern int alloc_symm_matrix(
    double ***ptr_X,
    int n
    );

extern void
square_symm_matrix(
    double **A,
    double **B,
    int n
    );

extern void
multiply_matrix_vector(
    double **A,
    double *x,
    int n,
    double *b
    );

extern int
alloc_matrix(
    double ***ptr_X,
    int n
    );

extern void
transpose_and_multiply(
    double **A,
    double **C,
    int n
    );

extern void
transpose_and_multiply_matrix_vector(
    double **A,
    double *x,
    int n,
    double *b
    );
