// Is b == 2 at the end of this function?
// Assume count = 4 and gang size = 4
// A =0,1,0,1
export void simple(
    uniform int A[], 
    uniform int count,
    uniform int B[], 
    ) 
{
  uniform int b = 0;
  foreach (index = 0 ... count) {
    if ( a[i] == 0 ) { 
      b++;
    }
  }
  B[0] = b;
}
/* Fails because
 *
 * Uniform variables can be modified as the program executes, but only
 * in ways that preserve the property that they have a single value
 * for the entire gang. Thus, it's legal to add two uniform variables
 * together and assign the result to a uniform variable, but assigning
 * a non-uniform (i.e., varying) value to a uniform variable is a
 * compile-time error.
 *
 * */
/*
 * It is possible to write code that has data races across the gang of
 * program instances. For example, if the following function is called
 * with multiple program instances having the same value of index,
 * then it is undefined which of them will write their value of value
 * to array[index]. */
