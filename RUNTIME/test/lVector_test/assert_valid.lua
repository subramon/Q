local plfile  = require 'pl.file'
local plpath  = require 'pl.path'
local dbg    = require 'Q/UTILS/lua/debugger'
local vec_utils = require 'Q/RUNTIME/test/lVector_test/vec_utility'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
local cmem    = require 'libcmem'
local get_ptr = require "Q/UTILS/lua/get_ptr"

local fns = {}

--===================

local set_value = function(buffer, index, value)
  buffer[index] = value
end
--===================

local validate_vec_meta = function(meta, is_materialized, num_elements, performed_eov)
  local status = true
  
  -- meta.base checks
  assert(meta.base.num_elements == num_elements)
  if is_materialized then
    assert(meta.base.is_nascent == false)
    assert(meta.base.is_eov == true)
    if meta.base.is_memo then
      assert(meta.base.file_name)
      assert(plpath.exists(meta.base.file_name))
    end
    --assert(meta.base.chunk_num == 0)
    --assert(meta.base.num_in_chunk == 0)    
  else
    assert(meta.base.is_nascent == true)
    -- assert(meta.base.chunk_num == math.floor(num_elements / qconsts.chunk_size))
    -- assert(meta.base.num_in_chunk == num_elements % qconsts.chunk_size)
    if performed_eov then
       assert(meta.base.is_eov == true)
       if meta.base.is_memo then
         assert(plpath.exists(meta.base.file_name))
       end
    elseif performed_eov == false then
       assert(meta.base.is_eov == false)
       if meta.base.num_elements < qconsts.chunk_size or not meta.base.is_memo then
         assert(meta.base.file_name == nil)
       else
         assert(meta.base.file_name)
       end
    end
  end
  
  -- meta.nn checks
  if meta.nn then
    assert(meta.nn.num_elements == num_elements)
    if is_materialized then
      assert(meta.nn.is_nascent == false)
      assert(meta.nn.file_name)
      assert(plpath.exists(meta.nn.file_name))
      assert(meta.nn.chunk_num == 0)
      assert(meta.nn.num_in_chunk == 0)    
    else
      assert(meta.nn.is_nascent == true)
      if meta.base.num_elements < qconsts.chunk_size or not meta.base.is_memo then
        assert(meta.nn.file_name == nil)
      end
      assert(meta.nn.chunk_num == math.floor(num_elements / qconsts.chunk_size))
      assert(meta.nn.num_in_chunk == num_elements % qconsts.chunk_size)    
    end    
  end
  
  return status
end
--===================

local nascent_vec_basic_operations = function(vec, test_name, num_elements, gen_method, perform_eov, validate_values)
  -- Validate metadata
  local md = vec:meta()
  local is_materialized = false
  local performed_eov = false
  local status = validate_vec_meta(md, is_materialized, 0, performed_eov)
  assert(status, "Metadata validation failed before vec:eov()")
  
  -- calling gen method for nascent vector to generate values ( can be scalar or cmem buffer )
  if gen_method then
    status = vec_utils.generate_values(vec, gen_method, num_elements, md.base.field_size, md.base.field_type)
    assert(status, "Failed to generate values for nascent vector")
  end
  -- Call vector eov
  if perform_eov == true or perform_eov == nil then
    vec:eov()
    assert(vec:check(), "Failed in vector check after vec:eov()")
  end
  -- Validate vector values
  -- TODO: modify validate values to work with gen_method == func
  if gen_method ~= "func" then
    if validate_values == true or validate_values == nil then
      local num_elements = vec:num_elements()
      local no_of_chunks = math.ceil( num_elements / qconsts.chunk_size )
      -- print("number of chunks are==========",no_of_chunks)
      for chunk_no = 0,no_of_chunks-1 do
        status = vec_utils.validate_values(vec, md.base.field_type, chunk_no)
        assert(status, "Vector values verification failed")
      end
    end
  end
  return true
end
--===================

local materialized_vec_basic_operations = function(vec, test_name, num_elements, validate_values)
  -- Validate metadata
  local md = vec:meta()
  local is_materialized = true
  local status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed for materialized vector")  
    
  if validate_values == true or validate_values == nil then
    -- Validate vector values
    status = vec_utils.validate_values(vec, md.base.field_type)
    assert(status, "Vector values verification failed")
  end

  status = vec:persist(true)
  assert(status)
  
  return true
end
--===================

-- write values to nascent vector with cmem_buf or scalar
fns.assert_nascent_vector1 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  -- in basic operations, vector values are validated
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized = false -- still vector can be served from in-memory buffer for current chunk
  local performed_eov = true 
 
  status = validate_vec_meta(md, is_materialized, num_elements, performed_eov)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size for base
  local expected_file_size
  if md.base.field_type == "B1" then
    expected_file_size = (math.ceil(num_elements/64.0) * 64) / 8
  else
    expected_file_size = num_elements * md.base.field_size
  end
  local actual_file_size = plpath.getsize(md.base.file_name)
  assert(actual_file_size == expected_file_size, "File size mismatch with expected value")

  if md.nn then
    -- Check file size for nn
    expected_file_size = (math.ceil(num_elements/64.0) * 64) / 8
    actual_file_size = plpath.getsize(md.nn.file_name)
    assert(actual_file_size == expected_file_size, "File size mismatch with expected value")
  end
  
  return true
  
end
--===================

-- write values to nascen vector using generator function
fns.assert_nascent_vector2 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local chunk_size = qconsts.chunk_size
  local md = vec:meta()
  --- here validate value for gen is not done 
  -- so it remains a nascent vector
  local is_materialized = false
  
  -- for gen function, num_elements = num_of_chunks * chunk_size
  -- here, arg num_elements represents num_of_chunks
  status = validate_vec_meta(md, is_materialized, num_elements * chunk_size)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size
  assert(plpath.getsize(md.base.file_name) == num_elements * chunk_size * md.base.field_size, "File size mismatch with expected value")

  return true
end
--===================

-- Validation when is_memo is false
-- try eov - should not success
-- try adding element after eov -- can not add
fns.assert_nascent_vector3_1 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov(), should be nascent vector as is_memo is false
  local md = vec:meta()
  assert(md.base.is_nascent == true, "Expected a nascent vector but actual value is not matching")
  assert(md.base.file_name == nil, "Nascent vector file name should be nil")
  
  -- Try adding element to eov'd nascent vector, should fail
  local s1 = Scalar.new(123, md.base.field_type)
  status = pcall(vec.put1, vec, s1)
  assert(status == false)
  assert(md.base.num_elements == vec:num_elements(), "Able to add value to eov'd nascent vector")
  assert(vec:check())
  
  return true
end
--===================

-- Validation when is_memo is false
-- try persist -- should not work
fns.assert_nascent_vector3_2 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov(), should be nascent vector as is_memo is false
  local md = vec:meta()
  assert(md.base.is_nascent == true, "Expected a nascent vector but actual value is not matching")
  assert(md.base.file_name == nil, "Nascent vector file name should be nil")
  -- Try persist() method with true, it should fail
  status = vec:persist(true)
  assert(status == nil, "Able set persist even if memo is false")
  
  return true
end
--===================

-- Validation when is_memo is false
-- set memo true and try vec:check() -- validation should work
fns.assert_nascent_vector3_3 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, false)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov(), should be nascent vector as is_memo is false
  local md = vec:meta()
  assert(md.base.is_nascent == true, "Expected a nascent vector but actual value is not matching")
  assert(md.base.file_name == nil, "Nascent vector file name should be nil")
  
  -- Try setting memo to true when chunk_num is zero i.e num_elements < chunk_size
  -- file_name should not be initialized, vec:check() should be successful
  assert(md.base.chunk_num == 0)
  status = vec:memo(true)
  assert(status, "Failed to update memo even if chunk_num is zero i.e num_elements < chunk_size")
  md = vec:meta()
  assert(vec:check())
  assert(md.base.file_name == nil, "File name initialized even if num_elements < chunk_size")
  
  return true
end
--===================

-- try to modify values of a vec (nascent -> materialized) using mmap ptr withoud start_write()
fns.assert_nascent_vector4 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  print(num_elements) 
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized = true
  status = validate_vec_meta(md, is_materialized, num_elements)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Check file size
  assert(plpath.getsize(md.base.file_name) == num_elements * md.base.field_size, "File size mismatch with expected value")
  
  -- Try to modify values of a read only vector
  local len, base_data, nn_data = vec:get_all()
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", get_ptr(base_data))
  status = pcall(set_value, iptr, 0, 123)
  assert(status == false, "Able to modify read only vector")
  
  return true
end
--===================

-- try modifying memo before first chunk is full - should success
-- try modifying memo after first chunk is flushed - should not work
fns.assert_nascent_vector5 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = false
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  assert(md.base.is_nascent == true, "Expected a nascent vector, but not a nascnet vector")
  
  -- try to modify Memo, this should work as num_elements == chunk_size
  status = vec:memo(false)
  assert(status, "Failed to modify memo even if first chunk is not flushed i.e num_chunk == 0")
  assert(vec:check())
  assert(status)
  
  -- Add single element so the (num_elements > chunk_size)
  local s1 = Scalar.new(123, md.base.field_type)
  status = vec:put1(s1)
  assert(vec:check())
  
  -- Try to modify Memo, this should fail
  status = vec:memo(false)
  assert(vec:check())
  assert(status == nil, "Able to modify memo even after first chunk is flushed")
  
  -- Validate metadata
  md = vec:meta()
  local is_materialized = false
  status = validate_vec_meta(md, is_materialized, num_elements + 1)
  assert(status, "Metadata validation failed")
  
  return true
end
--===================

-- nascent vector, vector is with nulls but don't provide nn_data in put_chunk
fns.assert_nascent_vector6 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  local md = vec:meta()
  
  -- create base buffer
  local base_data = cmem.new(md.base.field_size)
  local iptr = ffi.cast(qconsts.qtypes[md.base.field_type].ctype .. " *", get_ptr(base_data))
  iptr[0] = 121
  
  -- try put chunk
  local status = pcall(vec.put_chunk, vec, base_data, nil, 1)
  assert(status == false)
  
  return true
end
--===================

-- nascent vector, vector is with nulls but don't provide nn_data in put1
fns.assert_nascent_vector7 = function(vec, test_name, num_elements, gen_method)  
  -- common checks for vectors
  assert(vec:check())
  local md = vec:meta()
  
  -- create base scalar
  local s1 = Scalar.new(123, md.base.field_type)
  
  -- try put1
  local status = pcall(vec.put1, vec, s1)
  assert(status == false)
  
  return true
end
--===================

-- nascent_vector --> eov() ( i.e. is_nascent = T and is_eov = T )
-- if we read values, its the last_chunk and it will be served from buffer itself
-- so is_nascent remains T 
-- now trying start_write(), should success and after start_write() is_nascent is set to F
fns.assert_nascent_vector8_1_1 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = true
  -- validating(reading) values servers me from buffer itself
  local validate_values = true 
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov, validate_values)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized
  local performed_eov = true 
  is_materialized = false

  -- local md = vec:meta()
  -- print(md.base.is_nascent)
  status = validate_vec_meta(md, is_materialized, num_elements, performed_eov)
  assert(status, "Metadata validation failed after vec:eov()")

  -- Try to modify values using start_write()
  -- so is_nascent remains T 
  -- modifying vector using start_write() should success
  local len, base_data, nn_data = vec:start_write()
  assert(base_data, "Failed to open the mmaped file in write mode")
  assert(len, "Failed to open the mmaped file in write mode")
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", get_ptr(base_data))
  
  -- Set value at index 0
  local test_value = 121
  iptr[0] = test_value
  
  -- close the write handle
  vec:end_write()
  
  -- Now chunk() should work as open_mode set to 0, validate modified value
  len, base_data, nn_data = vec:get_all()
  assert(base_data)
  iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", get_ptr(base_data))
  assert(tonumber(iptr[0]) == test_value, "Value mismatch with expected value")
  
  return true
end
--===================

-- nascent_vector --> eov() ( i.e. is_nascent = T and is_eov = T )
-- reading values from previous chunk, (open mode is set to 1) 
-- as reading values from previous chunk( values are serverd from file) 
-- so is_nascent = F ( converted to materialized vector)
-- now trying start_write(), should fail

-- Update: with recent changes start_write() is allowed even if vector is in READ mode status
-- refer start_write() from core_vec.c
fns.assert_nascent_vector8_1_2 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = true
  -- validating(reading) values servers current chunk from buffer, 
  -- but previous chunk servers from file (i.e.open mode is set to 1) 
  -- is_nascent is still true
  local validate_values = true 
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov, validate_values)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized = false -- still current chunk can be served from in_memory buffer
  local performed_eov = true
 
  -- local md = vec:meta()
  -- print(md.base.is_nascent)
  status = validate_vec_meta(md, is_materialized, num_elements, performed_eov)
  assert(status, "Metadata validation failed after vec:eov()")

  
  -- Try to modify values using start_write(), should fail
  -- but open mode is set to 0, 
  local status, len, base_data, nn_data = pcall(vec.start_write, vec)
  --assert(status == false)
  --assert(base_data == nil)
  
  return true
end
--===================

-- nascet vector -> materialized vector (using eov)
-- try consecutive operation of chunk(), should work
fns.assert_nascent_vector8_2 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations, here a get_chunk operation is happening so open_mode set to 1
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized
  local performed_eov = true 
  if md.base.num_elements > qconsts.chunk_size then
    is_materialized = true
  else
    is_materialized = false
  end
  status = validate_vec_meta(md, is_materialized, num_elements,performed_eov)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Now chunk() should work as open_mode set to 1
  local len, base_data, nn_data = vec:get_all()
  assert(base_data)
  
  return true
end
--===================

-- nascet vector -> materialized vector (using eov)
-- try start_write() after read operation, this is not allowed

-- Update: with recent changes start_write() is allowed even if vector is in READ mode status
-- refer start_write() from core_vec.c
fns.assert_nascent_vector8_3 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations, here read operation is happening
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  local is_materialized = false -- still current chunk can be served from in_memory buffer
  local performed_eov = true 
  status = validate_vec_meta(md, is_materialized, num_elements, performed_eov)
  assert(status, "Metadata validation failed after vec:eov()")
  
  -- Try to modify values using start_write()
  local status, len, base_data, nn_data = pcall(vec.start_write, vec)
  --assert(status == false)
  --assert(base_data == nil)
  
  return true
end
--===================

-- For nascent vector, try chunk() without passing chunk_num
-- should return the current chunk
fns.assert_nascent_vector9 = function(vec, test_name, num_elements, gen_method)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations
  local perform_eov = false
  local validate_values = false
  local status = nascent_vec_basic_operations(vec, test_name, num_elements, gen_method, perform_eov, validate_values)
  assert(status, "Failed to perform vec basic operations")
  
  -- Validate metadata after vec:eov()
  local md = vec:meta()
  assert(md.base.is_nascent == true, "Expected a nascent vector, but not a nascnet vector")  

  -- Try chunk() without passing chunk_num, it should return the current chunk
  local len, base_data, nn_data = vec:get_all()
  assert(base_data)
  assert(len == md.base.num_in_chunk)
  
  return true
end
--===================

-- create a materialized vector and validate values
fns.assert_materialized_vector1 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  
  local md = vec:meta()
  if vec._has_nulls then
    assert(md.nn)
  end

  return true
end
--===================

-- try to add element in materialized vector, i.e add element at index num_elements + 1
fns.assert_materialized_vector2 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local validate_values = false
  local status = materialized_vec_basic_operations(vec, test_name, num_elements, validate_values)
  assert(status, "Failed to perform materialized vec basic operations")

  local md = vec:meta()
  
  -- Try setting value at wrong index
  local len, base_data, nn_data = vec:start_write()
  assert(base_data, "Failed to open the mmaped file in write mode")
  assert(len, "Failed to open the mmaped file in write mode")
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", get_ptr(base_data))
  
  -- Set value at index 0
  local test_value = 121
  status = set_value(iptr, md.base.num_elements + 1, test_value)
  assert(status == false, "Able to add element at wrong index for materialized vec")
  
  -- close the write handle
  vec:end_write()
  
  return false
end
--===================

-- try eov over materialized vector
fns.assert_materialized_vector3 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  
  status = pcall(vec.eov, vec)
  --assert(status == false)

  assert(vec:check())

  return true
end
--===================

-- try modifying values of materialized vector with start_write()
fns.assert_materialized_vector4 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local validate_values = false
  local status = materialized_vec_basic_operations(vec, test_name, num_elements, validate_values)
  assert(status, "Failed to perform materialized vec basic operations")

  local md = vec:meta()
  
  -- Try to modify value using start_write()
  local len, base_data, nn_data = vec:start_write()
  assert(base_data, "Failed to open the mmaped file in write mode")
  assert(len, "Failed to open the mmaped file in write mode")
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", get_ptr(base_data))
  
  -- Set value at index 0
  local test_value = 121
  iptr[0] = test_value
  
  -- close the write handle
  vec:end_write()
  
  -- Now chunk() should work as open_mode set to 0, validate modified value
  len, base_data, nn_data = vec:get_all()
  assert(base_data)
  iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", get_ptr(base_data))
  assert(tonumber(iptr[0]) == test_value, "Value mismatch with expected value")
  
  assert(vec:check())

  return true
end
--===================

-- Testcases where vector initialization is expected to fail
fns.assert_materialized_vector5 = function(vec, test_name, num_elements)
  assert(vec == nil)
  return true
end
--===================

fns.assert_materialized_vector6 = function(vec, test_name, num_elements)
  -- common checks for vectors
  assert(vec:check())
  
  -- Perform vec basic operations  
  local status = materialized_vec_basic_operations(vec, test_name, num_elements)
  assert(status, "Failed to perform materialized vec basic operations")
  
  local md = vec:meta()
  if vec._has_nulls then
    assert(md.nn)
  end
 
   -- Try to modify value using start_write()
  assert(vec:start_write(), "Failed to open the mmaped file in write mode")
  local len, base_data, nn_data = vec:get_all()
  -- Can't read as open_mode is set to 2, read operation requires it to be 0
  assert(base_data == nil)
  
  -- How do a get handle of mmaped pointer
  vec:end_write()
  
  -- Now chunk() should work as open_mode set to 0
  len, base_data, nn_data = vec:get_all()
  assert(base_data)
  -- local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  -- status = pcall(set_value, iptr, 0, 123)
  -- assert(status == false, "Able to modify read only vector")
  
  --[[
  -- Try setting value
  local test_value = 101
  local len, base_data, nn_data = vec:get_all()
  assert(nn_data)
  local iptr = ffi.cast(qconsts.qtypes[vec:qtype()].ctype .. " *", base_data)
  status = pcall(set_value, iptr, 0, test_value)
  
  -- Above should fail, 
  -- as we are modifying materialized vector with nulls without modifying respective nn vec
  assert(status == false)
  ]]
  return true
end
--===================

return fns
