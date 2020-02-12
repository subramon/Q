local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local ffi     = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'

local function corr_mat(X)
  -- X is an n by m matrix (table of lVectors)
  -- START: verify inputs
  local qtype
  assert(type(X) == "table", "X must be a table ")
  local n = nil
  for k, v in ipairs(X) do
    assert(type(v) == "lVector", "Each element of X must be a lVector")
    -- Check the vector v for eval(), if not then call eval()
    if not v:is_eov() then
      v:eval()
    end    
    if (n == nil) then
      n = v:length()
      qtype = v:fldtype()
      assert( (qtype == "F4") or (qtype == "F8"), "vectors must be F4/F8")
    else
      assert(v:length() == n, "each element of X must have the same length")
      assert(v:fldtype() == qtype, "each vector in X must have same type")
    end
  end
  local ctype = qconsts.qtypes[qtype].ctype
  local fldsz = qconsts.qtypes[qtype].width
  
  local m = #X
  -- Currently, m needs to be less than q_consts.chunk_size
  assert(m < qconsts.chunk_size) -- TODO P4 Relax above assumption
  -- END: verify inputs

  -- malloc space for the variance covariance matrix A 
  local c_Aptr = assert(cmem.new(ffi.sizeof("double *") * m))
  c_Aptr = get_ptr(c_Aptr, "double **")
  local q_Aptr = {}
  for i = 1, m do
    q_Aptr[i-1] = assert(cmem.new(ffi.sizeof("double") * m))
    c_Aptr[i-1] = get_ptr(q_Aptr[i-1], "double *")
  end

  local Xptr = assert(cmem.new(ffi.sizeof(ctype .. " *") * m))
  local Xptr = get_ptr(Xptr, ctype .. " **")
  c_Aptr[0][0] = 1
  for xidx = 1, m do
    local x_len, xptr, nn_xptr = X[xidx]:get_all()
    assert(x_len > 0)
    assert(nn_xptr == nil, "Null vector should not exist")
    Xptr[xidx-1] = get_ptr(xptr, "float *")
  end
  
  assert(qc["corr_mat"], "Symbol not found corr_mat")
  local status = qc["corr_mat"](Xptr, m, n, c_Aptr)
  assert(status == 0, "corr matrix could not be calculated")
  local CM = {}
  -- for this to work, m needs to be less than q_consts.chunk_size
  for i = 1, m do
    CM[i] = lVector.new({qtype = "F8", gen = true, has_nulls = false})
    CM[i]:put_chunk(q_Aptr[i - 1], nil, m)
    CM[i]:eov()
  end
  return CM
end
return require('Q/q_export').export('corr_mat', corr_mat)
