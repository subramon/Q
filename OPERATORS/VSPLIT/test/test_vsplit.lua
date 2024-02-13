local Q = require 'Q'

local M = {}
M[#M+1] = { name = "colSC", qtype = "SC", width = 32, has_nulls = false, is_load = true}
M[#M+1] = { name = "colI2", qtype = "I2", has_nulls = true, is_load = true}
M[#M+1] = { name = "colI8", qtype = "I8", has_nulls = false, is_load = true}
M[#M+1] = { name = "colI4", qtype = "I4", has_nulls = false, is_load = false, }
M[#M+1] = { name = "colF4", qtype = "F4", has_nulls = true, is_load = true}

local F = {}
F[#F+1] = "./infile0.csv"
F[#F+1] = "./infile1.csv"
F[#F+1] = "./infile2.csv"
F[#F+1] = "./infile3.csv"

local opdir = "./"
assert(Q.vsplit(F, M, opdir))
print("Test vsplit completed")
