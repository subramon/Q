local Q = require 'Q'

require 'Q/UTILS/lua/strict'

local M = dofile './meta_eee.lua'
local datadir = "./data/"
local niters = 1000000
local lua_niters = 10000

local tests = {}
tests.t1 = function ()
  os.execute("rm -f /home/subramon/local/Q/data/_*.bin") -- TODO FIX
  local buf, buf2
  local optargs
  local modes = {"C", "Lua"}
  for k, v in ipairs(modes) do 
    print("START Loading with ", v)
    if ( v == "C" ) then 
      optargs = { is_hdr = true }
    elseif ( v == "Lua" ) then 
      optargs = { is_hdr = true, use_accelerator = false }
    else
      assert(nil)
    end
    for i = 1, lua_niters do 
      local T_eee = Q.load_csv(datadir .. "eee_1.csv", M, optargs)
      local uuid = T_eee[1]
      assert(type(uuid) == "lVector")
      if ( ( i % 1000 ) == 1 )  then 
        print("C: Completed iter ", i)
        if not buf then 
          buf  = Q.print_csv(uuid, "", { lb = 0, ub = 10 })
        end
        assert(buf == Q.print_csv(uuid, "", { lb = 0, ub = 10 }))
      end
    end
    print("STOP  Loaded with ", v)
  end
  os.execute("rm -f /home/subramon/local/Q/data/_*.bin") -- TODO FIX
end
return tests
