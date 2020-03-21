extern int
Output(
       double **buffer,      
       int *weight, 
       double *last_packet,
       int n_last_packet, 
       double *quantiles,
       int num_quantiles,
       int n, // actual number of input values 
       int b,         
       int k
       );
