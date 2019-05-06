import Q.lua_executor as executor
from Q.constants import list_to_table_str, dict_to_table_str
from Q import lupa
from Q import q_op_category as q_cat
from Q.p_reducer import PReducer
from Q.p_scalar import PScalar
from Q.p_vector import PVector
from Q.validate import is_p_vector, is_p_scalar


def is_valid_arg():
    pass


def pack_args(val):
    """
    Convert args for a Q-lua function

    Parameters:
        val: a python object (list, dict, number, string etc)

    Returns:
        a lua representation for given python object
    """

    if is_p_vector(val):
        return val.get_base_vec()
    elif is_p_scalar(val):
        return val.get_base_scalar()
    elif type(val) == list or type(val) == tuple:
        new_list = []
        for arg in val:
            new_list.append(pack_args(arg))
        return to_table(new_list)
    elif type(val) == dict:
        for i, v in val.items():
            val[i] = pack_args(v)
        return to_table(val)
    else:
        return val


def wrap_output(op_name, result):
    """
    Convert output from a Q-lua function

    Parameters:
        op_name: the operation name
        result: output from Q-lua function

    Returns:
        a python object (representation) for Q-lua object
    """
    if op_name in q_cat.number_as_output:
        # no action required
        pass
    elif op_name in q_cat.string_as_output:
        # no action required
        pass
    elif op_name in q_cat.reducer_as_output:
        # wrap it with PReducer
        result = PReducer(result)
    elif op_name in q_cat.scalar_as_output:
        # wrap it with PScalar
        result = PScalar(base_scalar=result)
    elif op_name in q_cat.table_as_output:
        # convert lua table to dict/list
        result = util.to_list_or_dict(result)
        for key, val in result.items():
            result[key] = PVector(val)
    elif op_name in q_cat.vec_as_output:
        # wrap it with PVector
        result = PVector(result)
    else:
        raise Exception("Output type is not supported for operator {}".format(op_name))
    return result


def to_table(in_val):
    """
    converts input list or dict to table

    Parameters:
        in_val: a list or dict

    Returns:
        returns a lua table
    """

    func = None
    if type(in_val) == list:
        func = executor.eval_lua(list_to_table_str)
    elif type(in_val) == dict:
        func = executor.eval_lua(dict_to_table_str)
        in_val = lupa.as_attrgetter(in_val)
    else:
        print("Error")
    return func(in_val)


def to_list(in_table):
    """converts a lua table to list"""

    # TODO: check type of in_table, it should be lua table
    return list(in_table)


def to_dict(in_table):
    """converts a lua table to dict"""

    # TODO: check type of in_table, it should be lua table
    return list(in_table)


def to_list_or_dict(in_table):
    # TODO: check type of in_table, it should be lua table
    return dict(in_table)
