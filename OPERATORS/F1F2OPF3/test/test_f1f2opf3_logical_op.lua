--FUNCTIONAL TEST
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local plfile = require 'pl.file'

local tests = {}

tests.vvand = function()
  local col1 = { 0, 0, 1, 1 }
  local col2 = { 0, 1, 0, 1 }
  local expected = "0\n0\n0\n1\n"
  local col1 = Q.mk_col (col1, "B1")
  local col2 = Q.mk_col (col2, "B1")
  local result_col = Q.vvand(col1, col2, { junk = "junk" } )
  result_col:eval()
  local opt_args = { opfile = "_xx" }
  Q.print_csv(result_col, opt_args)
  local actual = plfile.read("_xx")
  assert(actual == expected, "vvand: input and output not matched")
  print("Test vvand succeeded")
end

tests.vvor = function()
  local col1 = { 0, 0, 1, 1 }
  local col2 = { 0, 1, 0, 1 }
  local expected = "0\n1\n1\n1\n"
  local col1 = Q.mk_col (col1, "B1")
  local col2 = Q.mk_col (col2, "B1")
  local result_col = Q.vvor(col1, col2, { junk = "junk" } )
  result_col:eval()
  local opt_args = { opfile = "_xx" }
  Q.print_csv(result_col, opt_args)
  local actual = plfile.read("_xx")
  assert(actual == expected, "vvor: input and output not matched")
  print("Test vvor succeeded")
end

tests.vvandnot = function()
  local col1 = { 0, 0, 1, 1 }
  local col2 = { 0, 1, 0, 1 }
  local expected = "0\n0\n1\n0\n"
  local col1 = Q.mk_col (col1, "B1")
  local col2 = Q.mk_col (col2, "B1")
  local result_col = Q.vvandnot(col1, col2, { junk = "junk" } )
  result_col:eval()
  local opt_args = { opfile = "_xx" }
  Q.print_csv(result_col, opt_args)
  local actual = plfile.read("_xx")
  assert(actual == expected, "vvand: input and output not matched")
  print("Test vvandnot succeeded")
end

return tests
