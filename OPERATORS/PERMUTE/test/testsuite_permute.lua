--local val_qtypes = {"I1", "I2", "I4", "I8", "F4", "F8"}
--local idx_qtypes = {"I1", "I2", "I4", "I8"}
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local utils = require 'Q/UTILS/lua/test_utils'

-- mk_col faltering for I2/I8 ??!!
local val_qtypes = {"I4"}
local idx_qtypes = {"I4"}

local assert_valid = function(expected)
  return function (func_res)
    local actual = utils.col_as_str(func_res)
--    print (actual)
    return actual == expected
    -- , "Expected" .. expected .. " but was " .. actual)
    -- print (func_res.vec.filename)
    -- TODO assert out_col file size  
  end
end

local create_tests = function() 
  local tests = {}
  local explode_types = function (val_tab, idx_tab, idx_in_src, expected)
    local expectedOut;
    for k1,vqt in pairs(val_qtypes) do
      for k2, iqt in pairs(idx_qtypes) do
        -- TODOexpectedOut = if/else expr did not work.. TERRA ISSUE?!
        if (vqt == 'I8') then 
          expectedOut = string.gsub(expected, ",", "LL,") 
        else         
          expectedOut = expected 
        end      
        table.insert(tests, {
          name = "succ_" .. vqt .. iqt,
          input = {mk_col(val_tab, vqt), mk_col(idx_tab, iqt), idx_in_src},
          check = assert_valid(expectedOut)
        })
      end
    end
  end  
  explode_types({10, 20, 30, 40, 50, 60}, {0, 5, 1, 4, 2, 3}, true, "10,60,20,50,30,40,")
  explode_types({10, 20, 30, 40, 50, 60}, {0, 5, 1, 4, 2, 3}, false, "10,30,50,60,40,20,")
  --print (table.tostring(tests))

  return {
    -- add any special test cases here
    {
      -- Test level setup/teardown can be specified
      -- setup = function() print ("failure setup") end,
      -- teardown = function() print ("failure teardown") end,
      name="fail_f4_ip",
      input = {
              mk_col ({10, 20, 30, 40, 50, 60}, "I4"),
              mk_col({0, 5, 1, 4, 2, 3}, "F4"),
              false},
      fail = "idx column must be integer type"
    },
    -- unpack all the other test cases here
    unpack(tests)
  }
end

local suite = {}
suite.tests = create_tests()
-- Suite level setup/teardown can be specified
suite.setup = function() 
  -- print ("in setup!!")
end
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite