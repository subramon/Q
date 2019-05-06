--FUNCTIONAL TEST
local Q = require 'Q'

local tests = {}

tests.vvand = function()
  local col1 = { 0, 0, 1, 1 }
  local col2 = { 0, 1, 0, 1 }
  local expected = "0\n0\n0\n1\n"
  local col1 = Q.mk_col (col1, "B1")
  local col2 = Q.mk_col (col2, "B1")
  local result_col = Q.vvand(col1, col2, { junk = "junk" } )
  result_col:eval()
  local opt_args = { opfile = "" }
  local actual = Q.print_csv(result_col, opt_args)
  print("Actual vvand output\n"..actual)
  assert(actual == expected, "vvand: input and output not matched")
end

tests.vvor = function()
  local col1 = { 0, 0, 1, 1 }
  local col2 = { 0, 1, 0, 1 }
  local expected = "0\n1\n1\n1\n"
  local col1 = Q.mk_col (col1, "B1")
  local col2 = Q.mk_col (col2, "B1")
  local result_col = Q.vvor(col1, col2, { junk = "junk" } )
  result_col:eval()
  local opt_args = { opfile = "" }
  local actual = Q.print_csv(result_col, opt_args)
  print("Actual vvor output\n"..actual)
  assert(actual == expected, "vvor: input and output not matched")
end

tests.vvandnot = function()
  local col1 = { 0, 0, 1, 1 }
  local col2 = { 0, 1, 0, 1 }
  local expected = "0\n0\n1\n0\n"
  local col1 = Q.mk_col (col1, "B1")
  local col2 = Q.mk_col (col2, "B1")
  local result_col = Q.vvandnot(col1, col2, { junk = "junk" } )
  result_col:eval()
  local opt_args = { opfile = "" }
  local actual = Q.print_csv(result_col, opt_args)
  print("Actual vvandnot output\n"..actual)
  assert(actual == expected, "vvandnot: input and output not matched")
end

return tests
