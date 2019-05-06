extern int calc_vote_per_g(
    float **d_train, /* [m][n_train] */
    int m,
    int n_train,
    float **d_test, /* [m][n_test] */
    int n_test,
    float *o_test /* [n_test] */
    );
