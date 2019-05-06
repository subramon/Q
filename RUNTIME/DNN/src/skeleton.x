/*
nn = Q.mk_nn(X, { num_epochs = 10, ... })
for i in 1, 10 do 
  nn:epoch()
end
W, b = nn:package()
*/

/* START: Inputs */
int num_epochs;
int batch_size;
int num_layers;
int *neurons_in_layer; 
int *activation_fn; // [num_layers] 
// neurons_in_layer[0] == 3 == number of features in data set
// neurons_in_layer[1] == 4
// neurons_in_layer[2] == 1
float **X; // [neurons_in_layer[0]][num_instances]
int num_instances;
// as an example, float **X; // [3][10];
/* STOP: Inputs */

// Allocate weights for all layers
float ***W;
W = (float ***)malloc(num_layers * sizeof(float **));
return_if_malloc_failed(W);
for ( int l = 1; l < num_layers; l++ ) {
  W[l] = malloc(neurons_in_layer[l-1]*neurons_in_layer[l]*sizeof(float));
  /* above is not quite correct. To be fixed */
  // initialize to uniform_random(-1, 1) / 1000;
}
// Allocate bias for all layers
float **B;
B = (float **)malloc(num_layers * sizeof(float *));
return_if_malloc_failed(B);
for ( int b = 1; b < num_layers; b++ ) {
  B[l] = malloc(neurons_in_layer[b]*sizeof(float));
  for ( int i = 0; i < neurons_in_layer[b]; i++ ) { 
    B[l][i] = 0; 
  }
}
//------------------------------------------------------------
for ( l = 1; l < num_layers; l++ ) {  // remember layer 0 = input
  switch ( activation_fn[l] ) { 
    case RELU       : 
    case SIGMOID    : 
    case SOFT_MAX   : 
    case TANH       : 
    case LEAKY_RELU : 
      /* okay */
      break;
    default : 
      go_BYE(-1);
      break;
  }
}
//------------------------------------------------------------
// Allocate activation outputs for all layers
float ***A;
A = (float ***)malloc(num_layers * sizeof(float **));
return_if_malloc_failed(A);
for ( int l = 0; l < num_layers; l++ ) {
  A[l] = malloc(neurons_in_layer[l] * sizeof(float *));
  return_if_malloc_failed(A[l]);
  if ( l > 0 ) { 
    for ( m = 0; m < neurons_in_layer[l]; m++ ) { 
      A[l][m] = malloc(batch_size * sizeof(float));
      return_if_malloc_failed(A[l][m]);
    }
  }
}
//------------------------------------------------------------
for ( int i = 0; i < num_epochs; i++ ) { 
  int num_batches = num_instances / batch_size;
  if ( num_batches == 0 ) { num_batches++; }
  for ( int j = 0; j < num_batches; j++ ) { 
    int lb = j  * batch_size;
    int ub = lb + batch_size;
    if ( j == num_batches-1 ) { ub = n; }
    int l_num_instances = ub - lb;
    for ( int l = 1; l < num_layers; l++ ) {
      if ( l == 1 )  {
        for ( int k = 0; k < num_neurons_in_layer[0]; k++ ) { 
          A[k] = X[k] + lb;
        }
      }
      // now we will do matrix multiply and apply activation function
    }
    // finish forward pass
    // start back propagation
    // finish back propagation
  }
}

