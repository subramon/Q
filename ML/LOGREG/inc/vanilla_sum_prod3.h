#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include "q_macros.h"

extern int
vanilla_sum_prod3(
    float **X, /* M vectors of length N */
    uint64_t M,
    uint64_t N,
    double *w, /* vector of length N */
    double **A /* M vectors of length M */
);
