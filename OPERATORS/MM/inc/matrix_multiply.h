extern int 
mm_simple(
    double ** x, 
    double ** y, 
    double ** z, 
    int m,
    int k,
    int n
    );
extern int 
mm_fast_many_cols(
    double ** x, 
    double ** y, 
    double ** z, 
    int m,
    int k,
    int n
    );
extern int 
mm_fast_many_rows(
    double ** x, 
    double ** y, 
    double ** z, 
    int m,
    int k,
    int n
    );
extern bool
cmp_matrix(
    double **x,
    double **y,
    int m,
    int n,
    double threshold
    );
extern int 
mm_fast_1d_alt(
    double ** x, 
    double ** y, 
    double ** z, 
    int m,
    int k,
    int n
    );
extern int 
mvmul_a(
    double ** x, 
    double * y, 
    double * z, 
    int m,
    int k
    );
