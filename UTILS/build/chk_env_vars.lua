local qconsts = require 'Q/UTILS/lua/q_consts'
local plpath  = require 'pl.path'
local function chk_env_vars()
-- START: Get and validate following environment variables
-- Q_ROOT
-- Q_BUILD_DIR
-- QC_FLAGS
-- Q_LINK_FLAGS
local q_root = qconsts.Q_ROOT
assert(q_root, "Do export Q_ROOT=/home/subramon/Q/ or some such")
final_h  = q_root .. "/include/"
final_so = q_root .. "/lib/"
local q_build_dir = qconsts.Q_BUILD_DIR
-- local dbg = require 'Q/UTILS/lua.debugger'
assert(plpath.isdir(q_build_dir), "Directory not found: " .. q_build_dir)
assert(plpath.isdir(final_h), "Directory not found: " .. final_h)
assert(plpath.isdir(final_so), "Directory not found: " .. final_so)

local QC_FLAGS = qconsts.QC_FLAGS
assert(QC_FLAGS ~= "", "QC_FLAGS not provided")

local Q_LINK_FLAGS = qconsts.Q_LINK_FLAGS
assert(Q_LINK_FLAGS ~= "", "Q_LINK_FLAGS not provided")
--
-- STOP: Get and validate needed environment variables
return final_h, final_so, q_build_dir
end
return chk_env_vars
