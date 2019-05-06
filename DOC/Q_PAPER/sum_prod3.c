_sum(float *x, int n) {
  float sum = 0;
  for ( i = 0; i < n; i++ ) { 
    sum += x[i];
  }
  return sum;
}
_vvmul(float *x, float *y, float *z, int n) {
  for ( i = 0; i < n; i++ ) { 
    z[i] = x[i] * w[i];
  }
}
for ( i = 0; i < m; i++ ) { 
  _vvmul(X[i], w, temp, n);
  for ( j = i; j < m; j++ ) { 
    _vvmul(X[j], temp, temp);
    A[i][j] = _sum(temp, n);
  }
}


