local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi = require 'ffi'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'

local function eigen(X, stand_alone_test)
  local stand_alone = stand_alone_test or false
  local soqc
  if  stand_alone_test then
    local hdr = [[
    extern int eigenvectors(
                 uint64_t n,
                 double *W,
                 double *A,
                 double **X
                );
    ]]
    ffi.cdef(hdr)
    soqc = ffi.load("../src/libeigen.so")
  end
  -- START: verify inputs
  assert(type(X) == "table", "X must be a table ")
  local m
  local qtype
  for k, v in ipairs(X) do
    assert(type(v) == "lVector", "Each element of X must be a lVector")
    -- Check the vector v for eval(), if not then call eval()
    if not v:is_eov() then
      v:eval()
    end
    if (m == nil) then
      m = v:length()
      qtype = v:fldtype()
      assert( (qtype == "F4") or ( qtype == "F8"), "only F4/F8 supported")
    else
      assert(v:length() == m, "each element of X must have the same length")
      assert(v:fldtype() == qtype)
    end
  -- Note: not checking symmetry, left to user's discretion to interpret 
  -- results if they pass in a matrix that is not symmetric
  end
  local ctype = qconsts.qtypes[qtype].ctype
  local fldsz = qconsts.qtypes[qtype].width
  assert(#X == m, "X must be a square matrix")
  -- END: verify inputs

  -- malloc space for eigenvalues (w) and eigenvectors (A)
  local wptr = assert(cmem.new(fldsz * m), "malloc failed")
  local wptr_copy = ffi.cast(ctype .. " *", get_ptr(wptr))

  local Aptr = assert(cmem.new(fldsz * m * m), "malloc failed")
  local Aptr_copy = ffi.cast(ctype .. " *", get_ptr(Aptr))

  local Xptr = assert(get_ptr(cmem.new(ffi.sizeof(ctype .. " *") * m)), 
    "malloc failed")
  Xptr = ffi.cast(ctype .. " **", Xptr)
  for xidx = 1, m do
    local x_len, xptr, nn_xptr = X[xidx]:get_all()
    assert(nn_xptr == nil, "Values cannot be nil")
    Xptr[xidx-1] = ffi.cast(ctype .. " *",  get_ptr(xptr))
  end
  local cfn = nil
  if ( stand_alone_test ) then
    cfn = soqc["eigenvectors"]
  else
    cfn = qc["eigenvectors"]
  end
  print("starting eigenvectors C function")
  assert(cfn, "C function for eigenvectors not found")
  local status = cfn(m, wptr_copy, Aptr_copy, Xptr)
  assert(status == 0, "eigenvectors could not be calculated")
  print("done with C, creating outputs")
  local E = {}
  -- for this to work, m needs to be less than q_consts.chunk_size
  for i = 1, m do
    E[i] = lVector.new({qtype = "F8", gen = true, has_nulls = false})
    E[i]:put_chunk(Aptr, nil, m)
    Aptr_copy = Aptr_copy + m
  end
  print("done with E")
  local W = lVector.new({qtype = qtype, gen = true, has_nulls = false})
  W:put_chunk(wptr, nil, m)

  return({eigenvalues = W, eigenvectors = E})

end
--return eigen
return require('Q/q_export').export('eigen', eigen)
