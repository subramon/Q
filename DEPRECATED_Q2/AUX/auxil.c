#include <stdio.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <limits.h>
#include <math.h>
#include <string.h>
#include <strings.h>
#include <dirent.h>
#include "qtypes.h"
#include "macros.h"
#include "mmap.h"
#include "auxil.h"

// START FUNC DECL
int
stoF4(
      const char *X,
      float *ptr_valF4
      )
// STOP FUNC DECL
{
  int status = 0;
  char *endptr;
  double valF8;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  valF8 = strtod(X, &endptr);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  // TODO P1 WTF??? Following needs to be commented out??
  // if ( ( valF8 < FLT_MIN ) || ( valF8 > FLT_MAX ) ) { go_BYE(-1); }
  *ptr_valF4 = valF8;
 BYE:
  return status ;
}

// START FUNC DECL
int
stoB(
      const char *X,
      bool *ptr_B
      )
// STOP FUNC DECL
{
  int status = 0;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  if ( strcasecmp(X, "true") == 0 ) { 
    *ptr_B = true;
  }
  else if ( strcasecmp(X, "false") == 0 ) { 
    *ptr_B = false;
  }
  else {
    go_BYE(-1);
  }
 BYE:
  return status ;
}
//
// START FUNC DECL
int
stoF8(
      const char *X,
      double *ptr_valF8
      )
// STOP FUNC DECL
{
  int status = 0;
  char *endptr;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  *ptr_valF8 = strtod(X, &endptr);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
 BYE:
  return status ;
}

// START FUNC DECL
int
stoI1(
      const char *X,
      int8_t *ptr_Y
      )
// STOP FUNC DECL
{
  int status = 0;
  char *endptr;
  long long Y;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { 
    go_BYE(-1); }
  Y = strtoll(X, &endptr, 10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  if ( ( Y < SCHAR_MIN ) || ( Y > SCHAR_MAX ) ) { go_BYE(-1); }
  *ptr_Y = Y;
 BYE:
  return status ;
}

// START FUNC DECL
int
stoI2(
      const char *X,
      int16_t *ptr_Y
      )
// STOP FUNC DECL
{
  int status = 0;
  char *endptr;
  long long Y;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  Y = strtoll(X, &endptr, 10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { go_BYE(-1); }
  if ( ( Y < SHRT_MIN ) || ( Y > SHRT_MAX ) ) { 
    fprintf(stderr, "not a short = [%s] \n", X);
    go_BYE(-1); }
  *ptr_Y = Y;
 BYE:
  return status ;
}

// START FUNC DECL
int
stoI4(
      const char *X,
      int32_t *ptr_Y
      )
// STOP FUNC DECL
{
  int status = 0;
  char *endptr;
  long long Y;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { 
    go_BYE(-1); }
  Y = strtoll(X, &endptr, 10);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { 
    fprintf(stderr, "endptr = [%s]\n", endptr);
    fprintf(stderr, "X = [%s]\n", X);
    go_BYE(-1); 
  }
  if ( ( Y < INT_MIN ) || ( Y > INT_MAX ) ) { go_BYE(-1); }
  *ptr_Y = Y;
 BYE:
  return status ;
}

// START FUNC DECL
int
stoI8(
      const char *X,
      int64_t *ptr_Y
      )
// STOP FUNC DECL
{
  int status = 0;
  char *endptr;
  if ( ( X == NULL ) || ( *X == '\0' ) ) { go_BYE(-1); }
  *ptr_Y = strtoll(X, &endptr, 0);
  if ( ( *endptr != '\0' ) && ( *endptr != '\n' ) ) { 
    go_BYE(-1); 
  }
 BYE:
  return status ;
}


// START FUNC DECL
int
read_nth_val( /* n starts from 0 */
	     const char *in_str,
	     const char *delim,
	     int n,
	     char *out_str,
	     int len_out_str
	      )
// STOP FUNC DECL
{
  int status = 0;

  if ( len_out_str < 2 ) { go_BYE(-1); }
  if ( out_str == NULL ) { go_BYE(-1); }
  if (  delim  == NULL ) { go_BYE(-1); }
  if (  in_str == NULL ) { go_BYE(-1); }
  if ( n < 0 ) { go_BYE(-1); }

  // advance cptr until we have crossed n occurrences of delim
  char *cptr = (char *)in_str;
  int n_delim = strlen(delim);
  if ( n_delim <= 0 ) { go_BYE(-1); }

  int i = 0;
  for ( ; ( ( i < n )  && ( *cptr != '\0' ) && ( *cptr != '\n' ) ) ; ) { 
    if ( strncmp(cptr, delim, n_delim) == 0 ) { 
      cptr += n_delim;
      i++; 
    }
    else {
      cptr++;
    }
  }
  //------------------------
  if ( i < n ) { // Insufficient elements
    *out_str = '\0';// null terminate string 
  }
  else {
    int j = 0;
    for ( j = 0; ( ( *cptr != '\0' ) && ( *cptr != '\n' ) ) ; j++ ) { 
      if ( strncmp(cptr, delim, n_delim) == 0 ) { break; }
      if ( j == (len_out_str-1) ) { go_BYE(-1); } // no space
      out_str[j]= *cptr++;
    }
    out_str[j] = '\0'; // null terminate string 
  }

 BYE:
  return status ;
}
// START FUNC DECL
int
break_str(
	  char *X,
	  char *delim,
	  char ***ptr_Y,
	  int *ptr_nY
	  )
// STOP FUNC DECL
{
  int status = 0;
  char **Y = NULL; int nY = 0; 
  char *bak_X = X; char *cptr = NULL;

  if ( X == NULL ) { go_BYE(-1); }
  if ( *X == '\0' ) { goto BYE; }
  nY = 1;
  for ( ; *bak_X != '\0'; bak_X++ ) { 
    if( *bak_X == ':' ) {
      nY++;
    }
  }
  Y = (char **)malloc(nY * sizeof(char *));
  return_if_malloc_failed(Y);
  for ( int i = 0; i < nY; i++ ) {
    Y[i] = NULL;
  }
  bak_X = X;
  for ( int i = 0; i < nY; i++ ) {
    cptr = strsep(&bak_X, delim);
    if ( ( cptr == NULL ) || ( *cptr == '\0' ) ) { go_BYE(-1); }
    Y[i] = (char *)malloc(strlen(cptr) + 1);
    return_if_malloc_failed(Y[i]);
    zero_string(Y[i], strlen(cptr) + 1);
    strcpy(Y[i], cptr);
  }
  *ptr_nY = nY;
  *ptr_Y  = Y;
 BYE:
  return status ;
}

// START FUNC DECL
int
num_lines(
	  char *infile,
	  int *ptr_num_lines
	  )
// STOP FUNC DECL
{
  int status = 0;
  char *X = NULL;  size_t nX = 0;
  int num_lines = 0;

  if ( ( infile == NULL ) || ( *infile == '\0' ) ) { go_BYE(-1); }
  rs_mmap(infile, &X, &nX, 0);
  for ( size_t i = 0; i < nX; i++ ) { 
    if ( X[i] == '\n' ) { num_lines++; }
  }
  *ptr_num_lines = num_lines;
 BYE:
  rs_munmap(X, nX);
  return status ;
}
//-------------------------------------------------------------
// START FUNC DECL
int
explode(
	const char *in_X,
	const char delim,
	char ***ptr_Y,
	int *ptr_nY
	)
// STOP FUNC DECL
{
  int status = 0;
  char **flds = NULL;
  int len, n_flds;
  char *cptr = NULL; 

  *ptr_Y = NULL; *ptr_nY = 0;
  if ( ( in_X == NULL ) || ( *in_X == '\0' ) )  { return status ; }

  n_flds = 1; cptr = (char *)in_X; len = strlen(in_X) + 1;
  for ( ; *cptr != '\0' ; cptr++ ) {
    if ( *cptr == delim ) {
      n_flds++;
    }
  }
  flds = malloc(n_flds * sizeof(char *));
  return_if_malloc_failed(flds);
  for ( int i = 0; i < n_flds; i++ ) { 
    flds[i] = malloc(len * sizeof(char));
    return_if_malloc_failed(flds[i]);
    zero_string(flds[i], len);
  }
  int fld_idx = 0; 
  cptr = (char *)in_X; 
  for ( int char_idx = 0; *cptr != '\0' ; cptr++ ) {
    if ( char_idx >= len ) { go_BYE(-1); }
    if ( *cptr == delim ) {
      if ( fld_idx >= n_flds ) { go_BYE(-1); }
      flds[fld_idx][char_idx++] = '\0';
      char_idx = 0;
      fld_idx++;
    }
    else {
      flds[fld_idx][char_idx++] = *cptr;
    }
  }
  if ( (fld_idx+1) != n_flds ) { go_BYE(-1); }

  *ptr_nY = n_flds;
  *ptr_Y =  flds;
 BYE:
  return status ;
}
// START FUNC DECL
int
extract_name_value(
		   char *in_str,
		   const char *start,
		   const char *stop,
		   char **ptr_val
		   )
// STOP FUNC DECL
{
  int status = 0;
  char *val = NULL;
  char *cptr1, *cptr2, *cptr3;
  int len, in_str_len;

  if ( in_str == NULL ) { go_BYE(-1); }
  if ( ( start == NULL ) || ( *start == '\0' ) ) { go_BYE(-1); }
  if ( ( stop == NULL )  || ( *stop  == '\0' ) ) { go_BYE(-1); }

  cptr1 = strstr(in_str, start);
  in_str_len = strlen(in_str);
  if ( ( cptr1 == NULL ) || ( *cptr1 == '\0' ) ) { 
    // Not there 
  }
  else { // Now advance to after the start string and look for stop string
    cptr2 = cptr1 + strlen(start);
    cptr3 = strstr(cptr2, stop);
    if ( cptr3 == cptr2 ) { 
      // Not there 
    }
    else {
      if ( cptr3 == NULL ) {
	len = in_str_len - ( cptr2 - in_str );
      }
      else {
        len = cptr3 - cptr2;
      }
      len++;
      val = (char *)malloc(len * sizeof(char));
      return_if_malloc_failed(val);
      zero_string(val, len);
      strncpy(val, cptr2, len-1);
    }
  }
  *ptr_val = val;
 BYE:
  return status ;
}
int
alt_extract_name_value(
		   const char *in_str,
		   const char *start,
		   const char *stop,
                   char *val, /* [len] */
                   int maxlen
		   )
// STOP FUNC DECL
{
  int status = 0;
  char *cptr1, *cptr2, *cptr3;
  int len, in_str_len;

  if ( in_str == NULL ) { go_BYE(-1); }
  if ( ( start == NULL ) || ( *start == '\0' ) ) { go_BYE(-1); }
  if ( ( stop == NULL )  || ( *stop  == '\0' ) ) { go_BYE(-1); }

  cptr1 = strstr(in_str, start);
  in_str_len = strlen(in_str);
  if ( ( cptr1 == NULL ) || ( *cptr1 == '\0' ) ) { 
    // Not there 
  }
  else { // Now advance to after the start string and look for stop string
    cptr2 = cptr1 + strlen(start);
    cptr3 = strstr(cptr2, stop);
    if ( cptr3 == cptr2 ) { 
      // Not there 
    }
    else {
      if ( cptr3 == NULL ) {
	len = in_str_len - ( cptr2 - in_str );
      }
      else {
        len = cptr3 - cptr2;
      }
      len++;
      if ( len >= maxlen ) { go_BYE(-1); }
      zero_string(val, maxlen);
      strncpy(val, cptr2, len-1);
    }
  }
 BYE:
  return status ;
}

// START FUNC DECL
bool is_directory(
		  char *in_dir
		  )
// STOP FUNC DECL
{
  DIR *dir = NULL;
  if ( ( in_dir == NULL ) || ( *in_dir == '\0' ) ) { return(false); }
  dir = opendir(in_dir);
  if ( dir == NULL ) { 
    return false; 
  } 
  else { 
    closedir(dir); return true; 
  }
}

// START FUNC DECL
int delete_directory(
		     char *dir_to_del
		     )
// STOP FUNC DECL
{
  int status = 0;
  struct dirent *d = NULL;
  DIR *dir = NULL;
  char buf[256];

  if ( ( dir_to_del == NULL ) || ( *dir_to_del == '\0' ) ) { go_BYE(-1); }
  dir = opendir(dir_to_del);
  if ( dir == NULL ) { return status ; }
  for ( ; ; ) {
    d = readdir(dir);
    if ( d == NULL ) { break; } 
    if ( strcmp(d->d_name, ".") == 0 ) { continue; }
    if ( strcmp(d->d_name, "..") == 0 ) { continue; }
    // printf("Deleting %s\n",d->d_name);
    sprintf(buf, "%s/%s", dir_to_del, d->d_name);
    remove(buf);
  }
  closedir(dir);
  remove(dir_to_del);
 BYE:
  return status ;
}

// START FUNC DECL
bool dir_exists (
		 const char *dir_name
		 )
// STOP FUNC DECL
{
  DIR *dir = NULL;
  if ( ( dir_name == NULL ) || ( *dir_name == '\0' ) ) { return false; }
  dir = opendir(dir_name);
  if ( dir == NULL ) { return false; }
  free_if_non_null(dir);
  return(true);
}

// START FUNC DECL
bool file_exists (
		  const char *filename
		  )
// STOP FUNC DECL
{
  int status = 0; struct stat buf;
  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { return false; }
  status = stat(filename, &buf );
  if ( status == 0 ) { /* File found */
    return true;
  }
  else {
    return false;
  }
}
// START FUNC DECL
int
strip_trailing_slash(
		     const char *in_str, 
		     char *out_str,
		     int out_len
		     )
// STOP FUNC DECL
{
  int status = 0;
  if ( in_str == NULL ) { go_BYE(-1); }
  if ( out_str == NULL ) { go_BYE(-1); }
  if ( out_len <= 0 ) { go_BYE(-1); }

  zero_string(out_str, out_len);
  int in_len = strlen(in_str);
  if ( in_len >= out_len ) { go_BYE(-1); }
  strcpy(out_str, in_str);
  for ( int i = in_len-1; i >= 0 ; i-- ) { 
    if ( out_str[i] == '/' ) { 
      out_str[i] = '\0';  
    }
    else {
      break;
    }
  }
  if ( strlen(out_str) == 0 ) { go_BYE(-1); }
 BYE:
  return status ;
}

// START FUNC DECL
int
get_disk_space ( 
		char * dev_path,
		unsigned long long *ptr_nbytes,
		char *mode
		 )
// STOP FUNC DECL
{
  int status = 0;
  struct statvfs sfs;
  *ptr_nbytes = 0;
  if ( dev_path == NULL ) { go_BYE(-1); }
  if ( mode == NULL ) { go_BYE(-1); }

  // fprintf(stderr, "dev_path = %s \n", dev_path);
  status = statvfs ( dev_path, &sfs); cBYE(status);
  if ( strcmp(mode, "capacity") == 0 ) {
    *ptr_nbytes = (unsigned long long)sfs.f_bsize * sfs.f_blocks;
  }
  else if ( strcmp(mode, "free_space") == 0 ) {
    *ptr_nbytes = (unsigned long long)sfs.f_bsize * sfs.f_bfree;
  }
  else { go_BYE(-1); }
 BYE:
  return status ;
}
// START FUNC DECL
int
count_char(
	   const char *X,
	   char c,
	   int *ptr_n
	   )
// STOP FUNC DECL
{
  int status = 0;
  if ( X == NULL ) { go_BYE(-1); }
  int n = 0, len = strlen(X);
  
  for ( int i = 0; i < len; i++ ) { 
    if ( X[i] == c ) { n++; }
  }
  *ptr_n = n;
 BYE:
  return status ;
}

// START FUNC DECL
int
strip_extra_spaces(
		   char *X
		   )
// STOP FUNC DECL
{
  int status = 0;
  if ( X == NULL )  { go_BYE(-1); }
  int i, len;
  len = strlen(X); if ( len == 0 ) { goto BYE; }
  // strip trailing spaces
  for ( i = len-1 ; i >= 0; i++ ) { 
    if ( isspace(X[i]) ) { X[i] =  '\0'; } else { break; }
  }
  len = strlen(X); if ( len == 0 ) { goto BYE; }
  // strip leading spaces
  int k = 0;
  for ( i = 0; i < len; i++ ) { 
    if ( isspace(X[i]) ) {
      k=i+1;
    }
    else {
      break;
    }
  }
  //-----------------
  for ( i = 0; i < len-k; i++ ) {
    X[i] = X[i+k];
  }
  for ( i = len -k; i < len; i++ ) { 
    X[i]= '\0';
  }
  //-----------------
  // strip extra spaces in between
 BYE:
  return status ;
}

#ifdef IPP
struct timezone {
  int tz_minuteswest;     /* minutes west of Greenwich */
  int tz_dsttime;         /* type of DST correction */
};
#endif


// START FUNC DECL
uint64_t get_time_usec(
    )
// STOP FUNC DECL
{
  struct timeval Tps;
  struct timezone Tpf;
  unsigned long long t = 0, t_sec = 0, t_usec = 0;

  gettimeofday (&Tps, &Tpf);
  t_sec  = (uint64_t )Tps.tv_sec;
  t_usec = (uint64_t )Tps.tv_usec;
  t = t_sec * 1000000 + t_usec;
  return(t);
}

// START FUNC DECL
int
copy_file(
	  char *from_dir,
	  char *filename,
	  char *to_dir
	  )
// STOP FUNC DECL
{
  int status = 0;
  char *buf1 = NULL; char *X1 = NULL; size_t nX1 = 0;
  char *buf2 = NULL; FILE *fp2 = NULL; size_t nw = 0;

  if ( ( from_dir == NULL ) || ( *from_dir == '\0' ) ) { go_BYE(-1); }
  if ( ( to_dir   == NULL ) || ( *to_dir   == '\0' ) ) { go_BYE(-1); }
  if ( strcmp(from_dir, to_dir) == 0 ) { go_BYE(-1); }

  int len1 = strlen(from_dir) + strlen(filename) + 8;
  buf1 = malloc(len1 *sizeof(char)); return_if_malloc_failed(buf1);
  strcpy(buf1, from_dir); 
  len1 = strlen(buf1); if ( buf1[len1-1] != '/' ) { strcat(buf1, "/"); }
  strcat(buf1, filename);
  status = rs_mmap(buf1, &X1, &nX1, 0); cBYE(status);
  if ( X1  == NULL ) { go_BYE(-1); }
  if ( nX1 == 0  ) { go_BYE(-1); }

  int len2 = strlen(to_dir)   + strlen(filename) + 8;
  buf2 = malloc(len2 *sizeof(char)); return_if_malloc_failed(buf2);
  strcpy(buf2, to_dir); 
  len2 = strlen(buf2); if ( buf2[len2-1] != '/' ) { strcat(buf2, "/"); }

  strcat(buf2, filename);
  if ( strcmp(buf1, buf2) == 0 ) { go_BYE(-1); }
  fp2 = fopen(buf2, "wb");
  return_if_fopen_failed(fp2,  buf2, "wb");
  
  nw = fwrite(X1, sizeof(char), nX1, fp2); 
  if ( nw != nX1 ) { go_BYE(-1); }

 BYE:
  rs_munmap(X1, nX1);
  fclose_if_non_null(fp2);
  free_if_non_null(buf1);
  free_if_non_null(buf2);
  return status ;
}
// START FUNC DECL
int 
avail_space(
	    char *dir,
	    unsigned long long *ptr_avail_space
	    )
// STOP FUNC DECL
{
  int status = 0;
  struct statvfs sbuf;

  status = statvfs(dir , &sbuf); cBYE(status);
  *ptr_avail_space = (unsigned long long)sbuf.f_bsize * 
    (unsigned long long)sbuf.f_bavail;
 BYE:
  return status ;
}


// START FUNC DECL
void
zero_string(
	    char *X,
	    const int nX
	    )
// STOP FUNC DECL
{
  for ( int i = 0; i < nX; i++ ) { X[i] = '\0'; } 
}


// START FUNC DECL
void
zero_string_to_nullc(
		     char *X
		     )
// STOP FUNC DECL
{
  for ( ; *X != '\0'; X++ ) { 
    *X = '\0';
  }
}


// START FUNC DECL
unsigned long long 
two_raised_to(
	      unsigned int n
	      )
// STOP FUNC DECL
{
  long long rslt = 1;
  for ( unsigned int i = 0; i < n; i++ ) { 
    rslt *= 2;
  }
  return(rslt);
}

//<hdr>
int 
xcat(
     const char *buf, 
     char *Y, 
     size_t nY, 
     size_t *ptr_iY
     )
//</hdr>
{
  int status = 0;
  size_t iY = *ptr_iY;
  if ( ( buf == NULL ) || ( *buf == '\0' ) ) { go_BYE(-1); }
  int len = strlen(buf);
  if ( iY + len > nY ) { go_BYE(-1); }
  strncpy(Y+iY, buf, len);
  iY += len;
  *ptr_iY = iY;
 BYE:
  return status ;
}

// START FUNC DECL
bool
is_legal_env_var(
		 char *env_var
		 )
// STOP FUNC DECL
{
  if ( env_var == NULL ) { return false; }
  int len = strlen(env_var); if ( len == 0 ) { return(false); }
  if ( len > MAX_LEN_FLD_NAME ) { return(false); }
  for ( int i = 0; i < len; i++ ) {
    if ( ( isdigit(env_var[i]) ) || ( isalpha(env_var[i]) ) || ( env_var[i] == '_' ) ) {
      /* all is well */
    }
    else {
      return(false);
    }
  }
  return(true);
}

// START FUNC DECL
bool
is_absolute_path(
		 char *X
		 )
// STOP FUNC DECL
{
  if ( X == NULL ) { return false; }
  if ( *X != '/' ) { return false; }
  for ( char *cptr = X; *cptr != '\0'; cptr++ ) { 
    if ( *cptr == '.' ) { return false; }
  }
  return true;
}
// START FUNC DECL
int
str_to_argv(
    char *qstr, 
    char **qargv, 
    int max_num_args,
    int max_len_arg,
    int *ptr_qargc
    )
// STOP FUNC DECL
{
  int status = 0;
  // skip over leading spaces 
  bool all_done = false;
  char *cptr = qstr;
  int qargc = 0;
  for ( ; ; ) { 
    // skip over spaces, if any 
    for ( ; *cptr != '\0' ; cptr++) {
      if ( !isspace(*cptr) ) { break; }
    }
    if ( *cptr == '\0' ) { break; }
    // Now start copying text into qargv[qargc][..] */
    int argidx = 0;
    for ( ; ; cptr++) {
      if ( qargc >= max_num_args ) { go_BYE(-1); }
      if ( ( isspace(*cptr) ) || ( *cptr == '\0' ) ) {
        qargc++; 
	if ( *cptr == '\0' ) { all_done = true; }
        cptr++; /* skip over space that caused break */ 
        break; 
      }
      if ( argidx >= max_len_arg ) { go_BYE(-1); }
      qargv[qargc][argidx++] = *cptr;
    }
    if ( all_done == true ) { break; } 
  }
  // Delete enclosing single quotes if any 
  for ( int i = 0; i < qargc; i++ ) { 
    if ( qargv[i][0] == '\'' ) {
      int len = strlen(qargv[i]);
      if ( qargv[i][len-1] != '\'' ) { go_BYE(-1); }
      for ( int j = 0; j < len-2; j++ ) {
        qargv[i][j] = qargv[i][j+1];
      }
      qargv[i][len-1] = '\0';
      qargv[i][len-2] = '\0';
    }
  }
  *ptr_qargc = qargc;
BYE:
  return(status);
}

// START FUNC DECL
bool
alldigits(
    char *X
    )
// STOP FUNC DECL
{
  if ( ( X == NULL ) || ( *X == '\0' ) ) { return true; }
  for ( char *cptr = X; *cptr != '\0'; cptr++ ) {
    if ( !isdigit(*cptr) ) { return false; }
  }
  return true;
}
// START FUNC DECL
bool
chk_op_f_to_s(
    char *op,
    char *errstr
    )
// STOP FUNC DECL
{
  int is_ok = 1;
  if ( ( op == NULL ) || ( *op == '\0' ) ) {
    is_ok = 0;
  }
  if ( is_ok == 1 ) { 
    if ( ( strcasecmp(op, "Print")  != 0 )  &&
         ( strcasecmp(op, "Min")  != 0 )  &&
         ( strcasecmp(op, "Max")  != 0 )  &&
         ( strcasecmp(op, "Avg")  != 0 )  &&
         ( strcasecmp(op, "Sum")  != 0 )  &&
         ( strcasecmp(op, "NDV")  != 0 )  &&
         ( strcasecmp(op, "Print")  != 0 )  &&
         ( strcasecmp(op, "ValAtIdx")  != 0 )  &&
         ( strcasecmp(op, "IdxAtVal")  != 0 )  &&
         ( strcasecmp(op, "ApproxNDV")  != 0 )  ) { 
      is_ok = 0;
    }
  }
  if ( is_ok == 0 ) { 
    strcpy(errstr, "op can be any one of [Print,Min,Max,Sum,Avg,");
    strcpy(errstr, "NDV,Print,ValAtIdx,IdxAtVal,ApproxNDV]");
    strcat(errstr, "First 8 characters of user provided op = ");
    strncat(errstr, op, 8);
    return false;
  }
  return true;
}
// START FUNC DECL
bool
chk_add_fld_op(
    char *op,
    char *errstr
    )
// STOP FUNC DECL
{
  int is_ok = 1;
  if ( ( op == NULL ) || ( *op == '\0' ) ) {
    is_ok = 0;
  }
  if ( is_ok == 1 ) { 
    if ( ( strcasecmp(op, "loadcsv")  != 0 )  &&
         ( strcasecmp(op, "loadbin")  != 0 )  ) { 
      is_ok = 0;
    }
  }
  if ( is_ok == 0 ) { 
    strcpy(errstr, "op can be any one of [LoadCSV,LoadBin].");
    strcat(errstr, "First 8 characters of user provided op = ");
    strncat(errstr, op, 8);
    return false;
  }
  return true;
}

// START FUNC DECL
bool
chk_add_tbl_op(
    char *op,
    char *errstr
    )
// STOP FUNC DECL
{
  int is_ok = 1;
  if ( ( op == NULL ) || ( *op == '\0' ) ) {
    is_ok = 0;
  }
  if ( is_ok == 1 ) { 
    if ( ( strcasecmp(op, "new")      != 0 ) && 
         ( strcasecmp(op, "loadcsv")  != 0 )  &&
         ( strcasecmp(op, "loadbin")  != 0 )  &&
         ( strcasecmp(op, "loadhdfs") != 0 ) ) {
      is_ok = 0;
    }
  }
  if ( is_ok == 0 ) { 
    strcpy(errstr, "op can be any one of [New,LoadCSV,LoadBin,LoadHDFS].");
    strcat(errstr, "First 8 characters of user provided op = ");
    strncat(errstr, op, 8);
    return false;
  }
  return true;
}
// START FUNC DECL
bool
chk_tbl_name(
    char *tbl,
    char *errstr
    )
// STOP FUNC DECL
{
  int i = 0;
  if ( ( tbl == NULL ) || ( *tbl == '\0' ) )  {
    strcpy(errstr, "Null Table name"); 
    WHEREAMI; return false; 
  }
  if ( *tbl == '_' ) { 
    strcpy(errstr, "Table name cannot start with underscore"); 
    WHEREAMI; return false; 
  }
  for ( char *cptr = tbl; *cptr != '\0'; cptr++, i++ ) { 
    if ( i > MAX_LEN_TBL_NAME ) { 
      sprintf(errstr, "Table name too long. Exceeds %d characters", MAX_LEN_TBL_NAME);
      WHEREAMI; return false; 
    }
    char letter = *cptr;
    if ( ( ( letter >= '0' ) && ( letter <= '9' ) )  || 
         ( ( letter >= 'a' ) && ( letter <= 'z' ) )  ||
         ( letter == '_' ) || 
         ( ( letter >= 'A' ) && ( letter <= 'Z' ) ) ) {
      /* so far so good */
    }
    else {
      sprintf(errstr, "Non alphanumeric character [%c] at position %d",
          letter, i);
      WHEREAMI; 
      return false;
    }
  }
  return true;
}
// START FUNC DECL
bool
chk_fld_prop(
    char *X
    )
// STOP FUNC DECL
{
  if ( X == NULL ) { WHEREAMI; return false; }
  if ( *X == '\0' ) { WHEREAMI; return false; }
  for ( char *cptr = X; *cptr != '\0'; cptr++ ) { 
    if ( ( !isalnum(*cptr) ) && ( *cptr != '=' ) ) {
      return false;
    }
  }
  return true;
}

// START FUNC DECL
int 
chk_is_ctbl(
    char *tbl,
    bool *ptr_is_ctbl
    )
// STOP  FUNC DECL
{
  int status = 0;
  int n;
  if ( tbl == NULL ) { go_BYE(-1); }
  if ( *tbl == '\0' ) { go_BYE(-1); }
  status = count_char(tbl, '|', &n);
  switch ( n ) { 
    case 0 : *ptr_is_ctbl = false; break; 
    case 1 : *ptr_is_ctbl =  true; break; 
    default : go_BYE(-1); break;
  }
BYE:
  return status;
}

//<hdr>
unsigned int
prime_geq(
	  int n
	  )
//</hdr>
{
  for ( int m = n+1; ; m++ ) {
    if ( is_prime(m) ) {
      return m;
    }
  }
}

//<hdr>
bool
is_prime(
	 unsigned int n
	 )
//</hdr>
{
  if ( n == 0 ) { return false; }
  if ( n == 1 ) { return true; }
  if ( n == 2 ) { return true; }
  if ( n == 3 ) { return true; }
  // int sqrt_n = (int)(sqrt((double)n));
  for ( unsigned int j = 5; j < n/2; j+= 2 ) { 
    if ( ( n % j ) == 0 ) {
      return false;
    }
  }
  return true;
}
