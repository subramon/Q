local Q = require 'Q'
local lgutils = require 'liblgutils'
-- x must exist because we have restored session that created x 
assert(type(x) == "lVector")
local y = x
x = nil
-- now over-write x with import from first tbsp
local meta_dir_root = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/VCTR/test/Lua/meta"
local data_dir_root = os.getenv("Q_SRC_ROOT") .. "/RUNTIME/VCTR/test/Lua/data"
Q.import("first_tbsp", meta_dir_root, data_dir_root)
assert(type(x) == "lVector")

local z = Q.vvadd(y, x):eval()
local w = Q.vseq(z, 2)
local n1, n2 = Q.sum(w):eval()
assert(n1 == n2)
print("Test import 1 succeeded")
