#include<stdio.h>

int print_vector(int* ptr, int length) {

    for(int i=0; i<length; i++) {
        printf("%d\n", ptr[i]);
    }
    return 0;
}
