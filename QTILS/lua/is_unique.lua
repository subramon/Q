-- local Q = require 'Q'
local sort = (require "Q/OPERATORS/SORT/lua/sort").vvsub

local Scalar = require 'libsclr'
local qc  = require 'Q/UTILS/lua/q_core'
local ffi = require 'ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local T = {} 
local function is_unique(x)

  assert(x and type(x) == "lVector")
  -- Ideally, you do not want execution to enter this block
  if ( x:set_meta("sort_order") ~= "asc" ) then 
    x = Q.sort(Q.duplicate(x))
  end
  local a, b =  Q.is_next_eq(x):eval()
  return a 
  --================================================
end
T.is_unique = is_unique
require('Q/q_export').export('is_unique', is_unique)
return T
