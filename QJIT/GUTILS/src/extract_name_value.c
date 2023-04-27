#include "q_incs.h"
extern char *strcasestr(const char *haystack, const char *needle);
#include "extract_name_value.h"

int
extract_name_value(
		   const char *in_str,
		   const char *start,
		   char delim,
                   char *val, /* [len] */
                   int maxlen
		   )
// STOP FUNC DECL
{
  int status = 0;
  char *cptr1, *cptr;
  int len;
  bool found_start;

  if ( in_str == NULL ) { go_BYE(-1); }
  if ( ( start == NULL ) || ( *start == '\0' ) ) { go_BYE(-1); }
  if ( delim  == '\0' ) { go_BYE(-1); }

  for ( found_start = false; ; ) { 
    cptr1 = strcasestr(in_str, start);
    // If no match found, then quit 
    if ( ( cptr1 == NULL ) || ( *cptr1 == '\0' ) ) { 
      found_start = false; break;
    }
    // If match from start of line, great. Break loop and keep moving
    if ( cptr1 == in_str ) { found_start = true; break; } 
    // See if there was a delimiter the match location
    if ( *(cptr1-1) == delim ) { found_start = true; break; }
    in_str += (cptr1 - in_str) + strlen(start);
  }
  if ( !found_start ) { goto BYE; }

  // Now advance to after the start string and look for stop string
  cptr1 += strlen(start);
  cptr = cptr1;
  for ( len = 0; ; len++, cptr1++ ) { 
    if ( ( *cptr1 == delim ) || ( *cptr1 == '\0' ) ) {
      break;
    }
  }
  if ( len > maxlen ) { 
    WHEREAMI;
    fprintf(stderr, "Input string = [%s], start=[%s], exceeded len = %d \n", in_str, start, maxlen);
    go_BYE(-1); 
  }
  memset(val, '\0', maxlen);
  strncpy(val, cptr, len);
  val[len] = '\0'; // null terminate string. space better exist!
BYE:
  return status ;
}
