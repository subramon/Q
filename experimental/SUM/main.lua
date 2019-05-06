-- env-setup and test for 'q_vagg' and sum() variants

local ffi = require("ffi") --Loading the FFI library 
local mylib = ffi.load("/home/pragati/Desktop/SUM/adder.so") --set the path of your adder.so file here in ""
require 'q_vagg'

--LuaUnit (luaunit.lua) for testing results
local lu = require('luaunit')

--used for float cases
function setPrecision(sum)
    sum = sum*1000000
    sum = math.ceil(sum)
    sum = sum/1000000
    return sum
end


print("Program Started")
local mysum, status
local sum

mysum, status = vagg(mylib, {-127,100,5,-1}, "int8_t", "int16_t", "int8_sum") -- call to function in q_vagg.lua file 
--print("\nTotal is " .. mysum);
sum=-127+100+5-1
if mysum~=sum  then 
	print("FAILURE of int8_t sum") 
end 

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {3,2,5,-1}, "int16_t", "int32_t", "int16_sum")
--print("\nTotal is " .. mysum);
sum=3+2+5-1
if mysum~=sum  then 
	print("FAILURE of int16_t sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {-38457,2,5,-1}, "int32_t", "int64_t", "int32_sum")
--print("\nTotal is " .. mysum);
sum=-38457+2+5-1
if mysum~=sum  then 
	print("FAILURE of int32_t sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {-38788778,2,5,-1}, "int64_t", "int64_t", "int64_sum")
--print("\nTotal is " .. mysum);
sum=-38788778+2+5-1
if mysum~=sum  then 
	print("FAILURE of int64_t sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {127,127,127}, "uint8_t", "uint16_t", "uint8_sum")
--print("\nTotal is " .. mysum);
sum=127+127+127
if mysum~=sum  then 
	print("FAILURE of uint8_t sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {32767,32767}, "uint16_t", "uint32_t", "uint16_sum")
--print("\nTotal is " .. mysum);
sum=32767+32767
if mysum~=sum  then 
	print("FAILURE of uint16_t sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {2147483647,2147483642,4}, "uint32_t", "uint64_t", "uint32_sum")
--print("\nTotal is " .. mysum);
sum=2147483647+2147483642+4
if mysum~=sum  then 
	print("FAILURE of uint32_t sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {2147483647,2147483647}, "uint64_t", "uint64_t", "uint64_sum")
--print("\nTotal is " .. mysum);
sum=2147483647+2147483647

if mysum~=sum  then 
	print("Test case 1: FAILURE of uint64_t sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {1099511627776,1099511627776}, "uint64_t", "uint64_t", "uint64_sum")
--print("\nTotal is " .. mysum);
sum=1099511627776+1099511627776

if mysum~=sum  then
        print("Test case 2: FAILURE of uint64_t sum")
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {3.275412,2.275421,3.275412}, "float", "float", "float_sum")
--print("\nTotal is " .. mysum);
sum=3.275412+2.275421+3.275412
mysum = setPrecision(mysum)

if mysum~=sum  then 
	print("FAILURE of float sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {3.27541212342,2.27541212342,3.27541212342}, "double", "double", "double_sum")
--print("\nTotal is " .. mysum);
sum=3.27541212342+2.27541212342+3.27541212342
mysum = setPrecision(mysum)
sum = setPrecision(sum)

if mysum~=sum  then 
	print("FAILURE of double sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


mysum, status = vagg(mylib, {65,6,9}, "char", "char", "char_sum")
--print("\nTotal is " .. mysum);
sum=65+6+9
if mysum~=sum  then 
	print("FAILURE of char sum") 
end

lu.assertEquals( mysum, sum ) --testing the results


print("Bye!")
