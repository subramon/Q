#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
typedef  unsigned long  long ub8;   /* unsigned 8-byte quantities */
typedef  unsigned long  int  ub4;   /* unsigned 4-byte quantities */
typedef  unsigned       char ub1;
extern ub8 hash( 
    const ub1 *k, 
    ub8 length, 
    ub4 level
    );
extern ub8 hash2( 
    const ub1 *k, 
    ub8 length, 
    ub8 level
    );
