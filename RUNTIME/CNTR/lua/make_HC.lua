local ffi = require 'ffi'
local stringify = require 'Q/UTILS/lua/stringify'

-- make the configs for the hashmap using optional arguments
local function make_HC(optargs, sofile)
  assert(type(sofile) == "string")
  if ( optargs ) then assert(type(optargs) == "table") end 
  local HC = ffi.new("rs_hmap_config_t[?]", 1)
  ffi.fill(HC, ffi.sizeof("rs_hmap_config_t")) -- set all to 0 
  if ( optargs ) then 
    if ( optargs.min_size ) then 
      assert(optargs.min_size == "number")
      assert(optargs.min_size > 16)
      HC[0].min_size = optargs.min_size
    end
    if ( optargs.max_size ) then 
      assert(optargs.max_size == "number")
      assert(optargs.max_size > 16)
      HC[0].max_size = optargs.max_size
    end
    assert(HC[0].min_size <= HC[0].max_size)
    if ( optargs.low_water_mark ) then 
      assert(optargs.low_water_mark == "number")
      assert(optargs.low_water_mark > 0.05)
      assert(optargs.low_water_mark < 0.50)
      HC[0].low_water_mark = optargs.low_water_mark
    end
    if ( optargs.high_water_mark ) then 
      assert(optargs.high_water_mark == "number")
      assert(optargs.high_water_mark > 0.50)
      assert(optargs.high_water_mark < 0.95)
      HC[0].high_water_mark = optargs.high_water_mark
    end
    assert(HC[0].low_water_mark <= HC[0].high_water_mark)
  end
  HC[0].so_file = stringify(sofile)
  HC[0].so_handle = ffi.NULL -- this is correct
  return HC
end
return make_HC
