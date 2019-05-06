typedef struct _ab_args_type {
  char conf_file[100];
  int size;
  float * values;
} AB_ARGS_TYPE;

extern int
init_ab(
    const char *conf_file,
    int size,
    AB_ARGS_TYPE **ptr_rslt
    );
extern int
sum_ab(
   void *in_ptr_args,
   int factor,
   int *ptr_sum
   );
extern void
print_ab(
     void *in_ptr_args
     );
extern int
free_ab(
    void *in_ptr_args
    );
