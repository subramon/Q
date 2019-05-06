local Q               = require 'Q'
local synth_data = require 'Q/MULTI_DIM/lua/synth_data'
local load_data = require 'Q/MULTI_DIM/lua/load_data'

local function load()
  local is_synth = true
  if ( is_synth ) then 
    T, M = synth_data()
  else
    T, M = load_data()
  end
  return T, M
end
return load
