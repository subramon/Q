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
mm_fast_1d_alt(
    double ** x,  /* m by k */
    double ** y,  /* k by 1 */
    double ** z,  /* m by 1 */
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
