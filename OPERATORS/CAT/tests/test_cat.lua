local Q         = require 'Q'
local c_to_txt  = require 'Q/UTILS/lua/C_to_txt'
local lVector	= require 'Q/RUNTIME/VCTR/lua/lVector'
local ffi       = require 'ffi'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  -- Case1
  -- x and y size is less than chunk_size
  local x_length = 65
  local y_length = 80

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} ):set_name("x")
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} ):set_name("y")

  local z = Q.cat({x, y}, { name = "z" })
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end

tests.t2 = function()
  -- Case2
  -- x = chunk_size and y < chunk_size
  local x_length = 65536
  local y_length = 80

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} ):set_name("x")
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} ):set_name("y")

  local z = Q.cat({x, y})
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end

tests.t3 = function()
  -- Case3
  -- x < chunk_size and y = chunk_size
  local x_length = 34
  local y_length = 65536

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat({x, y})
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t4 = function()
  -- Case4
  -- x = chunk_size and y = chunk_size
  local x_length = 65536
  local y_length = 65536

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat({x, y})
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t5 = function()
  -- Case5
  -- x < chunk_size and y > chunk_size
  local x_length = 655
  local y_length = 65540

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat({x, y})
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t6 = function()
  -- Case6
  -- x > chunk_size and y = chunk_size
  local x_length = 65567
  local y_length = 65536

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat({x, y})
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end


tests.t7 = function()
  -- Case7
  -- x > chunk_size and y > chunk_size
  local x_length = 65536 * 3 + 12
  local y_length = 65536 * 7 + 133

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} )

  local z = Q.cat({x, y})
  
  assert(z:length() == (x_length + y_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end    
end

tests.t8 = function()
  -- Case8
  -- x and y are of type B1  
  local x_table = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1}
  local y_table = {1, 0, 1, 1}
  
  local x = Q.mk_col(x_table, "B1")
  local y = Q.mk_col(y_table, "B1")

  local z = Q.cat({x, y})
  
  assert(z:length() == (x:length() + y:length()))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    if not z_val then z_val = 0 end
    val = x_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    if not z_val then z_val = 0 end
    val = y_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end 
end

tests.t9 = function()
  -- Case9 -- B1
  -- x > chunk_size and y < chunk_size
  local x_length = 65535
  local y_length = 4

  local x_table = {}
  for i = 1, x_length do
    if i % 2 == 1 then
      table.insert(x_table, 1)
    else
      table.insert(x_table, 0)
    end
  end
  local y_table = {1, 1, 1, 1}
  local x = Q.mk_col(x_table, "B1")
  local y = Q.mk_col(y_table, "B1")

  local z = Q.cat({x, y})
  
  assert(z:length() == (x:length() + y:length()), "Mismatch, Expected = " .. tostring(x:length() + y:length()) .. ", Actual = " .. tostring(z:length()))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    if not z_val then z_val = 0 end
    val = x_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    if not z_val then z_val = 0 end
    print(z_val)
    val = y_table[i]
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
end

tests.t10 = function()
  -- Case10
  -- x and y with null values
  local x_length = 10
  local y_length = 10
  local nn_buf_sz = qconsts.chunk_size  -- over allocating

  local x = lVector({qtype = "I4", gen = true, has_nulls = true})
  local y = lVector({qtype = "I4", gen = true, has_nulls = true})
  
  -- Create required buffers
  local x_buf = cmem.new(qconsts.qtypes.I4.width * x_length)
  local x_buf_copy = ffi.cast(qconsts.qtypes.I4.ctype .. " *", get_ptr(x_buf))
  local y_buf = cmem.new(qconsts.qtypes.I4.width * y_length)
  local y_buf_copy = ffi.cast(qconsts.qtypes.I4.ctype .. " *", get_ptr(y_buf))
  local nn_buf = cmem.new(nn_buf_sz)
  local nn_buf_copy = ffi.cast("int8_t *", get_ptr(nn_buf))
  -- Write values to buffer
  for i = 1, x_length do
    x_buf_copy[i-1] = i
  end
  for i = 1, y_length do
    y_buf_copy[i-1] = i
  end
  for i = 1, nn_buf_sz do
    -- 85 to binary = 01010101
    nn_buf_copy[i-1] = 85
  end
  x:put_chunk(x_buf, nn_buf, x_length)
  y:put_chunk(y_buf, nn_buf, y_length)

  x:eov()
  y:eov()
  --Q.print_csv(x)
  for i = 1, x_length do
    local val, nn_val = c_to_txt(x, i)
    print(val, nn_val)
  end
  print("###############")
  --Q.print_csv(y)
  print("###############")
  local z = Q.cat({x, y})
  --Q.print_csv(z)
  assert(z:length() == (x_length + y_length))

  local z_val, z_nn_val, val, nn_val

  for i = 1, x:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(x, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
    assert(z_nn_val == nn_val, "nn value mismatch, Expected = " .. tostring(nn_val) .. ", Actual = " .. tostring(z_nn_val))
  end
  for i = 1, y:length() do
    z_val, z_nn_val = c_to_txt(z, i + x:length())
    val, nn_val = c_to_txt(y, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
    assert(z_nn_val == nn_val, "nn value mismatch, Expected = " .. tostring(nn_val) .. ", Actual = " .. tostring(z_nn_val))
  end

end

tests.t11 = function()
  -- Case11
  -- Try cat with multiple vectors

  local a_length = 65599
  local b_length = 85
  local c_length = 675
  local d_length = 65536

  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = a_length} )
  local b = Q.seq( {start = 1, by = 1, qtype = "I4", len = b_length} )
  local c = Q.seq( {start = 1, by = 1, qtype = "I4", len = c_length} )
  local d = Q.seq( {start = 1, by = 1, qtype = "I4", len = d_length} )

  local z = Q.cat({a, b, c, d})
  
  assert(z:length() == (a_length + b_length + c_length + d_length))
  
  local z_val, z_nn_val, val, nn_val
  
  for i = 1, a:length() do
    z_val, z_nn_val = c_to_txt(z, i)
    val, nn_val = c_to_txt(a, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  for i = 1, b:length() do
    z_val, z_nn_val = c_to_txt(z, i + a:length())
    val, nn_val = c_to_txt(b, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  for i = 1, c:length() do
    z_val, z_nn_val = c_to_txt(z, i + a:length() + b:length())
    val, nn_val = c_to_txt(c, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end
  for i = 1, d:length() do
    z_val, z_nn_val = c_to_txt(z, i + a:length() + b:length() + c:length())
    val, nn_val = c_to_txt(d, i)
    assert(val == z_val, "Mismatch, Expected = " .. tostring(val) .. ", Actual = " .. tostring(z_val))
  end  
end


return tests
