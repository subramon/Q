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

local lib_link_path = string.format("-L%s/lib", Q_ROOT)
local inc_dir = Q_ROOT .. "/include/"

-- some basic checks
assert(fileops.isdir(Q_SRC_ROOT))
--================================================
local function compile(
  doth, 
  dotc, 
  hfile, 
  sofile, 
  func_name
  )
  -- START: Error checking on inputs
  assert(type(doth  ) == "string", "need a valid string for .h file")
  assert(type(dotc  ) == "string", "need a valid string for .c file")
  assert(type(hfile ) == "string", "need a valid hfile")
  assert(type(sofile) == "string", "need a valid sofile")
  --===============================
  local tmp_c = string.format("/tmp/_%s.c", func_name)
  local tmp_h = string.format("/tmp/_%s.h", func_name)
  write_to_file(dotc, tmp_c)
  write_to_file(doth, tmp_h)
  local incs = string.format("-I /tmp/ -I %s -I %s ", Q_SRC_ROOT .. "/UTILS/inc", Q_SRC_ROOT .. "/UTILS/gen_inc")
  -- TODO: What would we expect to find in Q_BUILD_DIR that we need?
  if fileops.isdir(Q_BUILD_DIR) then
    incs = string.format("%s -I %s", incs, Q_BUILD_DIR .. "/include")
  end
  -- TODO: Why do we need to link in lq_core? 
  local q_cmd = string.format("gcc %s %s %s %s %s %s -o %s", 
       QC_FLAGS, lib_link_path, tmp_c, incs, Q_LINK_FLAGS, "-lq_core",  sofile)
  local status = os.execute(q_cmd)
  assertx(status == 0, "gcc failed for command: ", q_cmd)
  assertx(fileops.isfile(sofile), "Target " ..  sofile .. " not created")
  -- TODO: Why do we need following? 
  local h_file = clean_h_file(tmp_h)
  write_to_file(h_file, hfile)
end

return compile
