local ffi = require 'ffi'
local qc  = require 'Q/UTILS/lua/qcore'
qc.q_cdef("UTILS/inc/q_common.h")
local qconsts = {}

  local max_width = {}
  max_width["SC"] = 1024 -- 1 char reserved for nullc

  qconsts.max_width = max_width
 --===========================
  qconsts.sz_str_for_lua = 1048576 -- TODO Should be much bigger
  --===========================
  local base_types = {}
  base_types["I1"] = true;
  base_types["I2"] = true;
  base_types["I4"] = true;
  base_types["I8"] = true;
  base_types["F4"] = true;
  base_types["F8"] = true;
  qconsts.base_types = base_types
  --===========================
  -- TODO P2: Where is the following used?
  local width = {}
  width["I1"]  = 8;
  width["I2"] = 16;
  width["I4"] = 32;
  width["I8"] = 64;
  width["F4"]   = 32;
  width["F8"]  = 64;
  qconsts.width = width
  --===========================

  -- CAUTION: cenum Needs to be in sync with OPERATORS/PRINT/src/cprint.c
  local qtypes = {}
  qtypes.I1 = {
    min = -128,
    max =  127,
    max_txt_width  = 32,
    width = 1,
    ctype = "int8_t",
    ispctype = "int8",
    max_length="6",
    cenum = 1, -- used to pass qtype to C
  }
  qtypes.I2 = {
    min = -32768,
    max =  32767,
    max_txt_width  = 32,
    width = 2,
    ctype = "int16_t",
    ispctype = "int16",
    max_length="8",
    cenum = 2, -- used to pass qtype to C
  }
  qtypes.I4 = {
    min = -2147483648,
    max =  2147483647,
    max_txt_width = 32,
    width = 4,
    ctype = "int32_t",
    ispctype = "int32",
    max_length="13",
    cenum = 3, -- used to pass qtype to C
  }
  qtypes.I8 = {
    min = -9223372036854775808,
    max =  9223372036854775807,
    max_txt_width = 32,
    width = 8,
    ctype = "int64_t",
    ispctype = "int64",
    max_length="22" ,
    cenum = 4, -- used to pass qtype to C
  }
  qtypes.F4 = {
    min = -3.4 * math.pow(10,38),
    max =  3.4 * math.pow(10,38),
    max_txt_width = 32,
    width = 4,
    ctype = "float",
    ispctype = "float",
    max_length="33",
    cenum = 5, -- used to pass qtype to C
  }
  qtypes.F8 = {
    min = -1.7 * math.pow(10,308),
    max =  1.7 * math.pow(10,308),
    max_txt_width = 32,
    width = 8,
    ctype = "double",
    ispctype = "double",
    max_length="65" ,
    cenum = 6, -- used to pass qtype to C
  }
  qtypes.SC = {
    -- I don't think we need this TODO P4 width = 8,
    ctype = "char",
    cenum = 7, -- used to pass qtype to C
  }
  qtypes.TM = {
    -- no min
    -- no max
    max_txt_width = 64,
    width = ffi.sizeof("TM"),
    ctype = "struct tm",
    cenum = 8, -- used to pass qtype to C
  }
  qtypes.B1 = {
    min = 0,
    max = 1,
    max_txt_width = 8, -- TODO P4 allow true/false as input values
    width = 1, -- This has to be handled as a special case
    ctype = "uint64_t",
    cenum = 9, -- used to pass qtype to C
  }

  qconsts.qtypes = qtypes
return qconsts
