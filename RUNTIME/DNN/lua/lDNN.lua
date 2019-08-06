local ffi = require 'ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local Dnn		= require 'libdnn'
local register_type	= require 'Q/UTILS/lua/q_types'
local qc		= require 'Q/UTILS/lua/q_core'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
local get_network_structure           = 
  require 'Q/RUNTIME/DNN/lua/aux/get_network_structure'
local get_dropout_per_layer = 
  require 'Q/RUNTIME/DNN/lua/aux/get_dropout_per_layer'
local get_activation_functions = 
  require 'Q/RUNTIME/DNN/lua/aux/get_activation_functions'
local get_ptrs_to_data = 
  require 'Q/RUNTIME/DNN/lua/aux/get_ptrs_to_data'
local release_ptrs_to_data = 
  require 'Q/RUNTIME/DNN/lua/aux/release_ptrs_to_data'
local chk_data = require 'Q/RUNTIME/DNN/lua/aux/chk_data'
local set_data = require 'Q/RUNTIME/DNN/lua/aux/set_data'
--====================================
local lDNN = {}
--[[
__index metamethod tells about necessary action/provision, when a absent field is called from table.
Below line indicates, whenever any method get called using 'dnn' object (e.g "dnn:fit()"),
here 'dnn' is object/table returned from new() method, the method/key will be searched in lDNN table.
If we comment below line then the methods/fields like 'fit' or 'check' will not be available for 'dnn' object
]]
lDNN.__index = lDNN


--[[
'__call' metamethod allows you to treat a table like a function.
e.g lDNN(mode, Xin, Xout, params)
above call is similar to lDNN.new(mode, Xin, Xout, params)
for more info, please refer sam.lua in the same directory
]]
setmetatable(lDNN, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})


register_type(lDNN, "lDNN")
-- -- TODO Indrajeet to change WHAT IS THIS???? 
-- local original_type = type  -- saves `type` function
-- -- monkey patch type function
-- type = function( obj )
--    local otype = original_type( obj )
--    if  otype == "table" and getmetatable( obj ) == lDNN then
--       return "lDNN"
--    end
--    return otype
-- end


function lDNN.new(params)
  local dnn = setmetatable({}, lDNN)
  --[[ we could have written previous line as follows 
  local dnn = {}
  setmetatable(dnn, lDNN)
  --]]
  -- for meta data stored in dnn
  -- Get structure of network, # of layers and # of neurons per layer
  local nl, npl, c_npl = get_network_structure(params)
  --=========== get dropout per layer; 0 means no drop out
  local dpl, c_dpl = get_dropout_per_layer(params, nl)
  --==========================================
  local afns = get_activation_functions(params, nl)
  --==========================================
  dnn._dnn = assert(Dnn.new(nl, c_npl, c_dpl, afns))
  -- TODO: Should we maintain all the meta data on C side?
  dnn._npl    = npl   -- neurons per layer for Lua
  dnn._c_npl  = c_npl -- neurons per layer for C
  dnn._dpl    = dpl   -- dropout per layer for Lua
  dnn._c_dpl  = c_dpl -- dropout per layer for C
  dnn._nl     = nl    -- num layers
  dnn._num_epochs = 0
  if ( qconsts.debug ) then dnn:check() end
  return dnn
end


function lDNN:fit(num_epochs)
  if ( qconsts.debug ) then self:check() end
  if ( not num_epochs ) then 
     num_epochs = 1
  else 
    assert( ( type(num_epochs) == "number")  and 
           ( num_epochs >= 1 ) ) 
  end
  local dnn  = self._dnn
  local lXin = self._lXin
  local lXout = self._lXout
  local lptrs_in  = self._lptrs_in
  local lptrs_out = self._lptrs_out
  local num_instances = self._num_instances
  assert(self._bsz, "batch size not set")

  local total = 0
  for i = 1, num_epochs do
    local start_t = qc.RDTSC()
    -- TODO Need to randomly permute data before each epoch 
    local cptrs_in  = get_ptrs_to_data(lptrs_in, lXin)
    local cptrs_out = get_ptrs_to_data(lptrs_out, lXout)
    -- TODO Pass read only data to fpass and bprop
    assert(Dnn.train(dnn, lptrs_in, lptrs_out, num_instances))
    -- WRONG: assert(Dnn.bprop(dnn, lptrs_in, lptrs_out, num_instances))
    release_ptrs_to_data(lXin)
    release_ptrs_to_data(lXout)
    local end_t = qc.RDTSC()
    total = total + tonumber(end_t - start_t)
    print("Iteration " .. i .. " time = " .. tostring(tonumber(end_t - start_t)))
  end
  print("Total Training time for " .. num_epochs .. " iteation = " .. total)
  self._num_epochs = self._num_epochs + num_epochs
  if ( qconsts.debug ) then self:check() end
  return true
end


function lDNN:predict(in_table)
  local start_t = qc.RDTSC()
  if ( qconsts.debug ) then self:check() end
  assert(type(in_table) == "table")
  local n_scalars = 0
  for k, v in pairs(in_table) do
    assert(type(v) == "Scalar")
    assert(v:fldtype() == "F4")
    n_scalars = n_scalars + 1;
  end
  local dnn  = self._dnn

  -- prepare input using input scalars
  local sz = ffi.sizeof("float *") * n_scalars
  local lptrs = cmem.new(sz)
  local cptrs = get_ptr(lptrs)
  cptrs = ffi.cast("float **", cptrs)
  for k, v in pairs(in_table) do
    local data = v:to_cmem()
    cptrs[k-1] = get_ptr(data, "F4")
  end
  local end_t = qc.RDTSC()
  local set_io_t = tonumber(end_t - start_t)

  local start_t = qc.RDTSC()
  local out = assert(Dnn.test(dnn, lptrs))
  local end_t = qc.RDTSC()
  local test_t = tonumber(end_t - start_t)
  if ( qconsts.debug ) then self:check() end
  return Scalar.new(out, "F4"), test_t, set_io_t
end

function lDNN:check()
  local chk = Dnn.check(self._dnn)
  assert(chk, "Internal error")
  return true
end

function lDNN:set_io(Xin, Xout)
  if ( qconsts.debug ) then self:check() end
  local ncols_in,  nrows_in  = chk_data(Xin)
  local ncols_out, nrows_out = chk_data(Xout)
  assert(nrows_in == nrows_out)
  assert(nrows_in > 0)

  local lXin, lptrs_in   = set_data(Xin, "in")
  local lXout, lptrs_out = set_data(Xout, "out")

  local npl = self._npl
  local  nl = self._nl
  assert(ncols_in  == npl[1] )
  assert(ncols_out == npl[nl])
  assert(ncols_out == 1) -- TODO: Assumption to be relaxed

  --==========================================
  self._lXin  = lXin  -- copy of input data
  self._lXout = lXout -- copy of output data
  self._num_instances = nrows_in
  self._lptrs_in  = lptrs_in   -- C pointers to input data
  self._lptrs_out = lptrs_out  -- C pointers to output data
  if ( qconsts.debug ) then self:check() end
  return self
end

local function release_vectors(X)
  if ( X ) then 
    for _, v in ipairs(X) do
      v:delete()
    end
  end
  X  = nil
end

function lDNN:unset_io()
  release_vectors(self._lXin)
  release_vectors(self._lXout)
  self._num_instances = nil
  self._lptrs_in  = nil
  self._lptrs_out = nil
end

function lDNN:set_batch_size(bsz)
  if ( qconsts.debug ) then self:check() end
  assert( ( bsz) and ( type(bsz) == "number")  and ( bsz >= 1 ) ) 

  if ( self._bsz ) then 
    assert(Dnn.unset_bsz(self._dnn))
    self._bsz = nil
  end 
  assert(Dnn.set_bsz(self._dnn, bsz))
  self._bsz   = bsz
  if ( qconsts.debug ) then self:check() end
  return self
end

function lDNN:unset_batch_size()
  if ( qconsts.debug ) then self:check() end
  assert(Dnn.unset_bsz(self._dnn))
  self._bsz   = nil
  if ( qconsts.debug ) then self:check() end
  return self
end


function lDNN:delete()
  lDNN:unset_io()
end

return lDNN
