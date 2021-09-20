export void
foo(
    uniform float X[], // [n]
    uniform int Y[], // [m]
    uniform int n,
    uniform int m,
    uniform int a,
    uniform int b
    )
{
  foreach ( i = 0 ... m  ) {
    int xidx = Y[i];
    float xval = X[xidx];
    Y[i] += xval;
  }
}
 
