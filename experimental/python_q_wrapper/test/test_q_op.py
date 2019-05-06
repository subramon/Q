import Q
from Q.p_vector import PVector
from Q.p_reducer import PReducer
from Q.p_scalar import PScalar


def test_const():
    """Test the Q.const() functionality
    It creates a constant vector with specified value and length"""

    length = 6
    in_val = {'val': 5, 'qtype': Q.I1, 'len': length}
    vec = Q.const(in_val)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()
    assert(vec.num_elements() == length)
    Q.print_csv(vec)
    print("Successfully executed Q.const test")


def test_full():
    """Test the Q.full() functionality, alias of Q.const()
    It creates a constant vector with specified value and length"""

    vec = Q.full(6, 5, dtype=Q.int8)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()
    assert(vec.num_elements() == 6)
    Q.print_csv(vec)
    print("Successfully executed Q.full test")


def test_full_without_dtype():
    """Test the Q.full() functionality without providing dtype"""

    vec = Q.full(6, 5)
    assert(isinstance(vec, PVector))
    assert(vec.qtype() == Q.int64)
    assert(vec.num_elements() == 0)
    vec.eval()
    assert(vec.num_elements() == 6)
    Q.print_csv(vec)
    print("Successfully executed Q.full without dtype test")


def test_zeros():
    """Test the Q.zeros() functionality
    It creates a constant vector of specified length with all values as 0"""

    vec = Q.zeros(6)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()  # expecting all values to be zero
    assert(vec.num_elements() == 6)
    Q.print_csv(vec)
    print("Successfully executed Q.zeros test")


def test_ones():
    """Test the Q.ones() functionality
    It creates a constant vector of specified length with all values as 1"""

    vec = Q.ones(6)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()  # expecting all values to be one
    assert(vec.num_elements() == 6)
    Q.print_csv(vec)
    print("Successfully executed Q.ones test")


def test_seq():
    """Test the Q.seq() functionality
    It creates a vector with values as sequence with specified inputs"""

    length = 6
    in_val = {'start': -1, 'by': 5, 'qtype': Q.I1, 'len': length}
    vec = Q.seq(in_val)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()
    assert(vec.num_elements() == length)
    Q.print_csv(vec)
    print("Successfully executed Q.seq test")


def test_arange():
    """Test the Q.arange() functionality, wrapper around Q.seq()"""

    stop = 5
    vec = Q.arange(stop)
    assert(isinstance(vec, PVector))
    assert(vec.qtype() == Q.int64)
    assert(vec.num_elements() == 0)
    vec.eval()  # expecting values as 0, 1, 2, 3, 4
    assert(vec.num_elements() == stop)
    Q.print_csv(vec)
    print("Successfully executed Q.arange test")


def test_arange_with_start():
    """Test the Q.arange() functionality with start value specified in input"""

    stop = 5
    start = 1
    vec = Q.arange(start, stop)
    assert(isinstance(vec, PVector))
    assert(vec.num_elements() == 0)
    vec.eval()  # expecting values as 1, 2, 3, 4
    assert(vec.num_elements() == (stop - start))
    Q.print_csv(vec)
    print("Successfully executed Q.arange with start value test")


def test_arange_with_step():
    """Test the Q.arange() functionality with start and step value specified in input"""

    step = 2
    stop = 8
    start = 3
    vec = Q.arange(start, stop, step)
    assert(isinstance(vec, PVector))
    assert(vec.qtype() == Q.int64)
    assert(vec.num_elements() == 0)
    vec.eval()  # expecting values as 3, 5, 7
    # assert(vec.num_elements() == 3)
    Q.print_csv(vec)
    print("Successfully executed Q.arange with step value test")


def test_vvadd():
    """Test Q.vvadd() functionality
    It performs sum of two vectors"""

    in_vals = [1, 2, 3, 4, 5]
    vec1 = Q.mk_col(in_vals, Q.I1)
    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec2 = Q.const(in_val)
    out = Q.vvadd(vec1, vec2)
    assert(out.num_elements() == 0)
    out.eval()
    assert(out.num_elements() == len(in_vals))
    Q.print_csv(out)
    print("Successfully executed vec_add test")


def test_add():
    """Test Q.add() functionality, it is a alias for Q.vvadd()"""

    in_vals = [1, 2, 3, 4, 5]
    vec1 = Q.mk_col(in_vals, Q.I1)
    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec2 = Q.const(in_val)
    out = Q.add(vec1, vec2)
    assert(out.num_elements() == 0)
    out.eval()
    assert(out.num_elements() == len(in_vals))
    Q.print_csv(out)
    print("Successfully executed vec_add test")


def test_op_concat():
    """Test the Q operator concatenation"""

    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec1 = Q.const(in_val)
    in_val = {'val': 25, 'qtype': Q.I1, 'len': 5}
    vec2 = Q.const(in_val)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully executed Q operator concat test")


def test_op_concat_memo():
    """Test the Q operator concatenation with setting memo to false"""

    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec1 = Q.const(in_val).memo(False)
    in_val = {'val': 25, 'qtype': Q.I1, 'len': 5}
    vec2 = Q.const(in_val).memo(False)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2).memo(False), vec2).memo(False), vec1).memo(False).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully executed Q operator concat test with setting memo false")


def test_sum():
    """Test the Q operator Q.sum() - returns sum of vector"""

    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec = Q.const(in_val).eval()
    result = Q.sum(vec)
    assert(isinstance(result, PReducer))
    total_sum, total_val = result.eval()
    assert(isinstance(total_sum, PScalar))
    assert(isinstance(total_val, PScalar))
    assert(total_val.to_num() == vec.length())
    assert(total_sum.to_num() == 25)
    print("Total sum is {}".format(total_sum))
    print("Total visited values are {}".format(total_val))
    print("Successfully executed Q.sum() operator test")


if __name__ == "__main__":
    test_const()
    print("==========================")
    test_full()
    print("==========================")
    test_full_without_dtype()
    print("==========================")
    test_seq()
    print("==========================")
    test_arange()
    print("==========================")
    test_arange_with_start()
    print("==========================")
    test_arange_with_step()
    print("==========================")
    test_vvadd()
    print("==========================")
    test_add()
    print("==========================")
    test_op_concat()
    print("==========================")
    test_op_concat_memo()
    print("==========================")
    test_sum()
