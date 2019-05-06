local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

tests.t1 = function()
  local col = Q.mk_col({1, 5, 4, 2, 3, 7, 9}, "I4")
  local res = Q.maxk_vector(col, 3)
  local exp_col = Q.mk_col({9, 7, 5}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t1")
end

tests.t2 = function()
  -- vector with more than chunk size values
  local len = 65536*2 + 45
  local col = Q.rand( { lb = 100, ub = 200, qtype = "I4", len = len })
  local res = Q.maxk_vector(col, 3)
  Q.print_csv(res)
  print("successfully completed t2")
end

tests.t3 = function()
  -- vector having repeated max values
  local col = Q.mk_col({1, 2, 4, 9, 3, 7, 9}, "I4")
  local res = Q.maxk_vector(col, 3)
  local exp_col = Q.mk_col({9, 9, 7}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t3")
end

tests.t4 = function()
  -- vector having more than chunk size values, max value appears in first chunk
  local len = 65536 + 45
  local in_table = {}
  for i = 1, len do
    in_table[i] = i
  end
  -- place max value in first chunk
  in_table[3] = 65536 + 48

  local col = Q.mk_col(in_table, "I4")
  local res = Q.maxk_vector(col, 3)
  local exp_col = Q.mk_col({65536 + 48, 65536 + 45, 65536 + 44}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t4")
end

-- test maxk_reducer for num_elements > chunk_size
-- where max values are in second chunk
tests.t6 = function()
  local chunk_size = qconsts.chunk_size
  local input_tbl_val = {}
  local input_tbl_drag = {}
  for i = 1, chunk_size do 
    input_tbl_val[i] = i*10
    input_tbl_drag[i] = i
  end
  for i = chunk_size+1, chunk_size+10 do
    input_tbl_val[i] = i%chunk_size
    input_tbl_drag[i] = i
  end

  local val = Q.mk_col(input_tbl_val, "I4")
  local drag = Q.mk_col(input_tbl_drag, "I4")
  local res = Q.maxk_reducer(val, drag, 3)
  local val_k, drag_k = res:eval()
  print("========================")
  for i, v in ipairs(val_k) do
    print(val_k[i], drag_k[i])
  end
  os.exit()
  local exp_col = Q.mk_col({1, 2, 3}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t6")
end

return tests
