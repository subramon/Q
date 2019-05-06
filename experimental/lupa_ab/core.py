import json
from lua_executor import Executor


executor = Executor()
executor.execute("ab = require 'core'")


init_ab_str = \
    """
    function(config_file)
        return ab.init_ab(config_file)
    end
    """

sum_ab_str = \
    """
    function(ab_struct, json_body)
        return ab.sum_ab(ab_struct, json_body)
    end
    """

print_ab_str = \
    """
    function(ab_struct)
        return ab.print_ab(ab_struct)
    end
    """

free_ab_str = \
    """
    function(ab_struct)
        return ab.free_ab(ab_struct)
    end
    """


def init_ab(config_file):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(init_ab_str)
    result = func(config_file)
    return result


def sum_ab(ab_struct, factor):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(sum_ab_str)
    json_body = json.dumps({'factor': factor})
    result = func(ab_struct, json_body)
    return result


def print_ab(ab_struct):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(print_ab_str)
    result = func(ab_struct)
    return result


def free_ab(ab_struct):
    # func_str = vec_func_str.format(fn_name="eval")
    func = executor.eval(free_ab_str)
    result = func(ab_struct)
    return result

