#include <immintrin.h>
#include <malloc.h>
#include <smmintrin.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(__GNUC__)
#define PORTABLE_ALIGN16 __attribute__((aligned(16)))
#else
#define PORTABLE_ALIGN16 __declspec(align(16))
#endif

/*

 * [Description]

 * This code sample demonstrates how to use C, MMX, and SSE3

 * instrinsics to calculate the dot product of two vectors.

 *

 * [Compile]

 * icc dot_prodcut.c (linux) | icl dot_product.c (windows)

 *

 * [Output]

 * Dot Product computed by C: 506.000000

 * Dot Product computed by SSE2 intrinsics:  506.000000

 * Dot Product computed by MMX intrinsics:  506

 */

 

#include <stdio.h>

#include <pmmintrin.h>

#define SIZE 32  //assumes size is a multiple of 4 because MMX and SSE

                 //registers will store 4 elements.

//Computes dot product using Ramesh
float dot_product_256(
    float *a, 
    float *b,
    int n
    );
//Computes dot product using C

float dot_product(float *a, float *b);

//Computes dot product using intrinsics

float dot_product_intrin(float *a, float *b);

//Computes dot product using MMX intrinsics

short MMX_dot_product(short *a, short *b);

int main()

{

  float *x = NULL, *y = NULL;
  x = memalign(32 ,SIZE * sizeof(float)); 
  y = memalign(32, SIZE * sizeof(float));

  short a[SIZE], b[SIZE];

  int i;

  float product;

  short mmx_product;

  

  for(i=0; i<SIZE; i++)

  {

    x[i]=i;

    y[i]=i;

    a[i]=i;

    b[i]=i;

  }

  product= dot_product(x, y);

  printf("Dot Product computed by C: %f\n", product);  

  

  #if __INTEL_COMPILER

  product = dot_product_256(x, y, SIZE);
  printf("Dot Product computed by Ramesh :  %f\n", product);

  product =dot_product_intrin(x,y);

  printf("Dot Product computed by SSE2 intrinsics:  %f\n", product);

  mmx_product =MMX_dot_product(a,b);

  printf("Dot Product computed by MMX intrinsics:  %d\n", mmx_product);

  

  #else

  printf("Use INTEL compiler in order to calculate dot product\n");

  printf("usng intrinsics\n");

  

  #endif

  return 0;

}

float dot_product(float *a, float *b)

{

  int i;

  int sum=0;

  for(i=0; i<SIZE; i++)

  {

    sum += a[i]*b[i];

  }

  return sum;

}

#if __INTEL_COMPILER

float dot_product_256(
    float *a, 
    float *b,
    int n
    )

{
  float arr[4];
  float total = 0;
  int i;
  int stride = 256 / (8*sizeof(float));

  __m256 num1, num2, num3, num4;

  float PORTABLE_ALIGN16 tmpres[stride];
  num4 = _mm256_setzero_ps();  //sets sum to zero


  for ( i = 0; i < n; i += stride) {

    //loads array a into num1  num1= a[7]  a[6] ... a[1]  a[0]
    num1 = _mm256_loadu_ps(a+i);   

    //loads array b into num2  num2= b[7]  b[6] ... b[1]  b[0]
    num2 = _mm256_loadu_ps(b+i);   

    // performs multiplication   
    // num3 = a[7]*b[7]  a[6]*b[6]  ... a[1]*b[1]  a[0]*b[0]
    num3 = _mm256_mul_ps(num1, num2); 

    //horizontal addition by converting to scalars
    _mm256_store_ps(tmpres, num3);
    // accumulate in total
    total += tmpres[0] + tmpres[1] + tmpres[2] + tmpres[3] + 
             tmpres[4] + tmpres[5] + tmpres[6] + tmpres[7];
  }
  return total;

}
float dot_product_intrin(float *a, float *b)

{

  float arr[4];

  float total;

  int i;

  __m128 num1, num2, num3, num4;

  num4= _mm_setzero_ps();  //sets sum to zero

  for(i=0; i<SIZE; i+=4)

  {

    num1 = _mm_loadu_ps(a+i);   //loads unaligned array a into num1  num1= a[3]  a[2]  a[1]  a[0]

    num2 = _mm_loadu_ps(b+i);   //loads unaligned array b into num2  num2= b[3]   b[2]   b[1]  b[0]

    num3 = _mm_mul_ps(num1, num2); //performs multiplication   num3 = a[3]*b[3]  a[2]*b[2]  a[1]*b[1]  a[0]*b[0]

    num3 = _mm_hadd_ps(num3, num3); //performs horizontal addition

                              //num3=  a[3]*b[3]+ a[2]*b[2]  a[1]*b[1]+a[0]*b[0]  a[3]*b[3]+ a[2]*b[2]  a[1]*b[1]+a[0]*b[0]

    num4 = _mm_add_ps(num4, num3);  //performs vertical addition

  }

  num4= _mm_hadd_ps(num4, num4);

  _mm_store_ss(&total,num4);

  return total;

}

//MMX technology cannot handle single precision floats

short MMX_dot_product(short *a, short *b)

{

  int i;

  short result, data;

  __m64 num3, sum;

   __m64 *ptr1, *ptr2;

   

  sum = _mm_setzero_si64(); //sets sum to zero

  for(i=0; i<SIZE; i+=4){

   ptr1 = (__m64*)&a[i];  //Converts array a to a pointer of type

                         //__m64 and stores four elements into MMX

                         //registers

   ptr2 = (__m64*)&b[i];

   num3 = _m_pmaddwd(*ptr1, *ptr2); //multiplies elements and adds lower

                                    //elements with lower element and

                                    //higher elements with higher

   sum = _m_paddw(sum, num3);       

   }

   data = _m_to_int(sum);     //converts __m64 data type to an int

   sum= _m_psrlqi(sum,32);    //shifts sum    

   result = _m_to_int(sum);   

   result= result+data;      

   _m_empty();  //clears the MMX registers and MMX state.

   return result;

}

#endif
