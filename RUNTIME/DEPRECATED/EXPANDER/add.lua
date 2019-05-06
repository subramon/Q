local dbg = require "debugger"
local ffi = require "ffi"
local mk_col = require 'mk_col'
local print_csv = require 'print_csv'
local ffi = require 'Q/UTILS/lua/q_ffi'
local Column = require "Column"
require 'globals'

f1f2opf3 = {}
f1f2opf3.add = "vvadd_specialize"
f1s1opf2 = {}
f1s1opf2.add = "vsadd_specialize"
-- Done doc pending: specializer must return a function and an out_ctype
-- TODO add to doc
expander_f1f2opf3 = require 'expander_f1f2opf3'

function eval(col)
    local chunk
    local size = 1 
    -- dbg()
    local chunk_num = 0 
    while size ~= 0  do
        size, chunk, nn_chunk = col:chunk(chunk_num)
        -- dbg()
        -- print("XY ", size)
        -- print("resumed")
        if size > 0  then 
            chunk_num = chunk_num + 1
            print(size, chunk, nn_chunk)
            local iter = ffi.cast("int*", chunk) -- TODO make general
            for i=1,size do 
                print(tonumber(iter[i-1]))
            end
        end
    end
end
-- function eval(vec)
--     local status = 0
--     local chunk, size
--     local i = 1
--     while status do
--         status, chunk, size = vec:chunk(i)
--         i = i + 1
--     end
-- end

function add(x, y)

    if type(x) == "Column" and type(y) == "Column" then
        local status, col = pcall(expander_f1f2opf3, "vvadd", x, y)
        if ( not status ) then print(col) end
        assert(status, "Could not execute vvadd")
        return col
    end
    if type(x) == "Column" and type(y) == "number" then
        local status, col = pcall(expander_f1s1opf2, "vsadd", x, y)
        assert(status, "Could not execute vsadd")
        return col
    end
    assert(false, "Don't know how to expand add")
end

-- local Vector = require 'Vector'
-- local Column = require "Column"
--local size = 1000
--create bin file of only ones of type int
-- local v1 = Vector{field_type='I4', filename='test.bin', }
-- local v2 = Vector{field_type='I4', filename='test.bin', }
print("hi",require'posix'.clock_gettime())
local c1 = mk_col( {1,2,3,4,5,6,7,8}, "I4")
local c2 = mk_col( {8,7,6,5,4,3,2,1}, "I4")
print("make column done", require'posix'.clock_gettime())

-- local chunk, size = v1:chunk(0)
-- for i=1, size do
--    local num = tonumber(ffi.cast("int*", chunk)[i])
--    print(num)
-- end
-- print(v1:chunk(0))
-- z =  add(add(v1,v2), v1)
z = add(c1, c2)
-- print(type(z))
eval(z)
print("eval done", require'posix'.clock_gettime())
print_csv( {z}, nil, "_foo.txt", require'posix'.clock_gettime())
