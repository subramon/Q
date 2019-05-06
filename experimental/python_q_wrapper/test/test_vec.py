import Q
from Q.p_vector import PVector
from Q.p_scalar import PScalar


def test_vec_concat():
    """Test the vector methods concatenation"""

    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec1 = Q.const(in_val).set_name("new_vec").eval()
    assert(isinstance(vec1, PVector))
    Q.print_csv(vec1)
    assert(vec1.get_name() == "new_vec")
    print("Successfully executed vector method concat test")


def test_vec_persist():
    """Test the vec persist method"""

    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec1 = Q.const(in_val)
    in_val = {'val': 25, 'qtype': Q.I1, 'len': 5}
    vec2 = Q.const(in_val)
    result = Q.vveq(Q.vvsub(Q.vvadd(vec1, vec2), vec2), vec1).persist(True).eval()
    assert(isinstance(result, PVector))
    Q.print_csv(result)
    print("Successfully executed Q operator concat test with persist flag to true")


def test_vec_arith():
    """Test the vector arithmetic with operators i.e addition with '+' operator etc"""

    in_val = {'val': 5, 'qtype': Q.I1, 'len': 5}
    vec1 = Q.const(in_val)
    in_val = {'val': 25, 'qtype': Q.I1, 'len': 5}
    vec2 = Q.const(in_val)

    # Add Two vectors
    vec3 = vec1 + vec2
    assert(isinstance(vec3, PVector))
    # TODO: do we require to eval vector after vec addition with '+' operator
    vec3.eval()
    assert(vec3.length() == vec1.length())
    Q.print_csv(vec3)
    print("------------------")

    # Add vector & scalar
    s1 = PScalar(25, Q.I1)
    vec4 = vec1 + s1
    assert(isinstance(vec4, PVector))
    # TODO: do we require to eval vector after vector-scalar addition with '+' operator
    vec4.eval()
    assert(vec4.length() == vec1.length())
    Q.print_csv(vec4)
    print("------------------")

    # Add vector & number
    vec5 = vec1 + 25
    assert(isinstance(vec5, PVector))
    # TODO: do we require to eval vector after vector-scalar addition with '+' operator
    vec5.eval()
    assert(vec5.length() == vec1.length())
    Q.print_csv(vec5)


    # verification
    result = Q.sum(Q.vveq(vec3, vec4))
    total_sum, total_val = result.eval()
    assert(total_sum.to_num() == vec1.length())

    result = Q.sum(Q.vveq(vec3, vec5))
    total_sum, total_val = result.eval()
    assert(total_sum.to_num() == vec1.length())

    print("Successfully executed vector arithmetic test")


if __name__ == "__main__":
    test_vec_concat()
    print("==========================")
    test_vec_persist()
    print("==========================")
    test_vec_arith()
    print("==========================")
