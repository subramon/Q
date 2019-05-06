#include<stdint.h>
#include<stdio.h>
#include<string.h>

int int32_sum(int32_t *X, int n, int64_t *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
  
  for (i = 0; i < n; i++)
  	printf("%d, ", X[i]);*/
  	
  int64_t sum = 0;
  for (i= 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %llu", *ptr_sum); //prints the sum calculated here
  return status;
}

int int8_sum(int8_t *X, int n, int16_t *ptr_sum)
{
  int status = 0;
  int i;
  /*printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
  
  for (i = 0; i < n; i++)
  	printf("%d, ", X[i]);*/
  	
  int16_t sum = 0;
  for (i= 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %d", *ptr_sum);
  return status;
}

int int16_sum(int16_t *X, int n, int32_t *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
  
  for (i = 0; i < n; i++)
  	printf("%d, ", X[i]);*/
  	
  int32_t sum = 0;
  for (i= 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %d", *ptr_sum);
  return status;
}


int int64_sum(int64_t *X, int n, int64_t *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
  
  for (i = 0; i < n; i++)
  	printf("%llu, ", X[i]);*/
  	
  int64_t sum = 0;
  for (i= 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %llu", *ptr_sum);
  return status;
}




int uint8_sum(uint8_t *X, int n, uint16_t *ptr_sum)
{
  int status = 0;
  int i; 
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
 
  for (i= 0; i < n; i++)
  	printf("%u, ", X[i]);*/
  	
  uint16_t sum = 0;

  for (i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %u", *ptr_sum);
  return status;
}

int uint16_sum(uint16_t *X, int n, uint32_t *ptr_sum)
{
  int status = 0;
  int i; 
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
  
  for (i= 0; i < n; i++)
  	printf("%u, ", X[i]);*/
  	
  uint32_t sum = 0;

  for (i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %u", *ptr_sum);
  return status;
}

int uint32_sum(uint32_t *X, int n, uint64_t *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("Added called witharray sz %d", n);
  printf("\nArray is:");
   
  for (i= 0; i < n; i++)
  	printf("%u, ", X[i]);*/
  	
  uint64_t sum = 0;

  for (i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %llu", *ptr_sum);
  return status;
}

int uint64_sum(uint64_t *X, int n, uint64_t *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
   
  for (i= 0; i < n; i++)
  	printf("%llu, ", X[i]);*/
  	
  uint64_t sum = 0;

  for (i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %llu	", *ptr_sum);
  return status;
}

int float_sum(float *X, int n, float *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
   
  for (i= 0; i < n; i++)
  	printf("%f, ", X[i]);*/
  	
  float sum = 0;
  for (i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %2.10f", *ptr_sum);
  return status;
}

int double_sum(double *X, int n, double *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
   
  for (i= 0; i < n; i++)
  	printf("%2.10lf, ", X[i]);*/
  	
  float sum = 0;
  for (i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %2.10lf", *ptr_sum);
  return status;
}


int char_sum(char *X, int n, char *ptr_sum)
{
  int status = 0;
  int i;
  /* printf("\nAdded called witharray sz %d", n);
  printf("\nArray is:");
   
  for (i= 0; i < n; i++)
  	printf("%d, ", X[i]);*/
  	
  char sum = 0;

  for (i = 0; i < n; i++ ) { 
    sum += X[i];
  }
  *ptr_sum = sum;
  //printf("\nSum = %d", *ptr_sum);
  return status;
}