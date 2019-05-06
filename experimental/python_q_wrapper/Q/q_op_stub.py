"""
This module contains the signature for Q-lua functions
it is to get suggestion about Q-lua functions when someone is using IDE
"""


def mk_col(input, qtype, nn_input=None):
    """
    creates a vector with given input values and qtype (fldtype)

    Parameters:
        input: list of values
        qtype: field type of a vector
        nn_input: null input values

    Returns:
        a vector with given values
    """

    pass


def print_csv(vec_list, opt_args=None):
    """
    Prints the vector values

    Parameters:
        vec_list: list of vectors
        opt_args: optional arguments

    Return:
        vector content representation
    """

    pass


def seq(args):
    """
    creates a vector with sequential values

    Parameters:
        args: a dictionary specifying sequence parameters

    Returns:
        a vector
    """

    pass


def const(args):
    """
    creates a vector with constant value

    Parameters:
        args: a dictionary specifying const vector creation parameters

    Returns:
        a vector with constant value
    """

    pass


def vvadd(vec1, vec2, opt_args=None):
    """
    performs the vector addition

    Parameters:
        vec1: first p_vector
        vec2: second p_vector
        opt_args: optional arguments

    Returns:
        resulted vector
    """

    pass


def vvsub(vec1, vec2, opt_args=None):
    """
    performs the vector subtraction

    Parameters:
        vec1: first p_vector
        vec2: second p_vector
        opt_args: optional arguments

    Returns:
        resulted vector
    """

    pass


def vveq(vec1, vec2, opt_args=None):
    """
    checks whether two vectors are equal

    Parameters:
        vec1: first p_vector
        vec2: second p_vector
        opt_args: optional arguments

    Returns:
        returns a boolean vector
    """

    pass


def sum(vec, opt_args=None):
    """
    calculates the vector sum

    Parameters:
        vec: a p_vector
        opt_args: optional arguments

    Returns:
        a scalar representing a sum
    """

    pass