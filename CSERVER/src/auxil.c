#include "q_incs.h"
#include "auxil.h"
#include "mmap.h"

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
  if ( ( valF8 < -1.0 * FLT_MAX ) || ( valF8 > FLT_MAX ) ) { go_BYE(-1); }
  if ( abs(valF8) <  FLT_MIN ) { go_BYE(-1); }
  *ptr_valF4 = valF8;
 BYE:
  return status ;
}
//
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
uint64_t 
timestamp(
    void
    )
{
  struct timespec time;
  clock_gettime(CLOCK_REALTIME, &time);
  uint64_t sec = time.tv_sec;
  uint64_t nsec = time.tv_nsec;
  return ( sec * 1000000000 )  + nsec;
}
// START FUNC DECL
uint32_t get_time_sec(
    void
    )
// STOP FUNC DECL
{
  struct timeval Tps;
  struct timezone Tpf;

  gettimeofday (&Tps, &Tpf);
  return (uint32_t )Tps.tv_sec;
}


// START FUNC DECL
uint64_t get_time_usec(
    void
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
  return t;
}
/* assembly code to read the TSC */
uint64_t 
RDTSC(
    void
    )
{
#ifdef RASPBERRY_PI
  return get_time_usec();
#else
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}

bool
is_valid_url_char(
    char c
    )
{
  const char *ok_chars = "-._~:/?#[]@!$&'()*+,;=";
  if ( isalnum(c) ) { return true; }
  for ( char *cptr = (char *)ok_chars; *cptr != '\0'; cptr++ ) { 
    if ( c == *cptr ) { return true; }
  }
  return false;
}
/* URL characters must be in 
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
0123456789
-._~:/?#[]@!$&'()*+,;=
*/
char g_rslt[Q_MAX_LEN_RESULT+1]; // For C: ab_process_req()
int
mk_json_output(
    char *api, 
    char *args, 
    char *err, 
    char *out
    )
{
  int status = 0;
  memset(g_rslt, '\0', Q_MAX_LEN_RESULT+1);
  int n_out = 0; int sz_out = Q_MAX_LEN_RESULT;
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = '{';
  status = add_to_buf(api, "API", g_rslt, sz_out, &n_out); cBYE(status);
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = ',';
  status = add_to_buf(args, "ARGS", g_rslt, sz_out, &n_out); cBYE(status);
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = ',';
  status = add_to_buf(err, "ERROR", g_rslt, sz_out, &n_out); cBYE(status);
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = '}';
  //--------------------------------------
BYE:
  return status;
}
int
add_to_buf(
    char *in,
    const char *label,
    char *out,
    int sz_out,
    int *ptr_n_out
    )
{
  int status = 0;
  int n_out = *ptr_n_out;
  
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = '"';
  if ( n_out + (int)strlen(label) >= sz_out ) { go_BYE(-1); }
  strcpy(out+n_out, label); n_out += strlen(label);
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = '"';
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = ' ';
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = ':';
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = ' ';
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = '"';

  for ( char *cptr = in; *cptr != '\0'; cptr++ ) { 
    if ( n_out >= sz_out ) { go_BYE(-1); }
    if ( isspace(*cptr) ) { g_rslt[n_out++] = ' '; continue; }
    if ( ( *cptr == '"' ) || ( *cptr == '\\' ) ) { 
      g_rslt[n_out++] = '\\';  
    }
    g_rslt[n_out++] = *cptr;
  }
  if ( n_out >= sz_out ) { go_BYE(-1); } out[n_out++] = '"';
  *ptr_n_out = n_out;
BYE:
  return status;
}
  //--------------------------------------
bool 
isfile (
    const char * const filename
    )
{
  struct stat buf;
  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { return false; }
  int status = stat(filename, &buf );
  if ( ( status == 0 ) && ( S_ISREG( buf.st_mode ) ) ) { /* Path found, check for regular file */
    return true;
  }
  else {
    return false;
  }
}
bool 
isdir (
    const char * const dirname
    )
{
  struct stat buf;
  if ( ( dirname == NULL ) || ( *dirname == '\0' ) ) { return false; }
  int status = stat(dirname, &buf );
  if ( ( status == 0 ) && ( S_ISDIR( buf.st_mode ) ) ) { /* Path found, check for directory */
    return true;
  }
  else {
    return false;
  }
}
