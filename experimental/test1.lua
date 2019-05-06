g_bitlen = {}
g_bitlen["int8_t"]  = 8;
g_bitlen["int16_t"] = 16;
g_bitlen["int32_t"] = 32;
g_bitlen["int64_t"] = 64;
g_bitlen["float"]   = 32;
g_bitlen["double"]  = 64;

function mk_data(sz)
  -- here is where we create space for data (malloc, mmap,...)
  return 1
end
function get_data(f)
  -- here is where we get pointer to data (malloc, mmap, ...)
  return 1
end
function is_fld(x)
  if ( type(x) ~= "table") then 
     error("vector expected. Got " .. type(x))
     return false
   end
   return true
 end

function  get_otype_f1f2opf3(v, f1type, f2type)
   return v[f1type .. "," .. f2type] 
end


function concat_checker(f1, f2, outtype)
  -- create table of valid mappings
  local t_v = { } -- t_v denotes valid keys and their values
  t_v["int32_t,int32_t" ] = "int64_t"
  t_v["int16_t,int32_t" ] = "int64_t"
  t_v["int16_t,int16_t" ] = "int32_t"

  local fn = "concat" 
  if not ( is_fld(f1) and is_fld(f2) ) then 
    error("concat requires arguments to be vectors");
  end
  if f1.len ~= f2.len  then 
    error("concat requires vector lengths to be equal");
  end
  l_outtype = get_otype_f1f2opf3(t_v, f1.fldtype, f2.fldtype)
  assert(l_outtype, "Some good error messasge")
  local shift = g_bitlen[f2.fldtype]
  --[[
  if not ( ( f1.fldtype == "int8_t" ) or 
     ( f1.fldtype == "int16_t" ) or 
     ( f1.fldtype == "int32_t" ) ) then
     error("concat requires fldtype to be I1/I2/I4")
  end
  if not ( ( f2.fldtype == "int8_t" ) or 
     ( f2.fldtype == "int16_t" ) or 
     ( f2.fldtype == "int32_t" ) ) then
     error("concat requires fldtype to be I1/I2/I4")
  end
  local l_outtype = ""
  if ( f1.fldtype == "int32_t" ) then 
     l_outtype = "int64_t"
  elseif( f1.fldtype == "int16_t" ) then 
    if ( f2.fldtype == "int32_t" ) then
      l_outtype = "int64_t"
    elseif( f2.fldtype == "int16_t" ) then
      l_outtype = "int32_t"
    elseif( f2.fldtype == "int8_t" ) then
      l_outtype = "int32_t"
    end
  elseif( f1.fldtype == "int8_t" ) then 
    if ( f2.fldtype == "int32_t" ) then
      l_outtype = "int64_t"
    elseif( f2.fldtype == "int16_t" ) then
      l_outtype = "int32_t"
    elseif( f2.fldtype == "int8_t" ) then
      l_outtype = "int16_t"
    end
  end
  --]]
  if ( outtype ~= nil ) then 
    if ( g_bitlen[outtype] >= g_bitlen[l_outtype] ) then
      l_outtype = outtype
    else
      error("specified output type is not big enough")
    end
  end
  fn = "concat_" .. f1.fldtype .. "_" .. f2.fldtype .. "_" .. l_outtype 
  scalar_op = " ( A << " .. shift .. " ) | B "
  includes = {"math", "curl/curl" }
  return fn, f1.fldtype, f2.fldtype, l_outtype, scalar_op, includes
end

function f1f2opf3_expander(
  checker_fn,
  f1,
  f2, 
  outtype
  )
  local fn, itype1, itype2, l_outtype, scalar_op, includes = 
  checker_fn(f1, f2, outtype)

  x = ""
  for i, v in ipairs(includes) do 
    x = x .. "#include <" .. v .. ".h> \n"
  end

local  nR = f1.len
  -- generate the C code
local t = {}
table.insert(t, "#include <stdio.h>")
table.insert(t, "#include <inttypes.h>")
table.insert(t, "#define ITYPE1 " .. f1.fldtype )
table.insert(t, "#define ITYPE2 " .. f2.fldtype )
table.insert(t, "#define OTYPE1 " .. l_outtype )
table.insert(t, "#define SOP(A,B) " .. scalar_op )
table.insert(t, "#include \"mcr_f1f2opf3.h\"")
table.insert(t, "int " .. fn .. "(ITYPE1 *A, ITYPE2 * B, uint64_t nR, OTYPE1 *C) { ")
table.insert(t,  " mcr_f1f2opf3(SOP(A[aidx], B[bidx]), " .. nR .. ") } ")
local s = table.concat(t, "\n") .. "\n"
print(s)
-- compile, created .so and got dyncall to link the .so
-- local libhandle = dc.load("foo.so")
local f = dc.find(libhandle, fn)
dc.mode(dc.C_DEFAULT)
f1data = get_data(f1)
f2data = get_data(f2)
f3data = C.ffi.mk_data(nR * sizeof(l_outtype))
local t = dc.call(f, "i*i*ll*)i", f1, f2, nR, f3)
f3 = {}
f3.len = nR
f3.data = f3data
f3.fldtype = l_outtype
return f3


end
-- f3 = concat(f1, f2, outtype)
function concat(f1, f2, outtype)
expander("f1f2opf3", "concat", ...)
end

function expander(dataflow, operator, f1, f2, outtype)
  local expander_fn = dataflow .. "_expander"
  local checker_fn  = operator .. "_checker"
  expander_fn(checker_fn, f1, f2, outtype)

end

f1 = {}
f2 = {}
f1.fldtype = "int32_t"
f2.fldtype = "int32_t"
f1.len = 100
f2.len = 100
outtype = nil

concat(f1, f2, outtype) -- real call 

-- TO DISCUSS 
-- P3 think about usage of conventions, good and bad 
-- P4 make includes more general 
-- P1 eliminate need to write concat function at all . Could it have been
-- auto-generated?? Think about optional arguments e.g., s_to_f has 
-- random in which case kind of distribution, bounds, algorithm, seed, ..
--
-- conventions
--  1) must exist a file called mcr_<dataflow>.h
--  2) must exist a function called <dataflow>_expander
--  3) must exist a function called <operator>_checker
--  4) scalar_op assumes arguments are A, B, C, ....
--  5) There is a Lua Table for 
--    (column 1) operator (column 2) dataflow
--  5) There is a Lua Table for 
--    (column 1) dataflow (column 2) signature e.g.
--    f1f2opf3 (f1, f2, outtype)
