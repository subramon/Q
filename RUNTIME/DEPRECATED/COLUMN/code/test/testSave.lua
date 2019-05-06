local save = require "Q/UTILS/lua/save"
local ffi = require 'Q/UTILS/lua/q_ffi'
local Vector = require 'Q/RUNTIME/COLUMN/code/lua/Vector'
local Column = require "Q/RUNTIME/COLUMN/code/lua/Column"
local qc = require 'Q/UTILS/lua/q_core'
local dictionary = require 'Q/UTILS/lua/dictionary'
-- require 'globals'
local dd = os.getenv("Q_DATA_DIR")

g_chunk_size = 16
--local size = 1000
--create bin file of only ones of type int
local v1 = Vector{field_type='I4',
filename= dd .. '/test1.txt', }
-- Not a good idea as strings will be quoted when saved and we will have to
-- deserialize them
save("vtwo", tostring(v1))
local c3 = Column{field_type='I4',
filename= dd .. '/test1.txt', }
save("cthree", tostring(c3))
local c4 = Column{field_type='I4',
filename=dd .. '/test1.txt', nn=true}
c4:set_meta("hey", 4)
c4:set_meta("bye", {1,2,3})
my_dict = dictionary("hello")
my_dict:add("please")
save("_try.txt")
for line in io.lines(os.getenv("Q_METADATA_DIR") .. "/_try.txt") do
   print(line)
end

