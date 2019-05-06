local T = {}

local function posdef_linear_solver(A, b)
  return require('Q/OPERATORS/AX_EQUALS_B/lua/do_solver')("full_posdef_positive_solver", A, b)
end
T.posdef = posdef_linear_solver
require('Q/q_export').export('posdef_linear_solver', posdef_linear_solver)

local function general_linear_solver(A, b)
  return require('Q/OPERATORS/AX_EQUALS_B/lua/do_solver')("positive_solver", A, b)
end
T.general = general_linear_solver
require('Q/q_export').export('general_linear_solver', general_linear_solver)

return T
