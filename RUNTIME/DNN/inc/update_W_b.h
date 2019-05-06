extern int
update_W_b(
    float ***W,
    float ***dW,
    float **b,
    float **db,
    int nl,
    int *npl,
    bool **d,
    float alpha // learning rate
    );
