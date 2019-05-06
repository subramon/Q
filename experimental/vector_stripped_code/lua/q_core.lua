local plpath = require 'pl.path'
local plfile = require 'pl.file'
local ffi = require 'lua/q_ffi'

local incfile = "include/q_core.h"
ffi.cdef(plfile.read(incfile))
return ffi.load('lib/libq_core.so')
