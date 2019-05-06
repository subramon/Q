#!/bin/bash
#These lua and C files are for calling the core C functions (i.e.the sum() function) from Lua using LuaJit FFI.
#
#The sum function supports for the following 6 types:
#1) int8_t, int16_t, int32_t, int64_t, float, double, char and
#2) uint8_t, uint16_t, uint32_t, uint64_t
#
#Compile + run instructions:
#
#1) Change the directory and make the SUM directory as currently working directory on cmd line.
#e.g.: $ cd Desktop/SUM/
#
#2) Compile the C code and create the adder.so file, the command is:
gcc -fPIC -shared -o adder.so adder.c

#3) In main.lua file Set the Path of adder.so file which you have created using step 1, as:
#e.g.: local mylib = ffi.load("<home>/Desktop/SUM/adder.so")

#4) Then run the main.lua file, the command is:
luajit main.lua

#DESCRIPTION:
#main.lua loads the adder.so, and exercises the functions with different data types. It invokes q_vagg.lua which contains a generic vagg function for numerical vector aggregation and internally uses appropriate C function.

#Trace the flow from main.lua to q_vagg.lua and refer the comments in both files to understand how luaJIT FFI is used to 
#- pass arrays (X) to C function
#- pass out-parameters (*ptr_sum) to C function
#- access the out-param's value in Lua.
