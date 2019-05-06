local ffi = require("ffi")


-- see if the file exists
function file_exists(file)
   local f = io.open(file, "rb")
   if f then f:close() end
   return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
   if not file_exists(file) then return {} end
   lines = {}
   for line in io.lines(file) do
      lines[#lines + 1] = line
   end
   return lines
end

local compileFile = function( file, libName)
   os.execute("gcc -c -std=c99 -fPIC " .. file .. " -o tmp")
   os.execute ("gcc tmp -shared -o " .. libName)
end

function add(a,b)
   ffi.C.add(a, b)
end

local parseFile = function(retType, type1, type2, fileIn, fileOut)
   print (fileOut)

   os.execute(" python test.py RET=" .. retType .. " TYPE1=" .. type1 .. " TYPE2=" .. type2 .. " " .. fileIn .. " " ..fileOut)
end

local load_c_ffi = function(libName , retType, type1, type2) 
   local ffi  = require("ffi")
   -- RET * add(TYPE1* A, TYPE2* B, RET* C, int length, int nb, int blk_size)
   ffi.cdef ( " int add(" .. type1 .. "* A, " .. type2 .. "* B, int length, int blk_size)")
   local c = ffi.load(fldr .. "libtestfin.so")
   return c
end

local mallocAsQTable = function(size)
   local ffi = require 'ffi'
    local C = ffi.C
    ffi.cdef([[
        void * malloc(size_t size);
        void free(void *ptr);
    ]])
     local ptr = C.malloc( size )
     io.stdout:write(tostring(ptr), '\n')
     io.stdout:write(type(ptr), '\n')
     local qTable = {}
     qTable.size = size
     qTable.ptr = ptr
     return qTable
end

local addTwoVectors = function(vec1, vec2, vecres)
   if vec1 == nil or vec2 == nil or vecres == nil then error("Vector is empty" ,2 ) end
   local ffi  = require("ffi")
   ffi.cdef ( "int add(" .. vec1.dataType .. "* A, " .. vec2.dataType .. "* B, " .. vecres.dataType .. "* C, int length, int blk_size);")
   ffi.cdef ("int initA(" .. vec1.dataType .. "*A, int length);")
   ffi.cdef ("int initB(" .. vec2.dataType .. "*B, int length);")
   ffi.cdef ("int writeOut(" .. vecres.dataType .. "*C, int length);")
   local C = ffi.load(fldr .. "libtestfin.so")
   local res = C.initA(vec1.ptr, vec1.size)
   local res = C.initB(vec2.ptr, vec2.size)
   local res = C.add(vec1.ptr, vec2.ptr, vecres.ptr, vec1.size, 64) -- right now assuming everything is 4 bytes
   print ("My return code is " .. res)
   C.writeOut(vecres.ptr, vecres.size)
end


local addTwoTables = function(table1, table2, tableres)
      if table1.size ~= table2.size or table1.size ~= tableres.size then error("Expected same size Qtables", 2) end

      if table1.dataType == nil or table2.dataType == nil or tableres.dataType == nil then 
         error("Expected data types to calculate length", 2) 
      end
      parseFile(tableres.dataType, table1.dataType, table2.dataType, fldr .. "test.c", fldr .. "testfin.c")
      compileFile(fldr .. "testfin.c", fldr .. "libtestfin.so")
      addTwoVectors(table1, table2, tableres)
end

fldr = "/home/srinath/Ramesh/Q/experimental/c_files/"
A = mallocAsQTable(4000)
A.dataType = "int"
B = mallocAsQTable(4000)
B.dataType = "int"
C = mallocAsQTable(4000)
C.dataType = "int"
addTwoTables(A, B, C)