typedef  unsigned long  long ub8;   /* unsigned 8-byte quantities */
typedef  unsigned long  int  ub4;   /* unsigned 4-byte quantities */
typedef  unsigned       char ub1;

extern ub8 
hash( 
    register ub1 *k, /* the key */
    register ub8 length,/* the length of the key */ 
    register ub8 level/* the previous hash, or an arbitrary value */
    );
extern ub8 
hash2( 
    register ub8 *k, /* the key */
    register ub8 length, /* the length of the key */ 
    register ub8 level /* the previous hash, or an arbitrary value */
    );
extern ub8 
hash3( 
    register ub1 *k, /* the key */
    register ub8 length, /* the length of the key */ 
    register ub8  level /* the previous hash, or an arbitrary value */ 
    );
