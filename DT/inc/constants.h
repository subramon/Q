#undef DEVELOPMENT
#ifdef DEVELOPMENT
#define MIN_LEAF_SIZE 32
#define NUM_FEATURES  2
#define NUM_INSTANCES 1024
#define BUFSZ  3
#endif

#define PERF_TEST
#ifdef PERF_TEST
#define MIN_LEAF_SIZE 64
#define NUM_FEATURES  128
#define NUM_INSTANCES 1048576
#define BUFSZ         1024
#endif
