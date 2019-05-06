#define WHEREAMI { fprintf(stderr, "Line %3d of File %s \n", __LINE__, __FILE__);  }
#define go_BYE(x) { WHEREAMI; status = x ; goto BYE; }
#define cBYE(x) { if ( (x) < 0 ) { go_BYE((x)) } }
#define fclose_if_non_null(x) { if ( (x) != NULL ) { fclose((x)); (x) = NULL; } } 
#define free_if_non_null(x) { if ( (x) != NULL ) { free((x)); (x) = NULL; } }
#define return_if_malloc_failed(x) { if ( (x) == NULL ) { go_BYE(-1); } }
