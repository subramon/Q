local plfile = require 'pl.file'
local plpath = require 'pl.path'

assert(plpath.isfile("getk_specialize_reducer.tmpl"), "File not found")
local x = plfile.read("getk_specialize_reducer.tmpl")
--=======================
local y = string.gsub(x, "<<operator>>", "mink")
y = string.gsub(y, "<<comparator>>", "<")
plfile.write("mink_specialize_reducer.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "maxk")
y = string.gsub(y, "<<comparator>>", ">")
plfile.write("maxk_specialize_reducer.lua", y)

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

assert(plpath.isfile("getk_specialize.tmpl"), "File not found")
x = plfile.read("getk_specialize.tmpl")
--=======================
y = string.gsub(x, "<<operator>>", "mink")
y = string.gsub(y, "<<comparator>>", "<")
y = string.gsub(y, "<<operation>>", "min")
y = string.gsub(y, "<<sort_ordr>>", "asc")
plfile.write("mink_specialize.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "maxk")
y = string.gsub(y, "<<comparator>>", ">")
y = string.gsub(y, "<<operation>>", "max")
y = string.gsub(y, "<<sort_ordr>>", "dsc")
plfile.write("maxk_specialize.lua", y)

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

assert(plpath.isfile("getk_mem_initialize_reducer.tmpl"), "File not found")
local x = plfile.read("getk_mem_initialize_reducer.tmpl")
--=======================
local y = string.gsub(x, "<<operator>>", "mink")
y = string.gsub(y, "<<comparator>>", "<")
plfile.write("mink_mem_initialize_reducer.lua", y)
--=======================
y = string.gsub(x, "<<operator>>", "maxk")
y = string.gsub(y, "<<comparator>>", ">")
plfile.write("maxk_mem_initialize_reducer.lua", y)

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


print("ALL DONE")

