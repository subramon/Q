local qc = require 'Q/UTILS/lua/q_core'
local function record_time(
  start_time, 
  func_name
  )
  if ( _G['g_time'] ) then 
      local delta = qc.RDTSC() - start_time
      if not _G['g_time'][func_name] then
        _G['g_time'][func_name] = delta
        _G['g_ctr'][func_name]  = 1
      else
        _G['g_time'][func_name] = _G['g_time'][func_name] + delta
        _G['g_ctr'][func_name]  = _G['g_ctr'][func_name]  + 1
      end
    end
  end
return record_time
