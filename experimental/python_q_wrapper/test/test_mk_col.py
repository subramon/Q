import Q
from Q.p_vector import PVector


def test_mk_col():
    """Test the Q.mk_col() functionality
    Input is list, output is PVector"""

    in_vals = [1, 2, 3, 4]
    vec = Q.mk_col(in_vals, Q.I1)
    assert(isinstance(vec, PVector))
    assert(vec.length() == len(in_vals))
    assert(vec.qtype() == Q.I1)
    print("Successfully executed Q.mk_col test")


def test_array():
    """Test the Q.array() functionality, alias for Q.mk_col
    Input is list, output is PVector"""

    in_vals = [1, 2, 3, 4]
    vec = Q.array(in_vals, dtype=Q.int8)
    assert(isinstance(vec, PVector))
    assert(vec.length() == len(in_vals))
    assert(vec.qtype() == Q.int8)
    # Q.print_csv(vec)
    print("Successfully executed Q.array test")


def test_array_without_dtype():
    """Test the Q.array() functionality without providing dtype
    it should pick default dtype"""

    in_vals = [1, 2, 3, 4]
    vec = Q.array(in_vals)
    assert(isinstance(vec, PVector))
    assert(vec.length() == len(in_vals))
    assert(vec.qtype() == Q.int64)

    in_vals = [1.0, 2.0, 3, 4]
    vec = Q.array(in_vals)
    assert(isinstance(vec, PVector))
    assert(vec.length() == len(in_vals))
    assert(vec.qtype() == Q.float64)

    # Q.print_csv(vec)
    print("Successfully executed Q.array without providing dtype")


if __name__ == "__main__":
    test_mk_col()
    print("==========================")
    test_array()
    print("==========================")
    test_array_without_dtype()
    print("==========================")
