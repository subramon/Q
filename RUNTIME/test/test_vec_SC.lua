local plpath = require 'pl.path'
local plfile = require 'pl.file'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem   = require 'libcmem' ;
local qconsts = require 'Q/UTILS/lua/q_consts'

require 'Q/UTILS/lua/strict'

local tests = {} 

tests.t1 = function()
  local y
  local M
  local num_elements 
  local s1, s2
  local buf = cmem.new(4096, "SC", "string buffer")
  local dir = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/test/"
  assert(plpath.isdir(dir))
  buf:set("ABCD123")
  -- create a nascent vector
  y = assert(Vector.new('SC:8', qconsts.Q_DATA_DIR))
  num_elements = 10
  for j = 1, num_elements do 
    assert(y:put1(buf))
  end
  y:eov()
  y:persist()
  assert(y:check())
  M = loadstring(y:meta())(); 
  local command = "od -c -v " .. M.file_name .. " > /tmp/_temp1.txt"
  os.execute(command)
  s1 = plfile.read("/tmp/_temp1.txt")
  local goodfile = dir .. "out_SC1.txt"
  assert(plpath.isfile(goodfile))
  s2 = plfile.read(goodfile)
  assert(s1 == s2)
  --=========================
  -- print("Testing SC Vector from file")
  local original_infile = dir .. 'SC2.bin'
  assert(plpath.isfile(original_infile), "ERROR: Create the input files")
  local infile = "/tmp/_SC2.bin"
  plfile.copy(original_infile, infile)
  y = assert(Vector.new('SC:8', qconsts.Q_DATA_DIR, infile, false))
  local ret_addr, ret_len = y:get_chunk(0);
  assert(ret_addr)
  assert(type(ret_addr) == "CMEM")
  assert(ret_len == 10)
  print("Successfully completed test t1")
end
--=========================
return tests
