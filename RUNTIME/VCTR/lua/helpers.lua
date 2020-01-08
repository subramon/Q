-- If not, any other string will work but do not use __ as a prefix
local ffi               = require 'ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cutils            = require 'libcutils'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local cVector		= require 'libvctr'
local register_type	= require 'Q/UTILS/lua/q_types'
local is_base_qtype	= require 'Q/UTILS/lua/is_base_qtype'
local qc		= require 'Q/UTILS/lua/q_core'
--====================================
local helpers = {}
helpers.determine_kind_of_new = function (args)
  assert(type(arg) == "table", "Vector constructor requires table as arg")
  local is_rehydrate = false
  local is_single = true
  assert(type(args) == "table")
  if ( ( #args == 2 ) and 
       ( type(arg[1]) == "table" ) and ( type(arg[2]) == "table" ) ) then
    args.has_nulls = true
    assert(type(args[2] == "table"))
    for k, v in pairs(args) do 
      if ( ( k == 1 ) or ( k == 2 ) ) then 
        assert(type(v == "table"))
      else
        error("bad args")
      end
    end
  else
    if ( args.file_name ) then 
      is_rehydrate = true; is_single = true
    end
    if ( args.file_names ) then 
      is_rehydrate = true; is_single = false
    end
  end
   --=============================
  if ( is_rehydrate == false ) then 
    if ( args.has_nulls) then 
      assert(type(args.has_nulls) == "boolean")
    else -- get from qconsts, default usually false
      args.has_nulls = qconsts.has_nulls 
    end
   --=============================
    assert(qconsts.qtypes[args.qtype], "Invalid qtype provided")
    if ( args.qtype ~= "SC" ) then 
      args.width = qconsts.qtypes[args.qtype].width
    end
   --=============================
  end
   --=============================
  return is_rehydrate, is_single
end

helpers.on_both = function(
  self,
  fn_to_apply,
  arg_to_fn
  )
  if ( arg_to_fn ~= nil ) then 
    assert(fn_to_apply(self._base_vec, arg_to_fn))
  else
    assert(fn_to_apply(self._base_vec))
  end
  if ( self._nn_vec ) then 
    if ( arg_to_fn ~= nil ) then 
      assert(fn_to_apply(self._nn_vec, arg_to_fn)) 
    else 
      assert(fn_to_apply(self._nn_vec)) 
    end
  end
  if ( qconsts.debug ) then self:check() end
  return true
end

helpers.chk_addr_len = function(x, len, chk_len)
  assert(type(x) == "CMEM")
  assert(type(len) == "number")
  assert(len > 0)
  if ( chk_len ) then
    assert(len == chk_len)
  end
end

helpers.extract_field = function(self, key, valtype)
  assert(type(key) == "string")
  assert(#key > 0)
  local casted_base_vec = ffi.cast("VEC_REC_TYPE *", self._base_vec)
  local base_val, nn_val
  --=============================
  if ( valtype == "number" ) then 
    if ( casted_base_vec[0][key]) then 
      base_val = tonumber(casted_base_vec[0][key])
    end
  elseif ( valtype == "string" ) then 
    base_val = ffi.string(casted_base_vec[0][key])
  elseif ( valtype == "boolean" ) then 
    base_val = casted_base_vec[0][key]
  else
    error("bad valtype")
  end
  --=============================
  if ( self._nn_vec ) then 
    local casted_nn_vec   = ffi.cast("VEC_REC_TYPE *", self._nn_vec)
    if ( valtype == "number" ) then 
      nn_val = tonumber(casted_base_vec[0][key])
    elseif ( valtype == "string" ) then 
      nn_val = ffi.string(casted_base_vec[0][key])
    elseif ( valtype == "boolean" ) then 
      nn_val = casted_base_vec[0][key]
    else
      error("bad valtype")
    end
  end
  return base_val, nn_val
end
helpers.mk_boolean = function(inval, default_val)
  if ( inval == nil ) then 
    assert(type(default_val) == "boolean")
    return default_val 
  end
  assert(type(inval) == "boolean")
  return inval
end

helpers.is_multiple_of_chunk_size = function(n)
  local chunk_size = cVector.chunk_size()
  if ( math.ceil(n / chunk_size ) == math.floor(n / chunk_size ) ) then
    return true
  else
    return false
  end
end

return helpers
