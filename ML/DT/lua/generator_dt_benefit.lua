local plpath = require 'pl.path'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code =  require("Q/UTILS/lua/gen_code")

-- Note this cdef hackery needed to keep this independent of Q
-- If we had done local Q = require 'Q', would not have been needed
-- Down side is that if CMEM changes, this better change
-- TODO Use penlight to get CMEM_REC_TYPE here automatically
local ffi = require 'ffi'
ffi.cdef([[

typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  int width;
  char fldtype[3+1]; 
  char cast_as[63+1];  // wip 
  char cell_name[31+1]; 
  bool is_foreign; // true => do not delete 
  bool is_stealable; // true => data can be stolen
} CMEM_REC_TYPE;
]])

ftypes = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
gtypes = { 'I4' } 

local sp_fn = require 'Q/ML/DT/lua/dt_benefit_specialize'
local num_produced = 0

local metric_name = "gambling"
local min_size = 2
local wt_prior = 1
local n_T = 2
local n_H = 2
for _, ftype in ipairs(ftypes) do
  for _, gtype in ipairs(gtypes) do
    local status, subs = pcall(sp_fn, ftype, gtype,
      metric_name, min_size, wt_prior, n_T, n_H)
    if ( status ) then
      gen_code.doth(subs, incdir)
      gen_code.dotc(subs, srcdir)
      print("Generated ", subs.fn)
      num_produced = num_produced + 1
    else
      print(subs)
    end
  end
end
assert(num_produced > 0)
