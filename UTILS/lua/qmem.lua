local cmem   = require 'libcmem'
local cutils = require 'libcutils'
local add_trailing_bslash = require 'Q/UTILS/lua/add_trailing_bslash'
local stringify = require 'Q/UTILS/lua/stringify'
local for_cdef = require 'Q/UTILS/lua/for_cdef'

local qmem = {}
--===========================
-- TODO  cVector qcfg.Q_DATA_DIR for data_dir
-- TODO Use cVector qcfg.chunk_size for chunk_size

qmem._cdata = cdata -- not to be modified by Lua, just pass through to C
return qmem
