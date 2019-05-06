
def is_p_vector(val):
    """checks whether given value is of type P_Vector"""

    from Q.p_vector import PVector
    return isinstance(val, PVector)


def is_p_scalar(val):
    """checks whether given vlaue is of type P_Scalar"""

    from Q.p_scalar import PScalar
    return isinstance(val, PScalar)