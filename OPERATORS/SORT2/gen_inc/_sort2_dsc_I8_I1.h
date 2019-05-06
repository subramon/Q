   
/* Order size using quicksort.  This implementation incorporates
   four optimizations discussed in Sedgewick:

   1. Non-recursive, using an explicit stack of pointer that store the
   next array partition to sort.  To save time, this maximum amount
   of space required to store an array of SIZE_MAX is allocated on the
   stack.  Assuming a 32-bit (64 bit) integer for size_t, this needs
   only 32 * sizeof(stack_node) == 256 bytes (for 64 bit: 1024 bytes).
   Pretty cheap, actually.

   2. Chose the pivot element using a median-of-three decision tree.
   This reduces the probability of selecting a bad pivot value and
   eliminates certain extraneous comparisons.

   3. Only quicksorts TOTAL_ELEMS / MAX_THRESH partitions, leaving
   insertion sort to order the MAX_THRESH items within each partition.
   This is a big win, since insertion sort is faster for small, mostly
   sorted array segments.

   4. The larger of the two sub-partitions is always pushed onto the
   stack first, with the algorithm then concentrating on the
   smaller partition.  This *guarantees* no more than log (total_elems)
   stack size is needed (actually O(1) in this case)!  */

#include <alloca.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

extern int
sort2_dsc_I8_I1 (
  void *const pbase,
  int8_t *drag,
  uint64_t total_elems
    );
