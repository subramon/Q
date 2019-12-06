#include "q_incs.h"

extern int
corr_mat(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double **A /* M vectors of length M */
);
