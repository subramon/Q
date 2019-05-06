extern int
dnn_check(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_delete(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_train(
    DNN_REC_TYPE *ptr_X,
    float ** const cptrs_in, /* [npl[0]][nI] */
    float ** const cptrs_out, /* [npl[nl-1]][nI] */
    uint64_t nI // number of instances
    );
extern int
dnn_bprop(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_free(
    DNN_REC_TYPE *ptr_X
    );
extern int
dnn_new(
    DNN_REC_TYPE *ptr_X,
    int nl,
    int *npl,
    float *dpl,
    const char * const afns
    );
extern int dnn_set_bsz(
    DNN_REC_TYPE *ptr_dnn,
    int bsz
    );
extern int dnn_unset_bsz(
    DNN_REC_TYPE *ptr_dnn
    );
extern int
dnn_test(
    DNN_REC_TYPE *ptr_dnn,
    float ** const cptrs_in,
    float *out
    );
