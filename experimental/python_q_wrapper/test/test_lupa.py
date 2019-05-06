from Q import utils, lua_executor


q_op_str = \
    """
    local Q = require 'Q'
    local t = {}
    for i, v in pairs(Q) do
        t[i] = v
    end
    return t
    """
q_operators = [ str(x) for x in dict(lua_executor.execute_lua(q_op_str)).keys() ]

# for i in q_operators:
#     print(i)


func_str = \
    """
    function(a, b)
        return a + b
    end
    """

func = lua_executor.eval_lua(func_str)
try:
    print(func(5, 9))
    print(func(None, 9))
except Exception as e:
    print(str(e))
print("Done")


print("=======================")

in_val = [1, 2, 3, 4]
res = utils.to_table(in_val)
print(type(res))
print(list(res))
print(dict(res))
