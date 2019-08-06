local ffi = require 'ffi'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local Dictionary = require 'Q/UTILS/lua/dictionary'
local get_ptr = require "Q/UTILS/lua/get_ptr"

local fns = {}

-- SV variable length strings
local SV_strings = { "test_sv_dummy_string", "test_sv_temp_string", "test_sv_string", "test_sv", "test_string"}
-- SC fixed length strings
local SC_strings = { "test_sc_string1", "test_sc_string2" }

--placing random seed once at start for generating random no. each time
math.randomseed(os.time())

-- function to check if string is present in the table or not
local function has_value (tab, val)
  for idx, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

fns.validate_values = function(vec, qtype, chunk_number)
  -- Temporary hack to pass chunk number to get_chunk in case of nascent vector
  -- This hack is not required as this case is handled
  -- Refer mail with sub "Calling get_chunk() method from lVector.lua for nascent vector without passing chunk_num"
  -- if vec:num_elements() <= qconsts.chunk_size then
  --  chunk_number = 0
  -- end
  local status, len, base_data, nn_data 
  if not chunk_number then
    assert(vec:is_eov())
    status, len, base_data, nn_data = pcall(vec.get_all, vec)
  else
    status, len, base_data, nn_data = pcall(vec.chunk, vec, chunk_number)
  end
  assert(status, "Failed to get the chunk from vector")
  assert(base_data, "Received base data is nil")
  assert(len, "Received length is not proper")
  
  if qtype == "SV" or qtype == "SC" then
    local table_type 
    if qtype == "SV" then table_type = SV_strings else table_type = SC_strings end
    for itr = 1, len do
      local actual_str = c_to_txt(vec, itr)
      local is_str_present = has_value( table_type, actual_str )
      if not is_str_present then
        status = false
        print("Value mismatch in " .. qtype .. " vector at index " .. itr)
        break
      end
    end
    return status
  end
  
  
  if qtype == "B1" then
    for i = 1 , len do 
      local bit_value = c_to_txt(vec, i)
      if bit_value == nil then bit_value = 0 end
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
  

  -- Temporary: no validation of vector values if has_nulls == true
  if vec:has_nulls() then
    assert(nn_data, "Received nn_data is nil")
    return true
  end
  
  --local iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", base_data)
  for i = 1, len do
    local expected = i*10 % qconsts.qtypes[qtype].max
    local value = c_to_txt(vec,i)
    -- print(expected, value)
    if ( value ~= expected ) then
      status = false
      print("Value mismatch at index " .. tostring(i) .. ", expected: " .. tostring(expected) .. " .... actual: " .. tostring(value))
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
    
    if qtype == "SV" then
      local sv_table_len = #SV_strings
      local dict = "D1"
      local dict_obj = assert(Dictionary(dict))
      vec:set_meta("dir", dict_obj)
      
      local base_data = cmem.new(field_size * num_elements)
      local iptr = ffi.cast(qconsts.qtypes.I4.ctype .. " *", get_ptr(base_data))
      
      local stridx = 0
      for itr = 1, num_elements do
        local index = math.random(1, sv_table_len)
        stridx = dict_obj:add(SV_strings[index])
        -- print("Dict data : ",stridx,SV_strings[index])
        iptr[itr - 1] = stridx
      end
      vec:put_chunk(base_data, nil, num_elements)
      
    elseif qtype == "SC" then
      local sc_table_len = #SC_strings
      local base_data = cmem.new(field_size)
      for itr = 1, num_elements do
        local index = math.random(1, sc_table_len)
        local str = SC_strings[index]
        ffi.copy(get_ptr(base_data), str)
        vec:put_chunk(base_data, nil, 1)
      end
    else
      local buf_length = num_elements
      local base_data, nn_data
      if qtype == "B1" then 
        -- We will populate a buffer by putting 8 bits at a time
        field_size = 8
        qtype = "I1"
        is_B1 = true
        num_elements = math.ceil(num_elements / 8)
      end
      base_data = cmem.new(num_elements * field_size)
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
      
      -- Check if vec has nulls
      if vec:has_nulls() then
        field_size = 8
        qtype = "I1"
        num_elements = math.ceil(num_elements / 8)
        
        nn_data = cmem.new(num_elements * field_size)
        local nn_iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", get_ptr(nn_data))
        for itr = 1, num_elements do
          nn_iptr[itr - 1] = itr*10 % qconsts.qtypes[qtype].max
        end      
      end
      
      vec:put_chunk(base_data, nn_data, buf_length)
    end
    assert(vec:check())
    status = true    
  end
  
  if gen_method == "scalar" then
    --local s1 = Scalar.new(qconsts.qtypes[qtype].min, qtype)
    --vec:put1(s1)
    for i = 1, num_elements do
      local s1, s1_nn
      if qtype == "B1" then
        local bval
        if i % 2 == 0 then bval = false else bval = true end
        s1 = Scalar.new(bval, qtype)
      else
        s1 = Scalar.new(i*10% qconsts.qtypes[qtype].max, qtype)
      end
      if vec:has_nulls() then
        local bval
        if i % 2 == 0 then bval = true else bval = false end
        s1_nn = Scalar.new(bval, "B1")
      end
      vec:put1(s1, s1_nn)
    end
    --s1 = Scalar.new(qconsts.qtypes[qtype].max, qtype)
    --vec:put1(s1)    
    status = true
  end
  
  if gen_method == "func" then
    local num_chunks = num_elements
    local chunk_size = qconsts.chunk_size
    for chunk_num = 1, num_chunks do 
      local a, b, c = vec:chunk(chunk_num-1)
      assert(a == chunk_size)
    end
    status = true
  end
  
  return status
end

return fns
