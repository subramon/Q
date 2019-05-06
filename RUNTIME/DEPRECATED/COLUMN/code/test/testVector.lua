local save = require "Q/UTILS/lua/save"
local dd = os.getenv("Q_DATA_DIR")
-- local dbg = require "debugger"
local ffi = require 'Q/UTILS/lua/q_ffi'
local qc = require 'Q/UTILS/lua/q_core'
local print_vector = function(ptr , len)
   for i=1,len do
   print( tonumber(ffi.cast("int*", ptr)[i-1]))
   end
end

-- local Generator = require "Generator"
local Vector = require 'Q/RUNTIME/COLUMN/code/lua/Vector'
local Column = require "Q/RUNTIME/COLUMN/code/lua/Column"
-- require 'Q/UTILS/lua/globals'
-- g_chunk_size = 16
--local size = 1000
--create bin file of only ones of type int
local v1 = Vector{field_type='I4',
filename=dd .. '/test1.txt', }
local v2 = Vector{field_type='I4',
filename=dd .. '/test1.txt', }
local x, x_size = v1:chunk(0)
print_vector(x, x_size)
local y, y_size = v2:chunk(1)
print_vector(y, y_size)
-- local v1_gen = Generator{vec=v1}
-- local i = 0
-- while(v1_gen:status() ~= 'dead')
-- do
--     local status, chunk, size = v1_gen:get_next_chunk()
--     if status then
--         print("Generator chunk number=".. i, "Generator status=" .. tostring(status), "Chunk size=" .. size)
--         print_vector(chunk, size)
--     else 
--         print("Generator chunk number=".. i, "Generator status=" .. tostring(status))
--     end
--     i = i +1
-- end

--TODO add tests for put to vector
local v3 = Vector{field_type='I4',
filename=dd .. "/o.txt", write_vector=true, 
}
v3:put_chunk(x, x_size)
v3:eov()


local z, z_size = v3:chunk(0)
print_vector(z, z_size)

--[[ INDRAJEET TODO
local v4 = Vector{field_type='B1', filename="test_bits.txt", field_size=1/8}
for i=0,15 do
 print(v4:get_element(i), tonumber(ffi.cast("int*", a_int) + i))
end
--]]

local a, a_size = z, z_size
print("Vector bit get test")
local a_int = ffi.malloc(ffi.sizeof("int")* a_size)
qc.get_bits_from_array(a, a_int, a_size)
local t2 = Vector{field_type='I4', write_vector=true}
t2:put_chunk(a_int, a_size)
t2:eov()
print "**************"
print_vector(a_int, a_size)
-- add function to print bits:b2
v5 = Column{field_type='I4',
filename= dd .. "/o2.txt", write_vector=true,
 }
 v5:put_chunk(x_size, x )
v5:eov()
t1 = Vector{filename= dd .. "/t1.txt", field_type="B1", write_vector=true}
t1:put_chunk(a,x_size)
t1:eov()

v6 = Column{field_type='I4',
filename=dd .. "/o3.txt", write_vector=true, nn=true
 }
assert(v6.nn_vec ~= nil , "has an nn vector")
v6:put_chunk(x_size, x, a )
v6:eov()
q_size, q, q_nn = v6:chunk(0)
print_vector(q, q_size)
local q_int = ffi.cast( "int*", ffi.malloc(ffi.sizeof("int")* q_size) )
qc.get_bits_from_array(q_nn, q_int, q_size)
print "**************"
print_vector(q_int, q_size)

print "**************"
print_vector(a_int, a_size)
print( v1:length())

print(q_int[0])
print(v6:get_element(1))

print "**"
print(q_int[0])
print(q_int[1])
print(q_int[3])
print(q_int[5])
print "**"
print(v6:get_element(0))
print(v6:get_element(1))
print(v6:get_element(3))
print(v6:get_element(5))
print "**************"
V7 = Vector{field_type='B1', filename=dd .. "/o7.txt", write_vector=true}
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 1)
V7:put_chunk(a, 2)


V7:eov()
-- Column generator
local gen = v6:wrap()
local c8 = Column{field_type='I4', gen=gen}
q_size, q, q_nn = c8:chunk(0)
print(q_size)

local c9_gen = Column{field_type='I4',
filename= dd .. '/test1.txt', }:wrap()

local c10 = Column{field_type='I4', gen=c9_gen}
local i = 0 
while c10:materialized() == false do
   q_size, q, q_nn = c10:chunk(i)
   print(i, q_size)
   i = i+ 1 
   for j=1,q_size do 
      print(tonumber(ffi.cast("int*", q)[j-1]))
   end
end
local c11_gen = Column{field_type='I4',
filename= dd ..'/test1.txt', }:wrap()


c11 = Column{field_type='I4', gen=c11_gen}
save("_try2.txt")
-- q_size, q, q_nn = c8:chunk(1)
-- print(q_size)

