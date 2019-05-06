local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local tests = {}
tests.t1 = function() 
  local buf = cmem.new(4096, "I4", "t1 buf")
  local M
  local is_memo
  local chunk_size = qconsts.chunk_size
  local rslt

  --==============================================
  -- Can get current chunk num but cannot get previous 
  -- ret_len should be number of elements in chunk
  local s = Scalar.new(123, "I4")
  local orig_ret_addr = nil
  local num_iters = 1 -- default value 
  
  print("num_iters = ", num_iters)

  for j = 1, num_iters do
    local y = Vector.new('I4', qconsts.Q_DATA_DIR)
    for i = 1, chunk_size do 
      local status = y:put1(s)
      assert(status)
      local ret_cmem, ret_len = y:get_chunk(0);
      assert(ret_cmem);
      assert(type(ret_cmem) == "CMEM")
      assert(ret_len == i)
      if ( i == 1 ) then 
        orig_ret_addr = get_ptr(ret_cmem, "I4")
      else
        local ret_addr = get_ptr(ret_cmem, "I4")
        assert(ret_addr == orig_ret_addr)
      end
    end
    local status = y:put1(s)
    assert(status)
    local ret_addr, ret_len = y:get_chunk(0);
    assert(ret_addr)
    assert(type(ret_addr) == "CMEM")
    assert(ret_len == chunk_size) -- can get previous chunk
    ret_addr, ret_len = y:get_chunk(1);
    assert(ret_len == 1)
    if ( ( j % 1000 ) == 0 )  then print("Iters ", j) end
  end
  print("Completed test t1")
end
return tests
