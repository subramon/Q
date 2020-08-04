// Assume count = 4 and gang size = 4
// A = 10,20,30,40
// B =0,1,0,1
export void simple(
    uniform int A[], 
    uniform int B[],
    uniform int C[],
    uniform int count
    ) 
{
  foreach (index = 0 ... count) {
    float b = b[index];
    if ( b == 0 ) { 
      c[i] = a[i];
    }
    else {
      c[i] = a[i-1];
    }
  }
}
