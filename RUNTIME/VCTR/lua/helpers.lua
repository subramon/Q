-- If not, any other string will work but do not use __ as a prefix
local ffi               = require 'ffi'
local qcfg		= require 'Q/UTILS/lua/qcfg'
local qconsts		= require 'Q/UTILS/lua/qconsts'
local cmem		= require 'libcmem'
local cVector		= require 'libvctr'
--====================================
local helpers = {}
helpers.determine_kind_of_new = function (args)
  assert(type(args) == "table", "Vector constructor requires table as arg")
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
    if ( args.vec_uqid ) then 
      is_rehydrate = true; 
    end
  end
   --=============================
  if ( is_rehydrate == false ) then 
    if ( args.has_nulls) then 
      assert(type(args.has_nulls) == "boolean")
    else -- get from qcfg, default usually false
      args.has_nulls = qcfg.has_nulls 
    end
   --=============================
    assert(qconsts.qtypes[args.qtype], "Invalid qtype provided")
    if ( args.qtype ~= "SC" ) then 
      args.width = qconsts.qtypes[args.qtype].width
    end
   --=============================
  end
   --=============================
  return is_rehydrate
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
  if ( qcfg.debug ) then self:check() end
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

local function get_val(vec, key, valtype)
  if ( not vec ) then return nil end 
  local cvec = ffi.cast("VEC_REC_TYPE *", vec)
  local val
  if ( type(cvec[0][key]) == "nil" ) then return nil end 

  if ( valtype == "number" ) then 
    val = tonumber(cvec[0][key])
  elseif ( valtype == "string" ) then 
    val = ffi.string(cvec[0][key])
  elseif ( valtype == "boolean" ) then 
    val = cvec[0][key]
  else
    error("bad valtype")
  end
  return val
end

helpers.extract_field = function(base_vec, nn_vec, key, valtype)
  assert(type(key) == "string")
  assert(type(base_vec) == "Vector")
  if ( nn_vec ) then assert(type(nn_vec) == "Vector") end 
  assert(#key > 0)
  local base_val = get_val(base_vec, key, valtype)
  local nn_val   = get_val(nn_vec,   key, valtype)
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

helpers.is_multiple_of_chunk_size = function(n, m)
  if ( n == 0 ) then return true end 
  assert(m > 0)
  if ( math.ceil(n / m ) == math.floor(n / m ) ) then
    return true
  else
    return false
  end
end

return helpers
