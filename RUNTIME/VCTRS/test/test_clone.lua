local plpath = require 'pl.path' local pldir  = require 'pl.dir'
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lgutils = require 'liblgutils'

local qtype = "I4"
local max_num_in_chunk = 64
local len = 3 * max_num_in_chunk + 7
local tests = {}
tests.t_clone = function()
  collectgarbage("stop")
  local pre_mem = lgutils.mem_used()
  local pre_dsk = lgutils.dsk_used()
  local x = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "x", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x:eval()
  x:chunks_to_lma()
  x:nop()
  local nC = x:num_chunks() 
  for k = 1, nC do 
    assert(x:num_readers(k-1) == 0) 
  end 
  x:nop()
  local nx, cx = x:get_chunk(3); assert(nx == 7)
  x:unget_chunk(3)
  assert(x:num_elements() == len)
  local y = x:clone()
  y:lma_to_chunks()
  y:check()
  assert(x:num_chunks() == y:num_chunks())
  assert(nC == 4)
  x:nop()
  for k = 1, nC do 
    assert(x:num_readers(k-1) == 0) 
  end 
  for i = 1, nC do 
    local nx, cx = x:get_chunk(3); assert(nx == 7)
    x:unget_chunk(3)

    local nx, cx = x:get_chunk(i-1)
    assert(type(cx) == "CMEM")
    assert(type(nx) == "number")

    local ny, cy = y:get_chunk(i-1)
    assert(type(cy) == "CMEM")
    assert(type(ny) == "number")

    assert(nx == ny)
    if ( i == nC ) then 
      assert(nx == 7)
    else
      assert(nx == x:max_num_in_chunk())
    end

    local xptr = get_ptr(cx, "int32_t *")
    local yptr = get_ptr(cy, "int32_t *")
    for j = 1, nx do
      -- print("Checking pointer " .. j .. " out of " .. nx)
      -- print("y[" .. j-1 .. "] = " .. yptr[j-1])
      -- print("x[" .. j-1 .. "] = " .. xptr[j-1])
      assert(xptr[j-1] == yptr[j-1])
    end
    x:unget_chunk(i-1)
    y:unget_chunk(i-1)

  end

  for k = 1, nC do assert(x:num_readers(k-1) == 0) end 
  assert(x:num_readers() == 0)

  local z = Q.vveq(x, y):eval()
  Q.print_csv({x, y, z}, { opfile = "_x"})
  local r = Q.sum(z)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  for k = 1, nC do assert(x:num_readers(k-1) == 0) end 
  assert(x:num_readers() == 0)

  x:delete()
  y:delete()
  z:delete()
  r:delete()
  -- TODO assert(lgutils.mem_used() == 0)
  -- TODO assert(lgutils.dsk_used() == 0)
  local post_mem = lgutils.mem_used()
  local post_dsk = lgutils.dsk_used()
  assert(pre_mem == post_mem)
  assert(pre_dsk == post_dsk)
  collectgarbage("restart")
  print("Test t_clone completed successfully")
end
tests.t_nn_clone = function()
  local x = Q.seq({ len = len, start = 1, by = 1, qtype = qtype})
  local nn_x = Q.const({len = len, val = true, qtype = "BL"})
  x:eval()
  nn_x:eval()
  x:set_nulls(nn_x)
  x:chunks_to_lma()
  assert(x:get_nulls():is_lma() == true)
  local y = x:clone()
  assert(y:has_nulls())
  assert(y:num_elements() == x:num_elements())
  assert(y:qtype() == x:qtype())
  assert(y:max_num_in_chunk() == x:max_num_in_chunk())
  assert(y:uqid() ~= x:uqid())

  local nn_y = y:get_nulls()
  assert(not nn_y:has_nulls())
  assert(nn_y:num_elements() == nn_x:num_elements())
  assert(nn_y:qtype() == nn_x:qtype())
  assert(nn_y:max_num_in_chunk() == nn_x:max_num_in_chunk())
  assert(nn_y:uqid() ~= nn_x:uqid())

  x:drop_nulls()
  y:drop_nulls()
  local n1, n2 = Q.sum(Q.vveq(x, y)):eval()
  assert(n1 == n2)
  local n1, n2 = Q.sum(Q.vveq(nn_x, nn_y)):eval()
  assert(n1 == n2)

  print("Test t_nn_clone completed successfully")
end
tests.t_chnk_clone = function() -- tests cloning when no lma 
  collectgarbage("stop")
  local pre_mem = lgutils.mem_used()
  local pre_dsk = lgutils.dsk_used()

  local max_num_in_chunk = 64
  local len = 3 * max_num_in_chunk + 17
  local xtbl = {}; for i = 1, len do xtbl[i] = i end 
  local nn_xtbl = {}; for i = 1, len do nn_xtbl[i] = true end 
  local x = Q.mk_col(xtbl, "I4", 
    { max_num_in_chunk = max_num_in_chunk}, nn_xtbl)
  assert(x:max_num_in_chunk() == max_num_in_chunk)
  x:set_name("x")

  local y = x:clone()
  assert(x:is_eov())
  assert(y:is_eov()) -- unfortunate consequence of current limitation
  assert(y:has_nulls()) -- unfortunate consequence of current limitation
  -- compare nn_X with nn_y
  local nn_x = x:get_nulls(); x:drop_nulls()
  local nn_y = y:get_nulls(); y:drop_nulls()
  assert(type(nn_x) == "lVector")
  assert(type(nn_y) == "lVector")
  local z = Q.vveq(nn_x, nn_y)
  local r = Q.sum(z)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  r:delete(); z:delete()
  -- compare x with y 
  local z = Q.vveq(x, y)
  local r = Q.sum(z)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  r:delete(); z:delete()

  x:delete()
  y:delete()
  nn_x:delete()
  nn_y:delete()
  local post_mem = lgutils.mem_used()
  local post_dsk = lgutils.dsk_used()
  assert(pre_mem == post_mem)
  assert(pre_dsk == post_dsk)
  collectgarbage("restart")
  print("Test t_chnk_clone completed successfully")
end

  
-- return tests
-- tests.t_clone()
-- tests.t_nn_clone()
tests.t_chnk_clone()
