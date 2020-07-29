--[[
  q_consts will be a place where all constants are defined
  it also includes all environment variables as well
  Functions that require access to these constants should have
  require 'Q/UTILS/lua/q_consts'
]]

local function add_trailing_bslash(x)
  assert(type(x) == "string")
  assert(#x > 1)
  if ( string.sub(x, #x, #x) ~= "/" ) then
    x = x .. "/"
  end
  return x
end

local ffi = require 'ffi'
ffi.cdef([[
typedef struct tm
{
  int tm_sec;			/* Seconds.	[0-60] (1 leap second) */
  int tm_min;			/* Minutes.	[0-59] */
  int tm_hour;			/* Hours.	[0-23] */
  int tm_mday;			/* Day.		[1-31] */
  int tm_mon;			/* Month.	[0-11] */
  int tm_year;			/* Year	- 1900.  */
  int tm_wday;			/* Day of week.	[0-6] */
  int tm_yday;			/* Days in year.[0-365]	*/
  int tm_isdst;			/* DST.		[-1/0/1]*/

  long int __tm_gmtoff;		/* Seconds east of UTC.  */
  const char *__tm_zone;	/* Timezone abbreviation.  */
} TM ; // NOTE: I gave a name TM to the struct tm because LuaFFI complained
   ]])
local qconsts = {}
--===========================
  -- Initialize environment variable constants
  -- Note: These are Environment variable constants, if modified in same lua environment
  -- would not modify the value of these environment variable constants
  qconsts.Q_SRC_ROOT	= add_trailing_bslash(os.getenv("Q_SRC_ROOT"))
  qconsts.Q_ROOT	= add_trailing_bslash(os.getenv("Q_ROOT"))
  if ( not os.getenv("QC_FLAGS") ) then
    qconsts.QC_FLAGS = [[
-g -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align
-Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings
-Wunused-variable -Wunused-parameter -Wno-pedantic
-fopenmp -mavx2 -mfma -Wno-unused-label
-fsanitize=address -fno-omit-frame-pointer
-fsanitize=undefined
-Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith
-Wmissing-declarations -Wredundant-decls -Wnested-externs
-Wshadow -Wcast-qual -Wcast-align -Wwrite-strings
-Wold-style-definition
-Wsuggest-attribute=noreturn
-Wduplicated-cond -Wmisleading-indentation -Wnull-dereference
-Wduplicated-branches -Wrestrict
    ]]
  else
    qconsts.QC_FLAGS	= os.getenv("QC_FLAGS")
  end
  qconsts.Q_LINK_FLAGS	= os.getenv("Q_LINK_FLAGS")
  qconsts.LD_LIBRARY_PATH = os.getenv("LD_LIBRARY_PATH")

  -- Use cVector qconsts.Q_DATA_DIR for data_dir
  -- Use cVector qconsts.chunk_size for chunk_size
--=================================

  qconsts.debug = true -- set to TRUE only if you want debugging
  qconsts.is_memo = true -- Vector code uses this default value
  qconsts.has_nulls = false -- Vector code uses this default value
  qconsts.qc_trace = false -- set to FALSE if performance logging of qc is to be turned off
  local max_width = {}
  max_width["SC"] = 1024 -- 1 char reserved for nullc

  -- Commenting 'max_len_file_name' field as it is not required on lua side
  -- On C side, it is present in q_constants.h
  -- qconsts.max_len_file_name = 255 -- TODO keep in sync with C
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
  local iorf = {}
  iorf["I1"]  = "fixed";
  iorf["I2"] = "fixed";
  iorf["I4"] = "fixed";
  iorf["I8"] = "fixed";
  iorf["F4"] = "floating_point";
  iorf["F8"] =  "floating_point";
  qconsts.iorf = iorf
  --===========================

  -- CAUTION: cenum Needs to be in sync with OPERATORS/PRINT/src/cprint.c
  local qtypes = {}
  qtypes.I1 = {
    min = -128,
    max =  127,
    max_txt_width  = 32,
    width = 1,
    ctype = "int8_t",
    max_length="6",
    cenum = 1, -- used to pass qtype to C
  }
  qtypes.I2 = {
    min = -32768,
    max =  32767,
    max_txt_width  = 32,
    width = 2,
    ctype = "int16_t",
    max_length="8",
    cenum = 2, -- used to pass qtype to C
  }
  qtypes.I4 = {
    min = -2147483648,
    max =  2147483647,
    max_txt_width = 32,
    width = 4,
    ctype = "int32_t",
    max_length="13",
    cenum = 3, -- used to pass qtype to C
  }
  qtypes.I8 = {
    min = -9223372036854775808,
    max =  9223372036854775807,
    max_txt_width = 32,
    width = 8,
    ctype = "int64_t",
    max_length="22" ,
    cenum = 4, -- used to pass qtype to C
  }
  qtypes.F4 = {
    min = -3.4 * math.pow(10,38),
    max =  3.4 * math.pow(10,38),
    max_txt_width = 32,
    width = 4,
    ctype = "float",
    max_length="33",
    cenum = 5, -- used to pass qtype to C
  }
  qtypes.F8 = {
    min = -1.7 * math.pow(10,308),
    max =  1.7 * math.pow(10,308),
    max_txt_width = 32,
    width = 8,
    ctype = "double",
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
