local Q = require 'Q'
local stringio = require 'pl.stringio'

local tests = {}

tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "i4", qtype = "I4", is_memo = false}
  M[2] = { name = "f4", qtype = "F4", is_memo = false}
  local datafile = "in1.csv"
  local T = Q.new_load_csv(datafile, M, O)
  local chunk_idx = 0
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    if ( k == "i4" ) then assert(v:fldtype() == "I4") end 
    if ( k == "f4" ) then assert(v:fldtype() == "F4") end 
  end
  repeat 
    local n 
    for k, v in pairs(T) do 
      n = v:chunk(chunk_idx)
    end
    chunk_idx = chunk_idx + 1
  until n == 0 
  --Q.print_csv(T)
  -- get length of input
  local datafile = "in1.csv"
  local num_lines = 0
  for _ in io.lines(datafile) do -- 'filename.txt' do
    num_lines = num_lines + 1
  end
  num_lines = num_lines - 1 -- because of header
  -- check length of vectors
  for k, v in pairs(T) do
    assert(v:is_eov())
    assert(v:length() == num_lines)
  end
end
--return tests
tests.t1()
