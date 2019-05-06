local qconsts = require 'Q/UTILS/lua/q_consts'
local QC_FLAGS= qconsts.QC_FLAGS
local Q_ROOT = qconsts.Q_ROOT 
local q_src_root = qconsts.Q_SRC_ROOT
local q_build = qconsts.Q_BUILD_DIR
local H_DIR = Q_ROOT .. "/include/" 
local Q_LINK_FLAGS = qconsts.Q_LINK_FLAGS
local fileops = require 'Q/UTILS/lua/fileops'
local assertx = require 'Q/UTILS/lua/assertx'
-- local tmp_c, tmp_h = "/tmp/dc.c", "/tmp/dc.h"


assert(fileops.isdir(q_src_root))
local H_DIR = Q_ROOT .. "/include/" 
local Q_LINK_FLAGS = qconsts.Q_LINK_FLAGS
-- local tmp_c, tmp_h = "/tmp/dc.c", "/tmp/dc.h"


local function cleaned_h_file(h_file)
  -- local cmd = string.format([[cat %s | sed 's/\\n/\n/g'| grep -v '#include'| cpp | grep -v '^#']], h_file)
  local cmd = string.format([[cat %s | grep -v '#include'| cpp | grep -v '^#']], h_file)
  local handle = io.popen(cmd)
  local res = handle:read("*a")
  handle:close()
  return res
end

local function write_to_file(content, fname)
  local file = assertx(io.open(fname, "w+"), "unable to create ", fname)
  -- local str = content:gsub('\n', [[\n]])
  file:write(content)
  file:close()

end

local lib_link_path = string.format("-L%s/lib", Q_ROOT)
local function compile(doth, h_path, dotc, so_path, libname)
  assert(doth ~= nil and type(doth) == "string", "need a valid string that is the  dot h file")
  assert( h_path ~= nil and type(h_path) == "string", "need a valid h_path")
  assert(dotc ~= nil and type(dotc) == "string", "need a valid string that is the dot c file")
  assert(so_path ~= nil and type(so_path) == "string", "need a valid so_path")
  local tmp_c = string.format("/tmp/_%s.c", libname)
  local tmp_h = string.format("/tmp/_%s.h", libname)
  write_to_file(dotc, tmp_c)
  write_to_file(doth, tmp_h)
  local incs = string.format("-I /tmp/ -I %s -I %s ", q_src_root .. "/UTILS/inc", q_src_root .. "/UTILS/gen_inc")
  if fileops.isdir(q_build) then
    incs = string.format("%s -I %s", incs, q_build .. "/include")
  end
  local q_cmd = string.format("gcc %s %s %s %s %s %s -o %s", 
       QC_FLAGS, lib_link_path, tmp_c, incs, Q_LINK_FLAGS, "-lq_core",  so_path)
  local status = os.execute(q_cmd)
  assertx(status == 0, "gcc failed for command: ", q_cmd)
  assertx(fileops.isfile(so_path), "Target ", libname, " not created")
  local h_file = cleaned_h_file(tmp_h)
  write_to_file(h_file, h_path)
end

return compile
