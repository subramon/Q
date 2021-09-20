#include "types.h"
#include "node_struct.h"
extern int
sclr_eval(
    uint32_t *nH, // [n] 
    uint32_t *nT, // [n] 
    float *X, 
    int m, // number of features
    int n, // number of data points to be classified
    const orig_node_t * const dt,
    int n_dt,
    int depth // for debugging 
    );
