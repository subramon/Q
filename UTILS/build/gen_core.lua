-- Specify script in order in which they should run
local T = {}

T[#T+1] = { dir = "/RUNTIME/COLUMN/code/src/", scripts = { "gen_files.sh" } }
T[#T+1] = { dir = "/UTILS/src/", scripts = { "gen_files.sh" } }
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/src/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/PRINT/src/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/PRINT/lua/", scripts = { "gen_files.sh" }}
return T
