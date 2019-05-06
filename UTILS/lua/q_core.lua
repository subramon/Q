local qconsts = require 'Q/UTILS/lua/q_consts'

local Q_ROOT = qconsts.Q_ROOT 
local Q_TRACE_DIR = qconsts.Q_TRACE_DIR

-- local dbg = require 'Q/UTILS/lua/debugger'
local assertx  = require 'Q/UTILS/lua/assertx'
local compile  = require 'Q/UTILS/lua/compiler'
local ffi      = require 'Q/UTILS/lua/q_ffi'
local gen_code = require 'Q/UTILS/lua/gen_code'

local incfile  = Q_ROOT .. "/include/q_core.h"
local inc_dir  = Q_ROOT .. "/include/"
local Logger   = require 'Q/UTILS/lua/logger'
local lib_dir  = Q_ROOT .. "/lib/"
local fileops  = require 'Q/UTILS/lua/fileops'
local qconsts  = require 'Q/UTILS/lua/q_consts'

local trace_logger = Logger.new({outfile = Q_TRACE_DIR .. "/qcore.log"})
-- cdef the basic 
assertx(fileops.isfile(incfile), "File not found ", incfile)
print("XXXXX incfile = ", incfile)
ffi.cdef(fileops.read(incfile), "File problems at " .. incfile)
local qc = ffi.load('libq_core.so')
local function_lookup = {}
local qt = {}
local libs = {}

local function load_lib(hfile)
  local file = hfile
  file = file:match('[^/]*$')
  assert(#file > 0, "filename must be valid")
  local function_name, subs = file:gsub("%.h$", "")
  assertx(function_lookup[function_name] == nil,
  "Library name is already declared: ", function_name)
  assert(subs == 1, "Should have a .h extension")
  local so_name = "lib" .. function_name .. ".so"
  assert(so_name ~= "libq_core.so", "Qcore should not be loaded with load libs")

  local status, msg = pcall(ffi.cdef, fileops.read(hfile))
  if status then
    local status, q_tmp = pcall(ffi.load, so_name)
    if status then
      libs[function_name] = q_tmp
      function_lookup[function_name] = libs[function_name][function_name]
    else
      print("Unable to load lib " .. so_name, q_tmp)
    end
  else
    print("Unable to load lib " .. so_name, msg)
  end
end

----- Init Lookup ----
local function add_libs()
  local h_files = fileops.list_files_in_dir(Q_ROOT .. "/include", "*.h")
  local libs = {}
  local found_qcore = 0
  for file_id=1,#h_files do
    local str = h_files[file_id]
    if str:find("q_core.h") == nil then
      load_lib(str)
    else
      found_qcore = 1
    end
  end
  assert(found_qcore == 1, "q_core must exist in the search path")
end

local function get_qc_val(val)
  return qc[val]
end

local function q_add(doth, dotc, function_name)
  -- the lib is absent or the doth is missing compile it
  assert(function_lookup[function_name] == nil and qt[function_name] == nil,
  "Function is already registered")
  assert(doth)
  assert(dotc)
  if type(doth) == "table" then -- means this is subs and tmpl
    local subs, tmpl = doth, dotc
    assert(type(tmpl) == "string")
    doth = gen_code.doth(subs, tmpl)
    dotc = gen_code.dotc(subs, tmpl)
  end
  assert(type(dotc) == "string")
  assert(type(doth) == "string")

  local h_path = inc_dir .. function_name .. ".h"
  local so_path = lib_dir  .. "/lib" .. function_name .. ".so"
  -- print("so path", so_path)
  assert(fileops.isfile(h_path) == false or fileops.isfile(so_path) == false,
    "Libs should not exist in loadable state")
  compile(doth, h_path, dotc, so_path, function_name)
  load_lib(h_path)
  -- ffi.cdef(plfile.read(h_path))
  --  local q_tmp = ffi.load("lib" .. function_name .. ".so")

  --  function_lookup[function_name] = q_tmp

  -- function_lookup[function_name] = q_tmp[function_name]
  -- lib_table[#lib_table + 1] = q_tmp
end

local function wrap(func, name)
  if qconsts.qc_trace == false then
    return func
  end

  return function(...)
    local start_time, stop_time
    start_time = qc.RDTSC() -- posix.timer.clock_gettime(0)
    local tbl = table.pack(func(...))
    stop_time = qc.RDTSC() -- posix.timer.clock_gettime(0)
    local time =  stop_time - start_time  -- (stop_time.tv_sec*10^6 +stop_time.tv_nsec/10^3 - (start_time.tv_sec*10^6 +start_time.tv_nsec/10^3))/10^6
    trace_logger:trace(name, time)
    -- print("time taken", time)
    if tbl.n == 0 then
      return nil
    else
      return unpack(tbl)
    end
  end
end

local qc_mt = {
  __newindex = function(self, key, value)
    if qconsts.debug == true then
      rawset(self,key, wrap(value , key))
    end
  end,
  __index = function(self, key)
    -- dbg()
    if key == "q_add" then return q_add end
    local func = function_lookup[key]
    -- dbg()
    if func ~= nil then
      return wrap(func, key) -- two layers of lookup as we are caching the whole c lib
    else
      local status, fun = pcall(get_qc_val, key)
      if status == true then
        return wrap(fun, key)
      else
        return nil
      end
    end
  end
}
setmetatable(qt, qc_mt)
add_libs()
return qt

-- bogus comment
