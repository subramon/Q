import Q.lua_executor as executor
import Q.utils as util
from Q import constants as q_consts
from Q.p_vector import PVector
from Q.p_reducer import PReducer
from Q.p_scalar import PScalar
import math


def call_lua_op(op_name, *args):
    """
    this functions calls the given Q-lua function with specified arguments

    Parameters:
        op_name: operation (Q-lua function) name (is a string)
        args: arguments to be passed to specified function

    Return:
        execution result of a function
    """

    # convert the python objects to lua
    args_table = util.pack_args(args)
    try:
        func = executor.eval_lua(q_consts.lua_op_fn_str)
        result = func(op_name, args_table)
    except Exception as e:
        # TODO: Handle operator level failures properly
        print(str(e))
        result = None
    if result:
        # wrap the lua objects to python
        result = util.wrap_output(op_name, result)
    return result


def __get_default_dtype(val_type):
    """returns the default types"""

    if val_type == int:
        dtype = q_consts.int64
    elif val_type == float:
        dtype = q_consts.float64
    else:
        raise Exception("input element type %s is not supported" % val_type)
    return dtype


# ==============================================


def array(in_vals, dtype=None):
    """Wrapper around Q.mk_col"""

    assert((type(in_vals) == list) or (type(in_vals) == tuple))
    if not dtype:
        val_type = type(in_vals[0])
        dtype = __get_default_dtype(val_type)
    if dtype not in q_consts.supported_dtypes:
        raise Exception("dtype %s is not supported" % dtype)

    # convert in_vals to lua table
    in_vals = util.to_table(in_vals)

    # call wrapper function
    return call_lua_op(q_consts.MK_COL, in_vals, dtype)


def full(shape, fill_value, dtype=None):
    """Create a constant vector, wrapper around Q.const"""

    assert(type(shape) == int)
    if not dtype:
        val_type = type(fill_value)
        dtype = __get_default_dtype(val_type)
    if dtype not in q_consts.supported_dtypes:
        raise Exception("dtype %s is not supported" % dtype)

    # call wrapper function
    in_val = {'val': fill_value, 'qtype': dtype, 'len': shape}
    return call_lua_op(q_consts.CONST, in_val)


def zeros(shape, dtype=None):
    """Create a constant vector with value zero"""

    return full(shape, 0, dtype)


def ones(shape, dtype=None):
    """Create a constant vector with value one"""

    return full(shape, 1, dtype)


def arange(start=0, stop=None, step=1, dtype=None):
    """Create a sequence according to inputs, wrapper around Q.seq()"""

    if not stop:
        stop = start
        start = 0
    if not (type(stop) == int or type(stop) == float):
        raise Exception("stop value can't be %s" % type(stop))
    if not dtype:
        val_type = type(stop)
        dtype = __get_default_dtype(val_type)
    if dtype not in q_consts.supported_dtypes:
        raise Exception("dtype %s is not supported" % dtype)
    length = math.ceil(float(stop - start) / step)

    # call wrapper function
    in_val = {'start': start, 'by': step, 'qtype': dtype, 'len': length}
    return call_lua_op(q_consts.SEQ, in_val)


def sqrt(vec):
    pass


def exp(vec):
    pass
