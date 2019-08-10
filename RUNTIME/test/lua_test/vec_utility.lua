local ffi = require 'ffi'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require "Q/UTILS/lua/get_ptr"

local fns = {}

fns.validate_values = function(vec, qtype, chunk_number, field_size )
  local status = true
  
  local ret_addr, ret_len = vec:get_chunk(chunk_number)
  assert(ret_addr)
  assert(ret_len)
  
  if qtype == "B1" then
    --qtype = "I1"
    --local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", ret_addr)
    for i = 1 , ret_len do 
      local chunk_num = math.floor((i-1)/qconsts.chunk_size)
      --local chunk_idx = (i-1) % qconsts.chunk_size
      
      local ret_addr, ret_len = vec:get_chunk(chunk_num)
      local ctype =  qconsts.qtypes[qtype]["ctype"]
      local casted = ffi.cast(ctype.." *", get_ptr(ret_addr))
      
      local bit_value = tonumber( qc.get_bit_u64(casted, (i-1)) )
      if bit_value ~= 0 then bit_value = 1 end
      local expected
      if i % 2 == 0 then 
        expected = 0
      else 
        expected = 1 
      end
      -- print("Expected value ",expected," Actual value ",bit_value)
      if expected ~= bit_value then
        status = false
        print("Value mismatch at index " .. tostring(i) .. ", expected: " .. tostring(expected) .. " .... actual: " .. tostring(bit_value))
        break
      end
    end
    return status
  end
  
  if qtype == "SC" then
    -- local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", ret_addr)
    for itr = 1, ret_len do
      local chunk_num = math.floor((itr-1)/qconsts.chunk_size)
      --local chunk_id = (i-1) % qconsts.chunk_size
      
      local ret_addr, ret_len = vec:get_chunk(chunk_num)
      local ctype =  qconsts.qtypes[qtype]["ctype"]
      local casted = ffi.cast(ctype.." *", get_ptr(ret_addr))
      
      local chunk_idx = (itr-1) % qconsts.chunk_size
      local actual_str = ffi.string(casted + chunk_idx * field_size)
      local expected_str 
      if itr % 2 == 0 then expected_str = "temp" else expected_str = "dummy" end
      --print("Expected value ",expected_str," Actual value ",actual_str)
      
      if expected_str ~= actual_str then
        status = false
        print("Value mismatch at index " .. tostring(itr) .. ", expected: " .. tostring(expected_str) .. " .... actual: " .. tostring(actual_str))
        break
      end
      
    end
    return status
  end
  
  -- local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", ret_addr)

  for i = 1, ret_len do
    local chunk_num = math.floor((i-1)/qconsts.chunk_size)
    local chunk_idx = (i-1) % qconsts.chunk_size
    
    local ret_addr, ret_len = vec:get_chunk(chunk_num)
    local ctype =  qconsts.qtypes[qtype]["ctype"]
    local casted = ffi.cast(ctype.." *", get_ptr(ret_addr))
    
    local expected = i*10 % qconsts.qtypes[qtype].max
  
    local actual_val = tonumber(casted[chunk_idx])
    if ( actual_val ~= expected ) then
      status = false
      print("Value mismatch at index " .. tostring(i) .. ", expected: " .. tostring(expected) .. " .... actual: " .. tostring(actual_val))
      break
    end
  end
  
  return status
end

-- for generating values ( can be scalar, gen_func, cmem_buf )
-- for B1, cmem_buf generates values as 01010101 i.e. 85 by treating it as I1
fns.generate_values = function( vec, gen_method, num_elements, field_size, qtype)
  local status = false
  if gen_method == "cmem_buf" then 
    local is_B1 = false  
    
    if qtype == "SC" or qtype == "SV" then
      local base_data = cmem.new(field_size)
      for itr = 1, num_elements do
        local str
        if itr%2 == 0 then str = "temp" else str = "dummy" end
        ffi.copy(get_ptr(base_data), str)
        vec:put1(base_data)
      end
    else
      local buf_length = num_elements
      if qtype == "B1" then 
        -- We will populate a buffer by putting 8 bits at a time
        field_size = 8
        qtype = "I1"
        is_B1 = true
        num_elements = math.ceil(num_elements / 8)
      end
      local base_data = cmem.new(num_elements * field_size)
      local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", get_ptr(base_data))
      --iptr[0] = qconsts.qtypes[qtype].min
      for itr = 1, num_elements do
        if is_B1 then 
          iptr[itr - 1] = 85
        else
          iptr[itr - 1] = itr*10 % qconsts.qtypes[qtype].max
        end
      end
      --iptr[num_elements - 1] = qconsts.qtypes[qtype].max
      vec:put_chunk(base_data, buf_length)
    end
    assert(vec:check())
    status = true
  end
  
  
  if gen_method == "scalar" then
    for i = 1, num_elements do
      local s1
      if qtype == "B1" then
        local bval
        if i % 2 == 0 then bval = false else bval = true end
        s1 = Scalar.new(bval, qtype)
      else
        s1 = Scalar.new(i*10% qconsts.qtypes[qtype].max, qtype)
      end
      vec:put1(s1)
    end    
    status = true
  end
  return status
end

return fns
