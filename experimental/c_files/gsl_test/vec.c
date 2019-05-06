#include <stdio.h>
#include <gsl/gsl_vector.h>

int sum(double* arr, int size) {
    for (int i=0; i<size ; i++) {
        arr[i] += 10;
    }
    return 0;
}


gsl_vector* get_vector( int size )
{
    int i;
    gsl_vector * v = gsl_vector_alloc (size);

    for (i = 0; i < size; i++)
    {
        gsl_vector_set (v, i, 1.23 + i);

    }
    return v;
}

double * get_vector_pointer(gsl_vector* v){
    return gsl_vector_ptr(v, 0);
}


int print_array_data(double* arr, int size){
    for(int i=0; i<size; i++) {
        printf("%f\n", arr[i]);
    }
    return 0;
}

int free_vector(gsl_vector * v)
{
    gsl_vector_free(v);
    return 0;
}

int main(int argc, char *argv[]) {
    gsl_vector* vec = get_vector(1);
    double* darry = get_vector_pointer(vec);
    //incd(darry,1);
    printf("printing darry\n");
    print_array_data(darry, 1);
    free_vector(vec);

}

double* get_double_array(int size) {
    double* arr = (double*) malloc(size*sizeof(double));
    for (int i=0; i<size; i++ ) {
        arr[i] = i;
    }
    return arr;
}
int free_double_array(double* arr) {
    free(arr);
    return 0;
}

gsl_vector_view make_vector(double* arr, int size) {
    return gsl_vector_view_array(arr, size);
}

