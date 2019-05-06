-- TODO REMOVE THIS FILE ??!

local q_core = require 'Q/UTILS/lua/q_core'
local ffi = require "ffi"
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local q_root = os.getenv("Q_ROOT")
local Column = require 'Q/RUNTIME/COLUMN/code/lua/Column'
assert(plpath.isdir(q_root))

local incfile = q_root .. "/include/q.h"
assert(plpath.isfile(incfile))
ffi.cdef(plfile.read(incfile))

local sofile = q_root .. "/lib/libq.so"
assert(plpath.isfile(sofile))
local cee =  ffi.load(sofile)
local q = {}
q.Column = Column
local function access(lib,symbol) return lib[symbol] end
local q_mt = {
   __newindex = function(self, key, value)
      print("newindex metamethod called")
      print(key, value)
      error("Assignment to q is not allowed")
   end,
   __index = function(self, key)
      -- Called only when the string we want to use is an
      -- entry in the table, so our variable names
      if key == "NULL" then
         return ffi.NULL
      else
         local status, val = pcall(access, cee, key)
         if status ~= false then return val end
         return q_core[key]
         -- TODO: indrajeet add q_core function if not exists
      end
   end,
}
return setmetatable(q, q_mt)
