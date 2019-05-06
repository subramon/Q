#ifndef __Q_MACROS_H
#define __Q_MACROS_H
#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
/*-------------------------------------------------------*/
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }
#define err_go_BYE() { fprintf(stderr, "Error = %s \n", strerror(errno)); go_BYE(-1); }
/*-------------------------------------------------------*/

#define cBYE(x) { if ( (x) < 0 ) { go_BYE((x)) } }
#define fclose_if_non_null(x) { if ( (x) != NULL ) { fclose((x)); (x) = NULL; } } 
#define free_if_non_null(x) { if ( (x) != NULL ) { free((x)); (x) = NULL; } }
#define return_if_fopen_failed(fp, file_name, access_mode) { if ( fp == NULL ) { fprintf(stderr, "Unable to open file %s for %s \n", file_name, access_mode); go_BYE(-1); } }
#define return_if_malloc_failed(x) { if ( x == NULL ) { fprintf(stderr, "Unable to allocate memory\n"); go_BYE(-1); } }

#define mcr_nop(X)  ((X))
#define mcr_sqr(X)  ((X) * (X))
#define mcr_min(X, Y)  ((X) < (Y) ? (X) : (Y))
#define mcr_max(X, Y)  ((X) > (Y) ? (X) : (Y))
#define mcr_sum(X, Y)  ((X) + (Y))
#define mcr_sum_sqr(X, Y)  ((X) + (Y)*(Y))
#define sqr(X)  ((X) * (X))

#define rs_munmap(X, nX) { \
  if ( ( X == NULL ) && ( nX != 0 ) ) {  WHEREAMI; return(-1); } \
  if ( ( X != NULL ) && ( nX == 0 ) )  { WHEREAMI; return(-1); } \
  if ( X != NULL ) { munmap(X, nX); X = NULL; nX = 0; } \
}

#define unlink_if_non_null(x) { if ( x != NULL ) { unlink( x ); } }

#define mcr_alloc_null_str(x, y) { \
  x = (char *)malloc(y * sizeof(char)); \
  return_if_malloc_failed(x); \
  zero_string(x, y); \
}

#define asm_time(x) { \
  __asm__{  \
    RDTSC  \
      mov DWORD PTR x, eax \
      mov DWORD PTR x+4, eax \
  } \
}

#define chk_range(xval, lb_incl, ub_excl) { if ( ( (xval) < (lb_incl) ) || ( (xval) >= (ub_excl ) ) ) { go_BYE(-1); } }

#define get_bit(x, i) ((x) & ((uint64_t) 1 << (i)))

#define is_ith_bit_set(x, i) ((x) & ((uint64_t) 1 << (i))) == 0 ? false : true 

#define set_bit(x, i) (x = (x) | ((uint64_t) 1 << (i)))

/* Following assumes word starts at 0's */
#define set_bit_val(word,  bit_idx, val) { word = word | (val << bit_idx ) }

#define unset_bit(x, i) (x = (x) & ~((uint64_t) 1 << (i)))

#define mcr_get_bit(x, i) ((x) & ((uint64_t) 1 << (i)))

#define mcr_is_ith_bit_set(x, i) ((x) & ((uint64_t) 1 << (i))) == 0 ? false : true 

#define mcr_set_bit(x, i) (x = (x) | ((uint64_t) 1 << (i)))

#define mcr_unset_bit(x, i) (x = (x) & ~((uint64_t) 1 << (i)))

#define SET_BIT(x,i)  (x)[(i) / 8] |= (1 << ((i) % 8))
#define CLEAR_BIT(x,i) (x)[(i) / 8] &= ~(1 << ((i) % 8))
#define GET_BIT(x,i) (((x)[(i) / 8] & (1 << ((i) % 8))) > 0)
#endif
