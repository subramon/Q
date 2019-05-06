local plfile = require 'pl.file'
local plpath = require 'pl.path'
--=======================
assert(plpath.isfile("f1s1opf2_val_specialize.tmpl"), "File not found")
local x = plfile.read("f1s1opf2_val_specialize.tmpl")
--=======================
y = string.gsub(x, "<<operator>>", "vsgeq_val")
y = string.gsub(y, "<<comparison>>", " >= " )
plfile.write("vsgeq_val_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsgt_val")
y = string.gsub(y, "<<comparison>>", " > " )
plfile.write("vsgt_val_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsleq_val")
y = string.gsub(y, "<<comparison>>", " <= " )
plfile.write("vsleq_val_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vslt_val")
y = string.gsub(y, "<<comparison>>", " < " )
plfile.write("vslt_val_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vseq_val")
y = string.gsub(y, "<<comparison>>", " == " )
plfile.write("vseq_val_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "vsneq_val")
y = string.gsub(y, "<<comparison>>", " != " )
plfile.write("vsneq_val_specialize.lua", y)
--=======================
