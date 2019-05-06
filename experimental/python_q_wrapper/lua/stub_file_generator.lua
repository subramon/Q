local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local pl_str = require 'pl.stringx'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local path_to_here = Q_SRC_ROOT .. "/experimental/python_q_wrapper/lua/"

-- stub file name and path
local filename = path_to_here .. "q_op_stub_file.pyi"
local f = io.open(filename, "w+")

local write_to_stub_file = function(func_signature)
  assert(f:write(func_signature), "Write failed")
end

for name,func in pairs(Q) do
  --print(name, func)
  if name ~= "save" and name ~= "restore" and name ~= "view_meta" and name ~= "Dictionary" then
    local status, docstring = pcall(Q[name], "help")
    if status==true and docstring then
      -- now processing the docstring to get Q operators signature
      
      -- TODO: asserting/checking has not done
      -- to get "Signature: Q.mk_col(input, qtype, opt_nn_input)" in str
      local str = pl_str.splitv(docstring, "\n")
      -- to get function arguments
      local _, _, lua_args = pl_str.partition(str, "(")
      -- to strip right parenthesis
      lua_args = pl_str.rstrip(lua_args, ")")
      local tbl = pl_str.split(lua_args, ",")
      for i = 1, #tbl do
        -- stripping spaces if any
        tbl[i] = pl_str.strip(tbl[i])
        -- replace opt_* to opt_args=None
        if pl_str.lfind(tbl[i], "opt") then
          tbl[i] = tbl[i] .. "=None"
        end
      end
      --tbl to string
      local py_args = utils['table_to_str'](tbl, ", ")
      local func_signature = "def " .. name .."(".. py_args .. "):\n    pass\n\n"
      write_to_stub_file(func_signature)
    end
  end
end

print("Stub file location: ".. filename)
f:close()

-- this is the docstring which we get from Q.mk_col("help") call
--[[
Signature: Q.mk_col(input, qtype, opt_nn_input)
-- creates a column of input table values of input qtype
1) input: array of values
2) qtype: desired qtype of column
3) nn_input: array of nn values
-- returns: column of input values of qtype
--]]

-- this what get dumped into stub_file.py which is required by python-Q wrapper
--[[
def mk_col(input, qtype, nn_input=None):
    pass
--]]
