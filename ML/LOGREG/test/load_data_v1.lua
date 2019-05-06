require 'Q/UTILS/lua/strict'
local plpath = require 'pl.path'
local Q = require 'Q'

local function load_data_v1(
  data_file, 
  meta_file,
  optargs_file,
  goal
  )
  local optargs
  if ( optargs_file ) then 
    assert(plpath.isfile(optargs_file))
    optargs = require(optargs_file)
  end

  assert(plpath.isfile(data_file), "File not found " .. data_file)
  assert(plpath.isfile(meta_file), "File not found " .. meta_file)
  local M = require(meta_file)

  local T = Q.load_csv(data_file, M, optargs)
  local lT = {}
  local g
  local num_cols = 0
  for k, v in pairs(T) do 
    if ( k == goal ) then 
      g = v
      lT[k] = nil
    else
      num_cols = num_cols + 1 
    end
  end
  assert(g)
  assert(num_cols >= 1)
  return lT, g, num_cols
end
return load_data_v1
