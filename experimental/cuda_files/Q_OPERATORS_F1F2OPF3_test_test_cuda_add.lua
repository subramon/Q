local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local in1 = {}
local in2 = {}
local len = 1024 * 1024
for i = 1, len-1 do
  in1[i] = i
  in2[i] = i
end

local x = Q.mk_col(in1, "I4")
local y = Q.mk_col(in2, "I4")

local z = Q.vvadd(x, y)
z:set_name("abc")
z:eval()

-- verify
for i = 1, len-1 do
  local val, nnval = z:get_one(i-1)
  assert(val:to_num() == i*2, "Mismatch, Expected = " .. tostring(i*2) .. ", Actual = " .. tostring(val))
end
--Q.print_csv(z)

print("SUCCESS")
-- Added os.exit() to avoid the luajit error, refer email with subj "Luajit problem when running vvadd with CUDA"
--os.exit()
