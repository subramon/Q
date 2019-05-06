

typedef struct _reduce_sum_F4_args {
  double cum_val;
  } REDUCE_sum_F4_ARGS;

extern int
sum_F4(
      const float * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_sqr_I1_args {
  double cum_val;
  } REDUCE_sum_sqr_I1_ARGS;

extern int
sum_sqr_I1(
      const int8_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_sqr_I4_args {
  double cum_val;
  } REDUCE_sum_sqr_I4_ARGS;

extern int
sum_sqr_I4(
      const int32_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_max_F4_args {
  float cum_val;
  } REDUCE_max_F4_ARGS;

extern int
max_F4(
      const float * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_min_I8_args {
  int64_t cum_val;
  } REDUCE_min_I8_ARGS;

extern int
min_I8(
      const int64_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_max_I1_args {
  int8_t cum_val;
  } REDUCE_max_I1_ARGS;

extern int
max_I1(
      const int8_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_I1_args {
  double cum_val;
  } REDUCE_sum_I1_ARGS;

extern int
sum_I1(
      const int8_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_sqr_F4_args {
  double cum_val;
  } REDUCE_sum_sqr_F4_ARGS;

extern int
sum_sqr_F4(
      const float * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_max_I4_args {
  int32_t cum_val;
  } REDUCE_max_I4_ARGS;

extern int
max_I4(
      const int32_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_min_I4_args {
  int32_t cum_val;
  } REDUCE_min_I4_ARGS;

extern int
min_I4(
      const int32_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_min_I1_args {
  int8_t cum_val;
  } REDUCE_min_I1_ARGS;

extern int
min_I1(
      const int8_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_sqr_I8_args {
  double cum_val;
  } REDUCE_sum_sqr_I8_ARGS;

extern int
sum_sqr_I8(
      const int64_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_sqr_F8_args {
  double cum_val;
  } REDUCE_sum_sqr_F8_ARGS;

extern int
sum_sqr_F8(
      const double * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_I2_args {
  double cum_val;
  } REDUCE_sum_I2_ARGS;

extern int
sum_I2(
      const int16_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_I4_args {
  double cum_val;
  } REDUCE_sum_I4_ARGS;

extern int
sum_I4(
      const int32_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_F8_args {
  double cum_val;
  } REDUCE_sum_F8_ARGS;

extern int
sum_F8(
      const double * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_max_F8_args {
  double cum_val;
  } REDUCE_max_F8_ARGS;

extern int
max_F8(
      const double * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_sqr_I2_args {
  double cum_val;
  } REDUCE_sum_sqr_I2_ARGS;

extern int
sum_sqr_I2(
      const int16_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_min_F8_args {
  double cum_val;
  } REDUCE_min_F8_ARGS;

extern int
min_F8(
      const double * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_max_I2_args {
  int16_t cum_val;
  } REDUCE_max_I2_ARGS;

extern int
max_I2(
      const int16_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_min_F4_args {
  float cum_val;
  } REDUCE_min_F4_ARGS;

extern int
min_F4(
      const float * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_max_I8_args {
  int64_t cum_val;
  } REDUCE_max_I8_ARGS;

extern int
max_I8(
      const int64_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_min_I2_args {
  int16_t cum_val;
  } REDUCE_min_I2_ARGS;

extern int
min_I2(
      const int16_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



typedef struct _reduce_sum_I8_args {
  double cum_val;
  } REDUCE_sum_I8_ARGS;

extern int
sum_I8(
      const int64_t * restrict in,
      uint64_t nR,
      void *ptr_args,
      uint32_t num_threads
      )
;



extern int
vsadd_I1_I1(
      const int8_t * restrict in,
      uint64_t nR,
      int8_t sval,
      int8_t * out
      )
;

extern int
qsort_asc_val_I1_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvneq_I1_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern void free_matrix(
      double **A,
      int n
      );
extern void multiply_matrix_vector(
    double **A,
    double *x,
    int n,
    double *b
    );
extern int alloc_matrix(
    double ***ptr_X,
    int n
    );
extern void
multiply(
    double **A,
    double **B,
    double **C,
    int n
    );
extern void
transpose(
    double **A,
    double **B,
    int n
    );
extern void
print_input(
    double **A,
    double **Aprime,
    double *x,
    double *b,
    int n
    );
extern uint64_t
RDTSC(
    void
    );
extern int
convert_matrix_for_solver(
    double **A,
    int n,
    double ***ptr_Aprime
    );


extern int
vvadd_F4_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvmul_I1_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvgt_F4_I2(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_F8_I8_F8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvmul_I4_F8_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvgeq_F8_I4(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I2_I8_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvleq_I1_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I8_F8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;

extern int
txt_to_SC(
      char * const X,
      char *out,
      size_t sz_out
      );


extern int
vvlt_F8_I2(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I8_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvmul_I8_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgt_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_F8_I4(
      const double * restrict in,
      uint64_t nR,
      int32_t sval,
      double * out
      )
;


extern int
vvgt_I8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_F8_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgeq_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern void
qsort_asc_F8 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvmul_I4_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
qsort_dsc_val_I4_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );



extern int
vsadd_I4_I2(
      const int32_t * restrict in,
      uint64_t nR,
      int16_t sval,
      int32_t * out
      )
;


extern int
vvmul_I1_I8_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvmul_I2_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvsub_F8_I4_F8(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvdiv_I2_I4_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvadd_I1_F4_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvneq_F4_I4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_F8_I1_F8(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;

extern void
qsort_asc_I1 (
     void *const pbase,
     size_t total_elems
     );


extern int
vveq_I4_I1(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I8_I4(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_F4_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvadd_I8_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;



extern int
vsadd_F8_F8(
      const double * restrict in,
      uint64_t nR,
      double sval,
      double * out
      )
;


extern int
vvleq_F8_I4(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_F4_I1(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I4_I8_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvneq_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I2_F8_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;

extern int
qsort_asc_val_F4_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvdiv_F4_I2_F4(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;

extern int
qsort_dsc_val_I4_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvneq_F8_I8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I4_F4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;



extern int
vsadd_I4_F4(
      const int32_t * restrict in,
      uint64_t nR,
      float sval,
      float * out
      )
;


extern int
vvneq_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I8_I2(
      const int64_t * restrict in,
      uint64_t nR,
      int16_t sval,
      int64_t * out
      )
;


extern int
vvleq_F4_I8(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I1_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_F8_I2(
      const double * restrict in,
      uint64_t nR,
      int16_t sval,
      double * out
      )
;


extern int
vvrem_I4_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvadd_I2_F4_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;

extern int
bytes_to_bits(
    uint8_t *in,
    uint64_t n,
    uint64_t *out
    );


extern int
vvgt_F4_I8(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_F8_I8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I4_I2_I4(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;

extern int
qsort_dsc_val_I2_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvlt_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_F4_I8(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I2_I4_I2(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvgeq_F8_F4(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I1_F8_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvneq_I1_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_F4_I1(
      const float * restrict in,
      uint64_t nR,
      int8_t sval,
      float * out
      )
;

extern int
qsort_asc_val_I4_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgt_I1_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_F4_I4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I1_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern void
qsort_asc_F4 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvdiv_I1_I8_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgt_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
SC_to_txt(
    char * const in,
    uint32_t width,
    char * X,
    size_t nX
    );



extern int
vvgeq_I8_I2(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I1_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );

extern void
qsort_dsc_F8 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvdiv_I1_I4_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;

extern void
qsort_dsc_I8 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvsub_F4_I8_F4(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvmul_F8_F4_F8(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvleq_F4_I2(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I1_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvsub_F8_F4_F8(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvgeq_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern void
qsort_asc_I4 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvlt_F4_I8(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I4_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvxor(
      const uint64_t * restrict in1,
      const uint64_t * restrict in2,
      uint64_t nR,
      uint64_t * restrict out
      )
;


extern int
vvrem_I2_I8_I2(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vveq_I4_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int positive_solver(
    double ** A,
    double * x,
    double * b,
    int n
    );


extern int
vvleq_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I1_I4(
      const int8_t * restrict in,
      uint64_t nR,
      int32_t sval,
      int32_t * out
      )
;


extern int
vvadd_F4_I1_F4(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvdiv_I8_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgt_F8_I4(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_F8_I1(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_F4_I2_F4(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;

extern int
qsort_dsc_val_F8_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvlt_F4_I2(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_F4_F8_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvlt_F8_I1(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I2_I4_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvrem_I1_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvsub_I2_I4_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvrem_I2_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;



extern int
vsadd_I2_F8(
      const int16_t * restrict in,
      uint64_t nR,
      double sval,
      double * out
      )
;


extern int
vvdiv_I8_I1_I8(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vveq_I2_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I4_F8_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvgt_I1_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_I8_F4_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvadd_I2_I8_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvdiv_I1_F8_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvadd_I1_I4_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvleq_I2_I1(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I8_I4(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I1_F4_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vveq_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I8_I4_I8(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgt_I1_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vvsub_I1_I8_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvneq_I2_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
F4_to_txt(
    const float * const in,
    const char * const fmt,
    char *X,
    size_t nX
    );

extern void
qsort_asc_I2 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvleq_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I8_I1_I1(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvlt_F8_I4(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
I4_to_txt(
    const int32_t * const in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern int
vvadd_I8_I2_I8(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgeq_I4_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_I1_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
qsort_asc_val_I4_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvrem_I8_I2_I2(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvdiv_F4_F8_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;



extern int
vsadd_I8_I4(
      const int64_t * restrict in,
      uint64_t nR,
      int32_t sval,
      int64_t * out
      )
;


extern int
vvdiv_I4_I1_I4(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvsub_F8_I8_F8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;

extern int
qsort_asc_val_F4_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvlt_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_F4_I2_F4(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvadd_F4_F8_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvgt_I8_I2(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I4_I1(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_F8_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvdiv_I4_I2_I4(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvsub_F8_I2_F8(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvmul_F8_I2_F8(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvlt_I1_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I1_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I4_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_I4_I8_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgeq_F4_I2(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I1_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I1_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_F4_I1(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_F8_I2(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_F4_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;



extern int
vsadd_I4_I4(
      const int32_t * restrict in,
      uint64_t nR,
      int32_t sval,
      int32_t * out
      )
;


extern int
vvneq_F8_I1(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I8_I4(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I4_I8_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvneq_F8_F4(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I2_I8_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;

extern int
qsort_dsc_val_I4_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvleq_I4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I2_I8(
      const int16_t * restrict in,
      uint64_t nR,
      int64_t sval,
      int64_t * out
      )
;



extern int
vsadd_I1_F4(
      const int8_t * restrict in,
      uint64_t nR,
      float sval,
      float * out
      )
;


extern int
vvleq_I8_I1(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_I8_I1_I8(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvneq_F8_I2(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I8_I2(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_F8_I1_F8(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvrem_I4_I2_I2(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvgt_I4_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_I4_F4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvgt_I2_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I4_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_F8_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvdiv_F8_I8_F8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvadd_F8_I1_F8(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvleq_I2_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_F8_F4(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_F4_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvlt_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_F4_I8(
      const float * restrict in,
      uint64_t nR,
      int64_t sval,
      float * out
      )
;

extern int
qsort_dsc_val_I2_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvneq_I1_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I1_I2_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvdiv_I8_I2_I8(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvlt_I2_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_F8_I1(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I8_I4_I4(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;

extern int
qsort_asc_val_I8_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvmul_F8_I4_F8(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vveq_I1_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F4_I8(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I2_F4_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvsub_I4_I1_I4(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvneq_I8_I2(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I1_I2_I1(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvsub_I8_F4_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvlt_F8_F4(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_F4_I8(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I4_I2(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_I1_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvleq_I8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I4_I1_I1(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;



extern int
vsadd_F8_I1(
      const double * restrict in,
      uint64_t nR,
      int8_t sval,
      double * out
      )
;


extern int
vvdiv_I2_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvdiv_I8_I4_I8(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgt_I4_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I2_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I8_I2_I8(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgeq_I1_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I8_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_F4_F8(
      const float * restrict in,
      uint64_t nR,
      double sval,
      double * out
      )
;



extern int
vsadd_I2_I2(
      const int16_t * restrict in,
      uint64_t nR,
      int16_t sval,
      int16_t * out
      )
;


extern int
vvmul_F4_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvgeq_I2_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I8_I1_I8(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvleq_I2_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_I8_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvlt_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I2_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I8_F4_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvgt_I8_I4(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_F8_I8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I4_F4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;

extern int
bits_to_bytes(
    uint64_t *in,
    uint8_t *out,
    uint64_t n_out
    );

extern int
qsort_dsc_val_I1_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvadd_I2_I1_I2(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvor(
      const uint64_t * restrict in1,
      const uint64_t * restrict in2,
      uint64_t nR,
      uint64_t * restrict out
      )
;


extern int
vvgeq_I2_I1(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_I8_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvdiv_F4_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvadd_I4_I1_I4(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvlt_I1_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_F4_I4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I4_I1(
      const int32_t * restrict in,
      uint64_t nR,
      int8_t sval,
      int32_t * out
      )
;


extern int
vvgeq_I2_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_F4_I2_F4(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvleq_I8_I2(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_F8_I4(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I2_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I1_F4_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvdiv_I1_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvadd_I8_I4_I8(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvdiv_F8_F4_F8(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvmul_F4_I4_F4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vveq_F4_I4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I8_F8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;



extern int
vsadd_I8_F8(
      const int64_t * restrict in,
      uint64_t nR,
      double sval,
      double * out
      )
;



extern int
vsadd_F8_F4(
      const double * restrict in,
      uint64_t nR,
      float sval,
      double * out
      )
;


extern int
vvneq_I4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I4_I2(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_I1_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;

extern int
qsort_asc_val_F8_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgeq_F4_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I2_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I4_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgeq_I4_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I8_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvmul_I4_I1_I4(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;

extern int
qsort_dsc_val_F4_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgt_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern void
qsort_dsc_I2 (
     void *const pbase,
     size_t total_elems
     );

extern int
qsort_asc_val_F4_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgt_I1_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I8_I2_I8(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgeq_F8_I8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F4_I2(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I8_I2(
      const int64_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I8_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );

extern int
qsort_asc_val_I2_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvadd_I2_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;

extern int
qsort_dsc_val_F8_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvmul_F8_I1_F8(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvadd_I4_I2_I4(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vveq_I1_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern void
qsort_dsc_F4 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvgeq_I1_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I8_I1(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_F4_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I1_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I1_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vveq_I4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I8_F4(
      const int64_t * restrict in,
      uint64_t nR,
      float sval,
      float * out
      )
;


extern int
vvadd_I4_F8_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;

extern int
qsort_dsc_val_I2_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
I2_to_txt(
    const int16_t * const in,
    const char * const fmt,
    char *X,
    size_t nX
    );



extern int
vsadd_I2_I4(
      const int16_t * restrict in,
      uint64_t nR,
      int32_t sval,
      int32_t * out
      )
;


extern int
vvrem_I1_I4_I1(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;



extern int
vsadd_F4_I4(
      const float * restrict in,
      uint64_t nR,
      int32_t sval,
      float * out
      )
;


extern int
vvsub_I4_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvlt_I1_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I8_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I2_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I1_I4_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvlt_F4_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_F8_I4_F8(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvneq_F4_I1(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I1_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I2_F4_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvleq_F4_I1(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I2_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I4_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F8_I2(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I2_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_F8_F4(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I1_I8_I1(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvleq_I2_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I2_I1_I1(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int8_t * restrict out
      )
;


extern int
vvgt_F4_I4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvand(
      const uint64_t * restrict in1,
      const uint64_t * restrict in2,
      uint64_t nR,
      uint64_t * restrict out
      )
;


extern int
vvlt_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I2_F4_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvdiv_F8_I2_F8(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvsub_I4_I2_I4(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;

extern int
qsort_dsc_val_I8_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvmul_I1_I2_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvleq_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_F4_I8_F4(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvgt_I4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I1_F8(
      const int8_t * restrict in,
      uint64_t nR,
      double sval,
      double * out
      )
;


extern int
vvgeq_F4_I4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_F4_I8_F4(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvgeq_I8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I2_I1_I2(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;

extern void
qsort_asc_I8 (
     void *const pbase,
     size_t total_elems
     );



extern int
vsadd_F8_I8(
      const double * restrict in,
      uint64_t nR,
      int64_t sval,
      double * out
      )
;


extern int
vvdiv_I4_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvlt_I2_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I8_I4(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I8_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I8_I1(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_F4_F8_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vveq_I1_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I2_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvsub_I8_I4_I8(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvgeq_I8_I4(
      const int64_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I4_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I4_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I1_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F8_I8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_F8_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvmul_I4_I8_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvadd_I2_F8_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
F8_to_txt(
    const double * const in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern int
vvgt_F4_I1(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I4_F4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;



extern int
vsadd_I2_F4(
      const int16_t * restrict in,
      uint64_t nR,
      float sval,
      float * out
      )
;

extern void
qsort_dsc_I4 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvmul_F4_I1_F4(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvadd_F8_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvadd_I8_F8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvgt_F8_I2(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_F8_I1(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_F4_I8_F4(
      const float * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;



extern int
vsadd_I2_I1(
      const int16_t * restrict in,
      uint64_t nR,
      int8_t sval,
      int16_t * out
      )
;


extern int
vveq_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I8_I1_I8(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;



extern int
vsadd_I8_I1(
      const int64_t * restrict in,
      uint64_t nR,
      int8_t sval,
      int64_t * out
      )
;


extern int
vvlt_I2_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I4_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I4_I1(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I1_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vveq_I2_I1(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_F8_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgeq_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_F4_I1_F4(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvadd_I2_I4_I4(
      const int16_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvgt_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I1_I8(
      const int8_t * restrict in,
      uint64_t nR,
      int64_t sval,
      int64_t * out
      )
;


extern int
vvlt_F8_I8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I4_I1(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_F4_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );

extern int
qsort_asc_val_I2_idx_I1 (
  int8_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvlt_I8_I1(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_F4_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_F8_idx_I2 (
  int16_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vveq_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I4_I2(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I1_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I2_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I1_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvmul_I2_F8_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vveq_I1_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vvgeq_I2_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_F4_I4_F4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvsub_I2_I2_I2(
      const int16_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;

extern int
qsort_dsc_val_I1_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvdiv_F4_I1_F4(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vveq_F8_F4(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I1_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_I8_I1(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvrem_I4_I8_I4(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvneq_F4_I2(
      const float * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F8_I4(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_I8_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vveq_I4_I8(
      const int32_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I8_F4_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvneq_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I4_I2(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_I1_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I2_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvadd_I4_I4_I4(
      const int32_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
vvleq_F4_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I2_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvandnot(
      const uint64_t * restrict in1,
      const uint64_t * restrict in2,
      uint64_t nR,
      uint64_t * restrict out
      )
;



extern int
vsadd_F4_I2(
      const float * restrict in,
      uint64_t nR,
      int16_t sval,
      float * out
      )
;


extern int
vvdiv_F8_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvdiv_F8_I4_F8(
      const double * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvmul_I1_F8_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;



extern int
vsadd_I4_F8(
      const int32_t * restrict in,
      uint64_t nR,
      double sval,
      double * out
      )
;


extern int
vveq_F8_I1(
      const double * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_asc_val_I8_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );

extern int
qsort_dsc_val_I2_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vveq_I8_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_F8_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );

extern int
qsort_dsc_val_F4_idx_I4 (
  int32_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgt_I2_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I2_I1(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_I1_I2_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvneq_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I1_I2(
      const int8_t * restrict in,
      uint64_t nR,
      int16_t sval,
      int16_t * out
      )
;


extern int
vvlt_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F4_I1(
      const float * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_I4_F8_F8(
      const int32_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;



extern int
vsadd_I8_I8(
      const int64_t * restrict in,
      uint64_t nR,
      int64_t sval,
      int64_t * out
      )
;


extern int
vvsub_I2_I1_I2(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvadd_F8_F4_F8(
      const double * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvmul_I2_I8_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;



extern int
vsadd_F4_F4(
      const float * restrict in,
      uint64_t nR,
      float sval,
      float * out
      )
;

extern void
qsort_dsc_I1 (
     void *const pbase,
     size_t total_elems
     );


extern int
vvmul_I2_I1_I2(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvneq_I8_I1(
      const int64_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F8_F8(
      const double * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_F8_I2_F8(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvdiv_I2_F8_F8(
      const int16_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvgeq_I8_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;

extern int
qsort_dsc_val_I4_idx_I8 (
  int64_t *srt_ordr,
  void *const pbase,
  size_t total_elems
    );


extern int
vvgeq_I4_I1(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vveq_F4_F8(
      const float * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;



extern int
vsadd_I4_I8(
      const int32_t * restrict in,
      uint64_t nR,
      int64_t sval,
      int64_t * out
      )
;


extern int
vvlt_I4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_I1_F8_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvdiv_I1_I2_I2(
      const int8_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      int16_t * restrict out
      )
;


extern int
vvdiv_F4_I4_F4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvmul_I1_I4_I4(
      const int8_t * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      int32_t * restrict out
      )
;


extern int
I1_to_txt(
    const int8_t * const in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern int
vveq_I2_I8(
      const int16_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I4_I2(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_F8_I2(
      const double * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
I8_to_txt(
    const int64_t * const in,
    const char * const fmt,
    char *X,
    size_t nX
    );


extern int
vvgt_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvsub_F4_I4_F4(
      const float * restrict in1,
      const int32_t * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvgeq_I4_F4(
      const int32_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I8_F4(
      const int64_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvdiv_I8_F8_F8(
      const int64_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvneq_I4_I1(
      const int32_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvlt_I2_I1(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I1_F8(
      const int8_t * restrict in1,
      const double * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I2_F4(
      const int16_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvleq_I1_I1(
      const int8_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvneq_I2_I1(
      const int16_t * restrict in1,
      const int8_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgeq_F4_F4(
      const float * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvgt_I4_I2(
      const int32_t * restrict in1,
      const int16_t * restrict in2,
      uint64_t nR,
      uint64_t *restrict out
      )
;


extern int
vvadd_F8_I8_F8(
      const double * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      double * restrict out
      )
;


extern int
vvmul_I1_F4_F4(
      const int8_t * restrict in1,
      const float * restrict in2,
      uint64_t nR,
      float * restrict out
      )
;


extern int
vvadd_I1_I8_I8(
      const int8_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;


extern int
vvrem_I8_I8_I8(
      const int64_t * restrict in1,
      const int64_t * restrict in2,
      uint64_t nR,
      int64_t * restrict out
      )
;
