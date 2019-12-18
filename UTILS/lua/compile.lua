local cutils        = require 'libcutils'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local assertx       = require 'Q/UTILS/lua/assertx'
local clean_h_file  = require 'Q/UTILS/lua/clean_h_file'

local QC_FLAGS     = qconsts.QC_FLAGS
local Q_ROOT       = qconsts.Q_ROOT 
local Q_SRC_ROOT   = qconsts.Q_SRC_ROOT
local Q_BUILD_DIR  = qconsts.Q_BUILD_DIR
local Q_LINK_FLAGS = qconsts.Q_LINK_FLAGS

local lib_link_path = string.format(" -L%s/lib", Q_ROOT)
local inc_dir = Q_ROOT .. "/include/"

-- some basic checks
assert(cutils.isdir(Q_SRC_ROOT))
--================================================
local function compile(
  doth,  -- INPUT 
  dotc,  -- INPUT 
  func_name, -- INPUT
  hfile, --  created by this function
  sofile --  created by this function
  )
  -- START: Error checking on inputs
  assert(type(doth  ) == "string", "need a valid string for .h file")
  assert(type(dotc  ) == "string", "need a valid string for .c file")
  assert(type(hfile ) == "string", "need a valid hfile")
  assert(type(sofile) == "string", "need a valid sofile")
  --===============================
  local tmp_c = string.format("%s/src/_%s.c", qconsts.Q_BUILD_DIR, func_name)
  local tmp_h = string.format("%s/include/_%s.h", qconsts.Q_BUILD_DIR, func_name)
  cutils.write(tmp_c, dotc)
  cutils.write(tmp_h, doth)
  -- Following means that in dynamically generated code, you can only 
  -- include "_foo.h" in _foo.c and in _foo.h, you can only include things
  -- that will be found in UTILS/inc or UTILS/gen_inc/
  -- As an example, you CANNOT include "cmem.h"
  local incs = {}
  incs[#incs+1] = "-I" .. qconsts.Q_BUILD_DIR .. "/include/"
  incs[#incs+1] = "-I" .. qconsts.Q_SRC_ROOT  .. "/UTILS/inc/"
  incs[#incs+1] = "-I" .. qconsts.Q_SRC_ROOT  .. "/UTILS/gen_inc/"
  incs = table.concat(incs, " ")

  -- Note that in a dynamically generated function, the only functions you 
  -- can call are those that are part of static compilation i.e.,
  -- the .h file will exit in UTILS/inc or UTILS/gen_inc/ and 
  -- the symbol will be available in the minimal libq_core.so
  -- Other assumptions
  -- (1) You will not refer to any constants from another file e.g.
  -- Do not use Q_MAX_LEN_FILE_NAME which is in q_constants.h
  -- On the other hand, you can do
  -- #define MY_MAX_LEN_FILE_NAME 63
  -- (2) Any structs you create and any functions you create have
  -- unique names
  local q_cmd = string.format("gcc %s %s %s %s %s %s -o %s", 
       QC_FLAGS, lib_link_path, tmp_c, incs, Q_LINK_FLAGS, "-lq_core",  sofile)
  local status = os.execute(q_cmd)
  assertx(status == 0, "gcc failed for command: ", q_cmd)
  assertx(cutils.isfile(sofile), "Target " ..  sofile .. " not created")
  -- Now, we need to make sure .h file is in place so that when server
  -- restarts, we can pick up the .h file and .so file are present
  -- and can be loaded and we do not compile mid-way through execution
  -- No need for get_func_decl(), clean_h_file is enough because
  -- we do not need to run through cpp because (for now) no constants 
  -- to worry about
  local h_file = clean_h_file(tmp_h) 
  cutils.write(hfile, h_file)
end

return compile
