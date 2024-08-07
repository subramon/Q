#ifndef __Q_MACROS_H
#define __Q_MACROS_H
#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }
#define cBYE(x) { if ( (x) < 0 ) { go_BYE((x)) } }
#define fclose_if_non_null(x) { if ( (x) != NULL ) { fclose((x)); (x) = NULL; } } 
#define free_if_non_null(x) { if ( (x) != NULL ) { free((x)); (x) = NULL; } }
#define return_if_fopen_failed(fp, file_name, access_mode) { if ( fp == NULL ) { fprintf(stderr, "Unable to open file %s for %s \n", file_name, access_mode); go_BYE(-1); } }
#define return_if_malloc_failed(x) { if ( x == NULL ) { fprintf(stderr, "Unable to allocate memory\n"); go_BYE(-1); } }

#define mk_comp_val(x, y, z ) ( ( (uint64_t)x << 32 ) | ( (uint64_t)z << 31 )  | y )
#define get_from(x) ( x >> 32 )
#define get_goal(x) ( ( x >> 31 ) & 0x1 )
#define get_yval(x) ( ( x & 0x7FFFFFFF ) )
#endif
