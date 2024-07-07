/* Items marked [1] are created by new */
/* Items marked [2] are created by set_io */
typedef struct _dnn_rec_type {
/*[1]*/  int nl; // num layers
/*[1]*/  int *npl;  // neurons per layer  [num_layers]
/*[1]*/  __act_fn_t  *A; // activation_function[num_layers]
/*[1]*/  __bak_act_fn_t  *bak_A; // bak_activation_function[num_layers]
/*[1]*/  float ***W; // weights, 
/*[1]*/  float ***dW; // delta weights, 
/*[1]*/  float **b; // bias, 
/*[1]*/  float **db; // delta bias, 
/*[1]*/  bool **d; // [num_layers][neurons_in_layer[i]]
/*[1]*/  float *dpl; // dropout per layer [num_layers]
  /* W[0] = NULL
   * W[i] = [num_layers][neurons_in_layer[i-1]][neurons_in_layer[i]]
   * b[0] = NULL
   * b[i] = [num_layers][neurons_in_layer[i]]
   * */
/*[2]*/  int bsz; // batch size
/*[3]*/  float ***z; 
/*[3]*/  float ***dz; 
/* z[0] == NULL
   z[i] = [num_layers][neurons_per_layer[l]][bsz]
   */
/*[3]*/  float ***a; 
/*[3]*/  float ***da; 
/*
   a[0] == NULL
   a[i] = [num_layers][neurons_per_layer[l]][bsz]
*/
} DNN_REC_TYPE;
