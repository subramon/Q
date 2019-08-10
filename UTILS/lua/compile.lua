local qconsts       = require 'Q/UTILS/lua/q_consts'
local fileops       = require 'Q/UTILS/lua/fileops'
local assertx       = require 'Q/UTILS/lua/assertx'
local clean_h_file  = require 'Q/UTILS/lua/clean_h_file'
local write_to_file = require 'Q/UTILS/lua/write_to_file'

local QC_FLAGS     = qconsts.QC_FLAGS
local Q_ROOT       = qconsts.Q_ROOT 
local Q_SRC_ROOT   = qconsts.Q_SRC_ROOT
local Q_BUILD_DIR  = qconsts.Q_BUILD_DIR
local Q_LINK_FLAGS = qconsts.Q_LINK_FLAGS

local incdir       = Q_ROOT .. "/include/" 
local lib_link_path = string.format("-L%s/lib", Q_ROOT)

-- some basic checks
assert(fileops.isdir(Q_SRC_ROOT))
-- TODO What else?
--================================================
local function compile(
  doth, 
  dotc, 
  hfile, 
  sofile, 
  libname
  )
  -- START: Error checking on inputs
  assert(doth ~= nil and type(doth) == "string", "need a valid string that is the  dot h file")
  assert( hfile ~= nil and type(hfile) == "string", "need a valid hfile")
  assert(dotc ~= nil and type(dotc) == "string", "need a valid string that is the dot c file")
  assert(sofile ~= nil and type(sofile) == "string", "need a valid sofile")
  --===============================
  local tmp_c = string.format("/tmp/_%s.c", libname)
  local tmp_h = string.format("/tmp/_%s.h", libname)
  write_to_file(dotc, tmp_c)
  write_to_file(doth, tmp_h)
  local incs = string.format("-I /tmp/ -I %s -I %s ", Q_SRC_ROOT .. "/UTILS/inc", Q_SRC_ROOT .. "/UTILS/gen_inc")
  if fileops.isdir(Q_BUILD_DIR) then
    incs = string.format("%s -I %s", incs, Q_BUILD_DIR .. "/include")
  end
  local q_cmd = string.format("gcc %s %s %s %s %s %s -o %s", 
       QC_FLAGS, lib_link_path, tmp_c, incs, Q_LINK_FLAGS, "-lq_core",  sofile)
  local status = os.execute(q_cmd)
  assertx(status == 0, "gcc failed for command: ", q_cmd)
  assertx(fileops.isfile(sofile), "Target ", libname, " not created")
  local h_file = clean_h_file(tmp_h)
  write_to_file(h_file, hfile)
end

return compile
