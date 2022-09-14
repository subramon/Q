local Q = require 'Q'
assert(type(x) == "lVector")
print("nX = ", x:num_elements())
x:pr("/tmp/_restored_x")
print("All done")
