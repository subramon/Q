import lupa

# Creates a lua runtime (environment)
lua_runtime = lupa.LuaRuntime(unpack_returned_tuples=True)
lua_runtime.execute("Q = require 'Q'")


from q_op_loader import op_wrapper
from q_op_loader import q_operators
from q_op_stub import *
from q_helper import *
from constants import *


# registers Q-lua functions to python global environment
for op_name in q_operators:
    globals()[op_name] = op_wrapper(op_name)