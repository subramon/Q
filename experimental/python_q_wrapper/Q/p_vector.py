import Q.lua_executor as executor
from Q import constants as q_consts
from Q.validate import is_p_vector, is_p_scalar


class PVector:
    """
    This class deals with the vector operations
    """

    def __init__(self, base_vec):
        self.base_vec = base_vec
        from q_helper import call_lua_op
        self.call_lua_op = call_lua_op

    def get_base_vec(self):
        """Returns a base vector"""

        return self.base_vec

    def eval(self):
        """
        evaluate the vector

        Returns:
            Returns the PVector object
        """

        func_str = q_consts.vec_func_str.format(fn_name="eval")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec)
        return self

    def length(self):
        """
        returns the vector length
        this method is applicable only for eval'ed vectors
        """

        func_str = q_consts.vec_func_str.format(fn_name="length")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec)
        return result

    def qtype(self):
        """returns the qtype (field type) of vector"""

        func_str = q_consts.vec_func_str.format(fn_name="qtype")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec)
        return result

    def num_elements(self):
        """returns the num_elements of vector"""

        func_str = q_consts.vec_func_str.format(fn_name="num_elements")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec)
        return result

    def set_name(self, name):
        """
        sets the name of a vector

        Parameters:
            name: name to be assigned to vector
        """

        func_str = q_consts.vec_func_arg_str.format(fn_name="set_name")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec, name)
        return self

    def get_name(self):
        """returns the name of a vector"""

        func_str = q_consts.vec_func_str.format(fn_name="get_name")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec)
        return result

    def memo(self, is_memo):
        """sets the memo value for vector"""

        func_str = q_consts.vec_func_arg_str.format(fn_name="memo")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec, is_memo)
        return self

    def is_memo(self):
        """returns memo value for vector"""

        func_str = q_consts.vec_func_str.format(fn_name="is_memo")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec)
        return result

    def persist(self, is_persist):
        """sets the persist flag for vector"""

        func_str = q_consts.vec_func_arg_str.format(fn_name="persist")
        func = executor.eval_lua(func_str)
        result = func(self.base_vec, is_persist)
        return self

    def __add__(self, other):
        """Add vector with second value (vector, scalar or number) using '+' operator"""

        if not (is_p_vector(other) or is_p_scalar(other)
                or isinstance(other, int) or isinstance(other, float)):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        # call wrapper function
        return self.call_lua_op(q_consts.ADD, self, other)

    def __sub__(self, other):
        """Subtract second value (vector, scalar or number) from vector using '-' operator"""

        if not (is_p_vector(other) or is_p_scalar(other)
                or isinstance(other, int) or isinstance(other, float)):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        # call wrapper function
        return self.call_lua_op(q_consts.SUB, self, other)

    def __div__(self, other):
        """divide vector by second value (vector, scalar or number) using '/' operator"""

        if not (is_p_vector(other) or is_p_scalar(other)
                or isinstance(other, int) or isinstance(other, float)):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        # call wrapper function
        return self.call_lua_op(q_consts.DIV, self, other)

    def __mul__(self, other):
        """multiply vector with second value (vector, scalar or number) using '*' operator"""

        if not (is_p_vector(other) or is_p_scalar(other)
                or isinstance(other, int) or isinstance(other, float)):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        # call wrapper function
        return self.call_lua_op(q_consts.MUL, self, other)