extern int
stoF4(
      const char *X,
      float *ptr_valF4
      )
;
//----------------------------
extern int
stoB(
      const char *X,
      bool *ptr_B
      )
;
//----------------------------
extern int
stoF8(
      const char *X,
      double *ptr_valF8
      )
;
//----------------------------
extern int
stoI1(
      const char *X,
      char *ptr_Y
      )
;
//----------------------------
extern int
stoI2(
      const char *X,
      short *ptr_Y
      )
;
//----------------------------
extern int
stoI4(
      const char *X,
      int *ptr_Y
      )
;
//----------------------------
extern int
stoI8(
      const char *X,
      long long *ptr_Y
      )
;
//----------------------------
extern int
read_nth_val( /* n starts from 0 */
	     const char *in_str,
	     const char *delim,
	     int n,
	     char *out_str,
	     int len_out_str
	      )
;
//----------------------------
extern int
break_str(
	  char *X,
	  char *delim,
	  char ***ptr_Y,
	  int *ptr_nY
	  )
;
//----------------------------
extern int
num_lines(
	  char *infile,
	  int *ptr_num_lines
	  )
;
//----------------------------
extern int
explode(
	const char *in_X,
	const char delim,
	char ***ptr_Y,
	int *ptr_nY
	)
;
//----------------------------
extern int
extract_name_value(
		   char *in_str,
		   const char *start,
		   const char *stop,
		   char **ptr_val
		   )
;
//----------------------------
extern bool is_directory(
		  char *in_dir
		  )
;
//----------------------------
extern int delete_directory(
		     char *dir_to_del
		     )
;
//----------------------------
extern bool dir_exists (
		 const char *dir_name
		 )
;
//----------------------------
extern bool file_exists (
		  const char *filename
		  )
;
//----------------------------
extern int
strip_trailing_slash(
		     const char *in_str, 
		     char *out_str,
		     int out_len
		     )
;
//----------------------------
extern int
get_disk_space ( 
		char * dev_path,
		unsigned long long *ptr_nbytes,
		char *mode
		 )
;
//----------------------------
extern int
count_char(
	   const char *X,
	   char c,
	   int *ptr_n
	   )
;
//----------------------------
extern int
strip_extra_spaces(
		   char *X
		   )
;
//----------------------------
extern unsigned long long get_time_usec(
    )
;
//----------------------------
extern int
copy_file(
	  char *from_dir,
	  char *filename,
	  char *to_dir
	  )
;
//----------------------------
extern int 
avail_space(
	    char *dir,
	    unsigned long long *ptr_avail_space
	    )
;
//----------------------------
extern void
zero_string(
	    char *X,
	    const int nX
	    )
;
//----------------------------
extern void
zero_string_to_nullc(
		     char *X
		     )
;
//----------------------------
extern unsigned long long 
two_raised_to(
	      unsigned int n
	      )
;
//----------------------------
extern int
csv_to_json(
	    char *infile,
	    char **ptr_Y, 
	    size_t *ptr_nY
	    )
;
//----------------------------
extern bool
is_legal_env_var(
		 char *env_var
		 )
;
//----------------------------
extern bool
is_absolute_path(
		 char *X
		 )
;
//----------------------------
extern int
str_to_argv(
    char *qstr, 
    char **qargv, 
    int max_num_args,
    int max_len_arg,
    int *ptr_qargc
    )
;
//----------------------------
extern bool
alldigits(
    char *X
    )
;
//----------------------------
extern bool
chk_tbl_name(
    char *tbl
    )
;
//----------------------------
extern bool
chk_fld_prop(
    char *X
    )
;
//----------------------------
extern int 
chk_is_ctbl(
    char *tbl,
    bool *ptr_is_ctbl
    )
;
//----------------------------
