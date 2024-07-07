local Q = require 'Q'


local saved_file_path = "dnn_in.txt"
local n_samples = 1024 * 1024

Xin = {}
Xout = {}

npl = { 16, 8, 4, 2, 1 }
dpl = { 0, 0, 0, 0, 0 }
afns = { '', 'relu', 'relu', 'relu', 'sigmoid' }
for i = 1, npl[1] do
  Xin[i] = Q.rand( { lb = -2, ub = 2, seed = 1234, qtype = "F4", len = n_samples }):eval()
end
Xout[1] = Q.convert(Q.rand( { lb = 0, ub = 2, seed = 1234, qtype = "I1", len = n_samples }), "F4"):eval()
Q.save(saved_file_path)
os.exit()
