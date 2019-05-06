from Q.constants import *
import Q.lua_executor as executor
from Q.p_scalar import PScalar


class PReducer:
    """
    This class deals with the reducer operations
    """

    def __init__(self, base_reducer):
        self.base_reducer = base_reducer

    def eval(self):
        """
        evaluates the reducer

        Returns:
            returns a tuple of scalars (what we get from Q-lau)
        """

        func_str = vec_func_str.format(fn_name="eval")
        func = executor.eval_lua(func_str)
        result = func(self.base_reducer)
        new_result = []
        if type(result) == tuple:
            for val in result:
                new_result.append(PScalar(base_scalar=val))
        result = tuple(new_result)
        return result

    def get_name(self):
        """returns the name of a reducer"""

        func_str = vec_func_str.format(fn_name="get_name")
        func = executor.eval_lua(func_str)
        result = func(self.base_reducer)
        return result

    def set_name(self, name):
        """sets the name of a reducer"""

        func_str = vec_func_arg_str.format(fn_name="set_name")
        func = executor.eval_lua(func_str)
        result = func(self.base_reducer, name)
        return self

    def value(self):
        """returns value of a reducer"""

        func_str = vec_func_str.format(fn_name="value")
        func = executor.eval_lua(func_str)
        result = func(self.base_reducer)
        return PScalar(base_scalar=result)
