#ifndef __ACT_FNS_H
#define __ACT_FNS_H
extern float 
sigmoid(
    float *x, 
    int n, 
    float *y
    );
extern float
sigmoid_bak(
    float *z,
    float *da,
    int n,
    float *dz
    );
extern float 
identity(
    float *x, 
    int n, 
    float *y
    );
extern float 
relu(
    float *x, 
    int n, 
    float *y
    );
extern float 
softmax(
    float *x, 
    int n, 
    float *y
    );
extern float
relu_bak(
    float *z,
    float *da,
    int n,
    float *dz
    );
#endif
