local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
require 'Q/UTILS/lua/strict'

local tests = {} 
tests.t1 = function()
  -- tests that memory is zero after Vector created, non-zeor after 
  -- put happens and zero again after Vector is deleted
  local mem = 0
  local qtype = 'I4'
  local y = Vector.new(qtype, qconsts.Q_DATA_DIR)
  local s = Scalar.new(123, qtype)
  mem = Vector.print_mem()
  print(mem)
  assert(mem == 0)
  local status = y:put1(s)
  mem = Vector.print_mem()
  assert(mem == qconsts.chunk_size * qconsts.qtypes[qtype].width)
  status = y:eov(true)
  y:delete()
  mem = Vector.print_mem()
  assert(mem == 0)
  print("Successfully completed test t1")
end
--==============================================
return tests
