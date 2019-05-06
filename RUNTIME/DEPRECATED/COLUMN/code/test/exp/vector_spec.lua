local ffi = require 'Q/UTILS/lua/q_ffi'
local Vector = require 'Q/RUNTIME/COLUMN/code/lua/Vector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local plpath = require 'pl.path'
-- for k,v in pairs(arg) do print(k,v) end
local length = tonumber(arg[4]) or 1000
local f_name, f2_name, f3_name
local v_type = "I4"
describe("Vector" , function(vector_type)
   vector_type = vector_type or v_type
      
   describe("should read from files", function()
     pending("need a valid filename")    
     pending("needs a valid type")
     pending("needs a valid length")
     pending("verify number of chunks")
   end)
   
   describe("should allow push semantics", function()
           local v1 = Vector({filename=f_name, field_type=vector_type })
           local d_type= qconsts.qtypes[v1:fldtype()].ctype

   end)
   
   describe("should allow pull semantics", function()
        local v1 = Vector({filename=f_name, field_type=vector_type })
        local d_type= qconsts.qtypes[v1:fldtype()].ctype
     describe("that gets chunks", function(chunk_num)
         chunk_num = chunk_num or 0
         local ptr, size = v1:chunk(chunk_num)
         ptr = ffi.cast(d_type .. "*" , ptr)
         ptr = ffi.cast(qconsts.qtypes[v1:fldtype()].ctype .. "*", ptr)

         it("of size in  q_consts", function()
            if v1:length() >= qconsts.chunk_size then
                 assert.True(size == qconsts.chunk_size)
            else
                 assert.True(size < qconsts.chunk_size)
                 assert.True(size == v1:length())
             end
         end)
         it("whose bytes should depdend  on the type", function()
         
         end)
         it("whose length should be independent of the type", function()
                 
         end)
        
         it("which should have correct offsets", function()
            assert.True(tonumber(ptr[size - 1]) == chunk_num * qconsts.chunk_size + size - 1 )
         end)
     end)

     describe("whose length", function()
         it("should match the file size", function() 
            local size = plpath.getsize(v1.filename)/ ffi.sizeof(d_type)
            local chunk, chunk_size = v1:chunk(-1)
            assert.True(size == chunk_size)
         end)
      end)

   end)

   setup(function(vector_type)
      -- create two binary vectors
      vector_type = vector_type or v_type
      local d_type = qconsts.qtypes[vector_type].ctype
      local v1 = Vector({field_type=vector_type, write_vector=true})
      local v2 = Vector({field_type=vector_type, write_vector=true})
      -- local f1 = ffi.C.fopen(f_name, "wb+")
      -- assert(f1 ~= ffi.NULL, "Unable to open file")

      -- local f2 = ffi.C.fopen(f2_name, "wb+")
      -- assert(f2 ~= ffi.NULL, "Unable to open file")
      -- print(d_type, ffi.sizeof(d_type))
      local ptr = ffi.cast(d_type .. "*", ffi.malloc(ffi.sizeof(d_type)) )
      for i=1,length do
          ptr[0] = i - 1
         v1:put_chunk(ptr, 1)
         -- local entries_writen = tonumber( ffi.C.fwrite(ptr, ffi.sizeof(d_type), 1, f1))
         -- assert (entries_writen == 1, "Unable to write to file f")

         ptr[0] = 9
         v2:put_chunk(ptr, 1)
         -- assert(tonumber( ffi.C.fwrite(ptr, ffi.sizeof(d_type), 1, f2)) == 1, "Unable to write to file f2")
      end
      v1:eov()
      v2:eov()
      f_name = v1.filename
      f2_name = v2.filename
      -- print(f_name, f2_name)
      -- ffi.C.fclose(f1)
      -- ffi.C.fclose(f2)
   end)

   teardown(function()
      os.remove(f_name)
      os.remove(f2_name)
   end)

end)
