#!/usr/bin/env lua

local tmpl = dofile 'qsort.tmpl'

order = { 'asc', 'dsc' }
fldtype = { "int8_t", "int16_t", "int32_t", "int64_t", "float", "double" }

for i, o in ipairs(order) do 
  for k, f in ipairs(fldtype) do 
    tmpl.SORT_ORDER = o
    tmpl.FLDTYPE = f
    tmpl.NAME = "qsort_" .. o .. "_" .. f
    -- TODO Check below is correct order/comparator combo
    if o == "asc" then c = "<" end
    if o == "dsc" then c = ">" end
    tmpl.COMPARATOR = c
    --======================
    doth = tmpl 'declaration'
    fname = "../../PRIMITIVES/inc/" .. "_" .. tmpl.NAME .. ".h" 
    local f = assert(io.open(fname, "w"))
    f:write(doth)
    f:close()
    --======================
    dotc = tmpl 'definition'
    fname = "../../PRIMITIVES/src/" .. "_" .. tmpl.NAME .. ".c" 
    local f = assert(io.open(fname, "w"))
    f:write(dotc)
    f:close()
    --======================
  end
end
