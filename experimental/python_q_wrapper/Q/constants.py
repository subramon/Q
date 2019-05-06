supported_dtypes = ["I1", "I2", "I4", "I8", "F4", "F8"]
# ============================================================

# Q data types
I1 = "I1"
I2 = "I2"
I4 = "I4"
I8 = "I8"
F4 = "F4"
F8 = "F8"
# ============================================================

# data types that resembles with numpy
int8 = "I1"
int16 = "I2"
int32 = "I4"
int64 = "I8"
float32 = "F4"
float64 = "F8"
# ============================================================

# operator names
MK_COL = "mk_col"
CONST = "const"
ADD = "add"
SUB = 'sub'
MUL = 'mul'
DIV = 'div'
SEQ = "seq"
# ============================================================

# scalar function strings
create_scalar_str = \
    """
    function(val, qtype)
        local Scalar = require 'libsclr'
        return Scalar.new(val, qtype)
    end
    """

scalar_arith_func_str = \
    """
    function(scalar1, scalar2)
        return scalar1 {op} scalar2
    end
    """

scalar_func_str = \
    """
    function(scalar)
        return scalar:{fn_name}()
    end
    """

scalar_func_arg_str = \
    """
    function(scalar, arg_val)
        return scalar:{fn_name}(arg_val)
    end
    """
# ============================================================

# vec function strings
vec_func_str = \
    """
    function(vec)
        return vec:{fn_name}()
    end
    """

vec_func_arg_str = \
    """
    function(vec, arg_val)
        return vec:{fn_name}(arg_val)
    end
    """
# ============================================================

# used in utils.py
list_to_table_str = \
    """
    function(items)
        local t = {}
        for index, item in python.enumerate(items) do
            t[ index+1 ] = item
        end
        return t
    end
    """

dict_to_table_str = \
    """
    function(d)
        local t = {}
        for key, value in python.iterex(d.items()) do
            t[ key ] = value
        end
        return t
    end
    """
# ============================================================

# lua_op function string
lua_op_fn_str = \
    """
    function(op_name, args)
        return Q[op_name](unpack(args))
    end
    """

# get Q operator names string
q_op_str = \
    """
    local t = {}
    for i, v in pairs(Q) do
        t[#t+1] = i
    end
    return t
    """
