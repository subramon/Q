local Q = require 'Q'
-- input args are in the order below
-- operation like vvadd, vvsub etc
-- qtype_input1 - qtype of first input argument
-- qtype_input2 - qtype of second input argument
-- input1 - lua table of values
-- input2 - lua table of values

return function(operation, qtype_input1, qtype_input2, input1, input2)
  local col1 = Q.mk_col (input1, qtype_input1)
  local col2 = Q.mk_col (input2, qtype_input2)

  -- print("Testcase ", operation ,"...q_type", qtype_input1, qtype_input2 )
  local result_col = Q[operation](col1, col2, { junk = "junk" } )
  result_col:eval()
  return result_col
end