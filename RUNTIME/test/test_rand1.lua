local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ; 
local qconsts = require 'Q/UTILS/lua/q_consts'
local rand_qtype = require 'Q/RUNTIME/test/rand_qtype'
require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
math.randomseed(os.time())

local tests = {}
tests.t1 = function()
  local num_iters = 64
  Vector.reset_timers()
  for i = 1, num_iters do 
    local xtype = rand_qtype()
    local x = lVector( { qtype = xtype, gen = true, has_nulls = false})
    --===========================
    --[[ TODO Delete once sure not needed
    local num_elements = 64
    local width = qconsts.qtypes[xtype].width
    local bytes_to_alloc = num_elements * width
    local base_data = cmem.new(bytes_to_alloc, xtype)
    local vptr = get_ptr(base_data, xtype)
    for i = 1, num_elements do
      vptr[i] = 0
    end
    --]]
    --===========================
    local counter = 0
    local num_trials = 64
    for i = 1, num_trials do
      local qtype = rand_qtype()
      local s1 = Scalar.new(i % 127, qtype)
      if ( qtype == xtype ) then counter = counter + 1 end
      pcall(x.put1, x, s1)
      -- Note that it is okay for the pcall to fail
      -- x:put1(s1)
      assert(x:check())
    end
    x:eov()
    assert(x:check())
    assert(x:num_elements() == counter)
  end
  Vector.print_timers()
  Vector.print_mem()
  print("Completed test1")
end
return tests
