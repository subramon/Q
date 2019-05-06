#include <stdio.h>
//#define RET double
//#define TYPE1 int
//#define TYPE2 float

RET add_inner(TYPE1 A, TYPE2 B) {
   return (RET) A + B;
}

int add(TYPE1* A, TYPE2* B, RET* C, int len, int blk_size) {
   int length = len/sizeof(TYPE1);
   float nb = length*1.0/blk_size;

   if (nb != (int)nb) {
      nb += 1 ;
   }
   //printf("nb is %f", nb);
   for(int i=0 ; i<nb; i++) {
      int lb = i*blk_size;
      int ub = (i+1)*blk_size -1;
      ub = ub < length-1 ? ub:length-1;
      //printf ("lb is %d and ub is %d\n", lb, ub);
      if (lb > ub) {
         break;
      }
      for(int j= lb ; j<= ub ; j++) {
         C[j] = add_inner(A[j], B[j]);
      }
   }
   return 0;
}

int initA(TYPE1* A , int length) {
   for (int i =0 ;i<length/sizeof(A[0]); i++)
      A[i] = 1;
   return 0;
}


int writeOut(RET* C, int length) {
   for (int i =0; i<length/sizeof(C[0]); i++)
      printf("%d\n", C[i]);
   return 0;
}

int initB(TYPE2* B , int length) {
    for (int i=0; i<length/sizeof(B[0]); i++)
       B[i] = 2;
    return 0;
}

