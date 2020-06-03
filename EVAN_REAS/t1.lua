require 'Q/UTILS/lua/strict'
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
local plutils= require 'pl.utils'

local infile = assert(arg[1])
assert(plpath.isfile(infile))
-- define meta data
local M = {}
local O = { is_hdr = true }
for i = 1, 13 do 
  local name = x .. tostring(i)
  M[i] = { name = name, qtype = "F4", is_memo = true, has_nulls = false}
end:w

