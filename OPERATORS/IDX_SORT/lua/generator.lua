local incdir = "../gen_inc/"
local srcdir = "../gen_src/"
local plpath = require 'pl.path'
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code = require 'Q/UTILS/lua/gen_code'

  local qconsts = require 'Q/UTILS/lua/q_consts'
  local tmpl = 'idx_qsort.tmpl'

  ordrs = { 'asc', 'dsc' }
  val_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
  idx_qtypes = { "I1", "I2", "I4", "I8" }

  for i, ordr in ipairs(ordrs) do 
    for j, val_qtype in ipairs(val_qtypes) do 
      for k, idx_qtype in ipairs(idx_qtypes) do 
        local subs = {}
        subs.fn = qsort_
        subs.srt_ordr = ordr
        subs.val_qtype = val_qtype
        subs.val_ctype = qconsts.qtypes[val_qtype].ctype
        subs.idx_qtype = idx_qtype
        subs.idx_ctype = qconsts.qtypes[idx_qtype].ctype
        subs.fn = "qsort_" .. subs.srt_ordr .. "_val_" .. 
          subs.val_qtype .. "_idx_" .. subs.idx_qtype 
        -- TODO Check below is correct order/comparator combo
        if ordr == "asc" then c = "<" end
        if ordr == "dsc" then c = ">" end
        subs.comparator = c
        --======================
        gen_code.doth(subs, tmpl, incdir)
        gen_code.dotc(subs, tmpl, srcdir)
      end
    end
  end
  print("Succesfully completed " .. arg[0])
