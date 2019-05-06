local T = {} 
local function get_val_by_idx(x, y, optargs)
  local expander = require 'Q/OPERATORS/GET/lua/expander_get'
  local status, z = pcall(expander, "get_val_by_idx", x, y, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute [get_val_by_idx]")
  return z
end
T.get_val_by_idx = get_val_by_idx
require('Q/q_export').export('get_val_by_idx', get_val_by_idx)

local function get_idx_by_val(x, y, optargs)
  local expander = require 'Q/OPERATORS/GET/lua/expander_get'
  local status, z = pcall(expander, "get_idx_by_val", x, y, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute [get_idx_by_val]")
  return z
end
T.get_idx_by_val = get_idx_by_val
require('Q/q_export').export('get_idx_by_val', get_idx_by_val)
