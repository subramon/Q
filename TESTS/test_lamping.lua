-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
--[[

gather does the following

Input:
L        A       G       C       T
x1      1       2       3       4
x2      4       3       2       1
x3      1       0       0       3

Output:

X1 A 1
X1 G 2
X1 C 3
X1 T 4

X2 A 4
X2 G 3
X2 C 2
X2 T 1

X3 A 1
X3 G 0
X3 C 0
X3 T 3

--=================================================

P.S. Here is an example of how to use tidyr and dplyr functions. Suppose you take your input and want to know how many times each base occurs exactly once. Assuming I haven't made a mistake, the R for that is:

IN above example, asnwer is
A 2
G 0
C 0
T 1

starting %>%
  gather(base, count, A, G, C, T) %>%
  filter(count == 1) %>%
  group_by(base) %>%
  summarize(count = n())
--]]


local tests = {}
tests.t1 = function ()
  -- TODO Create some data for agct
  local datadir = os.getenv("Q_SRC_ROOT") .. "/TESTS/"
  local M = dofile(datadir .. "meta_data_lamping.lua")
  local agct = Q.load_csv(datadir .."agct.csv", M, { is_hdr = true, use_accelerator = false})
  for k, v in pairs(agct) do 
    --print(k, Q.sum(Q.vseq(v, 1)):eval())
  end
end
return tests
