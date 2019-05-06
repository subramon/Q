#!/usr/bin/env lua
local tmpl = dofile 'dl_txt_to_F.tmpl'
local incdir = "../gen_inc/"
local srcdir = "../gen_src/"
local subs = {}      -- a set to collect authors
function Entry (b) 
  subs[b.qtype] = b 
end
dofile("subs_F.lua")
-- for qtype in pairs(subs) do print(qtype) end
for k, v in pairs(subs) do 
  print("Processing ", k)
  -- TODO: Can we dothis more efficiently?
  tmpl.fn = v.fn
  tmpl.out_type_displ = v.out_type_displ 
  tmpl.out_type = v.out_type 
  tmpl.big_out_type = v.big_out_type 
  tmpl.base = v.base 
  tmpl.min_val = v.min_val 
  tmpl.max_val = v.max_val 
  tmpl.converter = v.converter
  -- print(tmpl 'declaration')
  doth = tmpl 'declaration'
  local fname = incdir .. "_" .. tmpl.fn .. ".h", "w"
  local f = assert(io.open(fname, "w"))
  f:write(doth)
  f:close()
  -- print(tmpl 'definition')
  dotc = tmpl 'definition'
  local fname = srcdir .. "_" .. tmpl.fn .. ".c", "w"
  local f = assert(io.open(fname, "w"))
  f:write(dotc)
  f:close()
end
print("ALL DONE")
