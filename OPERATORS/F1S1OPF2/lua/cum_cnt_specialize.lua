local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
--[[
The input Vector * be sorted but I am deliberately not going to enforce 
that as a check. This is one of those "caveat emptor" kind of situations 
i.e., "let the buyer beware" or in this case the Q user.  It makes most 
sense to use cum_cnt when the input is sorted but I am not yet convinced 
that it is the *ONLY* case where it would be useful.

--]]

return function (
  val_qtype,
  dummy, -- to be consistent with f1s1opf2 paradigm
  optargs
  )
  local hdr = [[
typedef struct _cum_cnt_<<val_qtype>>_<<cnt_qtype>>_args {
  <<val_ctype>> prev_val;
  <<cnt_ctype>> prev_cnt;
  <<val_ctype>> max_val;
  <<cnt_ctype>> max_cnt;
} CUM_CNT_<<val_qtype>>_<<cnt_qtype>>_ARGS;
  ]]
  assert(is_base_qtype(val_qtype))

  --preamble
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/cum_cnt.tmpl"
  local subs = {}; 
  subs.val_qtype = val_qtype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  --===============
  local cnt_qtype = "I8"
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.cnt_qtype ) then 
      assert(type(optargs.cnt_qtype) == "string")
      cnt_qtype = optargs.cnt_qtype
      if ( ( cnt_qtype == "I1" ) or ( cnt_qtype == "I2" ) or
           ( cnt_qtype == "I4" ) or ( cnt_qtype == "I8" ) ) then
           -- all is well
      else
        assert(nil, "bad cnt_qtype")
      end
    elseif ( optargs.in_nR ) then
      assert(type(optargs.in_nR) == "number")
      assert(optargs.in_nR >= 1 )
      if ( optargs.in_nR <= 127 ) then
        cnt_qtype = "I8"
      elseif ( optargs.in_nR <= 32767 ) then
        cnt_qtype = "I2"
      elseif ( optargs.in_nR <= 2147483647 ) then
        cnt_qtype = "I4"
      end
    end
  end
  --===============
  local cnt_ctype = qconsts.qtypes[cnt_qtype].ctype
  local val_ctype = qconsts.qtypes[val_qtype].ctype
  hdr = string.gsub(hdr,"<<val_qtype>>", val_qtype)
  hdr = string.gsub(hdr,"<<val_ctype>>", val_ctype)
  hdr = string.gsub(hdr,"<<cnt_qtype>>", cnt_qtype)
  hdr = string.gsub(hdr,"<<cnt_ctype>>", cnt_ctype)
  pcall(ffi.cdef, hdr)
  --===============
  --TODO: is it required to introduce mem_initialize?
  -- Set args 
  local args_ctype = "CUM_CNT_" .. val_qtype .. "_" .. cnt_qtype .. "_ARGS"
  local sz_args = ffi.sizeof(args_ctype)
  local args = assert(cmem.new(sz_args), "malloc failed")
  local args_ptr = ffi.cast(args_ctype .. " *", get_ptr(args))
  args_ptr.prev_cnt  = -1;
  args_ptr.prev_val  = 0;
  subs.args = args
  subs.args_ctype = args_ctype 
  --===============
  subs.fn = "cum_cnt_" .. val_qtype .. "_" .. cnt_qtype
  subs.cnt_qtype = cnt_qtype
  subs.in_qtype  = val_qtype -- to be consistent with expander
  subs.out_qtype = cnt_qtype -- to be consistent with expander
  subs.cnt_ctype = qconsts.qtypes[subs.cnt_qtype].ctype
  return subs, tmpl
end
