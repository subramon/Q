import Q.lua_executor as executor
from Q import constants as q_consts
from Q.validate import is_p_vector, is_p_scalar


class PScalar:
    """
    This class deals with the scalar operations
    """

    def __init__(self, val=None, qtype=None, base_scalar=None):
        if base_scalar:
            self.base_scalar = base_scalar
        else:
            if not val or not qtype:
                raise Exception("Provide appropriate argument to PScalar constructor")
            # create a base scalar object
            func = executor.eval_lua(q_consts.create_scalar_str)
            self.base_scalar = func(val, qtype)

    def get_base_scalar(self):
        """return base scalar"""

        return self.base_scalar

    def to_num(self):
        """
        converts a scalar to number

        Returns:
            returns a numeric value associated with scalar
        """

        func_str = q_consts.scalar_func_str.format(fn_name="to_num")
        try:
            func = executor.eval_lua(func_str)
            result = func(self.base_scalar)
        except Exception as e:
            raise Exception("Failed to convert scalar to number")
        return result

    def fldtype(self):
        """return fldtype (qtype) of a scalar"""

        func_str = q_consts.scalar_func_str.format(fn_name="fldtype")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def qtype(self):
        """return fldtype (qtype) of a scalar"""

        return self.fldtype()

    def to_str(self):
        """
        convert scalar to string

        Returns:
            returns a string representation of scalar
        """

        func_str = q_consts.scalar_func_str.format(fn_name="to_str")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def to_cmem(self):
        """
        convert scalar to cmem

        Returns:
            returns cmem object associated with scalar
        """

        func_str = q_consts.scalar_func_str.format(fn_name="to_cmem")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def conv(self, qtype):
        """convert scalar to other qtype"""

        func_str = q_consts.scalar_func_arg_str.format(fn_name="conv")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, qtype)
        return self

    def abs(self):
        """convert scalar to absolute"""

        func_str = q_consts.scalar_func_str.format(fn_name="abs")
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar)
        return result

    def __check_and_execute(self, other, operation):
        """
        checks the given value and executes specified scalar operation

        Parameters:
            other: a given value with which a scalar is getting operated
            operation: operation specification (is a string)

        Returns:
            the scalar object
        """

        if not (is_p_scalar(other) or isinstance(other, int) or isinstance(other, float)):
            raise Exception("Second argument type {} is not supported".format(type(other)))
        # converts int and floats to scalar
        if isinstance(other, int):
            other = PScalar(other, q_consts.I8)
        elif isinstance(other, float):
            other = PScalar(other, q_consts.F8)
        else:
            # it's a PScalar, nothing to do
            pass
        other = other.get_base_scalar()
        func_str = q_consts.scalar_arith_func_str.format(op=operation)
        func = executor.eval_lua(func_str)
        result = func(self.base_scalar, other)
        return PScalar(base_scalar=result)

    def __add__(self, other):
        """add scalar with given value"""

        if is_p_vector(other):
            return other + self
        else:
            return self.__check_and_execute(other, "+")

    def __sub__(self, other):
        """subtract given value from scalar"""

        if is_p_vector(other):
            return other - self
        else:
            return self.__check_and_execute(other, "-")

    def __mul__(self, other):
        """multiply scalar with given value"""

        if is_p_vector(other):
            return other * self
        else:
            return self.__check_and_execute(other, "*")

    def __div__(self, other):
        """divide scalar with given value"""

        if is_p_vector(other):
            return other / self
        else:
            return self.__check_and_execute(other, "/")

    def __ne__(self, other):
        """check whether scalar value is not equal to given value"""

        return self.__check_and_execute(other, "~=")

    def __eq__(self, other):
        """check whether scalar value is equal to given value"""

        return self.__check_and_execute(other, "==")

    def __ge__(self, other):
        """check whether scalar is greater than or equal to given value"""

        return self.__check_and_execute(other, ">=")

    def __gt__(self, other):
        """check whether scalar is greater than given value"""

        return self.__check_and_execute(other, ">")

    def __le__(self, other):
        """check whether first scalar is less than or equal to second scalar"""

        return self.__check_and_execute(other, "<=")

    def __lt__(self, other):
        """check whether first scalar is less than second scalar"""

        return self.__check_and_execute(other, "<")

    def __abs__(self):
        return self.abs()

    def __str__(self):
        """string representation of scalar"""

        return self.to_str()