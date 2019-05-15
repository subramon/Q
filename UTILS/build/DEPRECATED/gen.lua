-- Specify script in order in which they should run
local T = {}
T[#T+1] = { dir = "/RUNTIME/COLUMN/code/src/", scripts = { "gen_files.sh" } }
T[#T+1] = { dir = "/UTILS/src/", scripts = { "gen_files.sh" } }
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/src/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/F1F2OPF3/lua/", scripts = { "make clean && make" }}
T[#T+1] = { dir = "/OPERATORS/F1F2OPF3/lua/", scripts = { "pkg_f1f2opf3.lua" }}
T[#T+1] = { dir = "/OPERATORS/F1S1OPF2/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/F1S1OPF2/lua/", scripts = { "pkg_f1s1opf2.lua" }}
T[#T+1] = { dir = "/OPERATORS/PRINT/src/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/F_TO_S/lua/", scripts = { "gen_files.sh"}}
T[#T+1] = { dir = "/OPERATORS/F_TO_S/lua/", scripts = { "pkg_f_to_s.lua"}}
T[#T+1] = { dir = "/OPERATORS/SORT/lua/", scripts = { "gen_files.sh"}}
T[#T+1] = { dir = "/OPERATORS/IDX_SORT/lua/", scripts = { "gen_files.sh"}}
T[#T+1] = { dir = "/OPERATORS/PRINT/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = { dir = "/OPERATORS/S_TO_F/lua/", scripts = { "gen_files.sh"}}
T[#T+1] = { dir = "/OPERATORS/S_TO_F/lua/", scripts = { "pkg_s_to_f.lua"}}
T[#T+1] = { dir = "/OPERATORS/AX_EQUALS_B/", scripts = { "make clean && make" } }
--========================
T[#T+1] = {dir = "/UTILS/src/", scripts = { "gen_files.sh" } }
T[#T+1] = {dir = "/OPERATORS/LOAD_CSV/lua/", scripts = { "gen_files.sh" }}
T[#T+1] = {dir = "/OPERATORS/LOAD_CSV/src/", scripts = { "gen_files.sh" }}
T[#T+1] = {dir = "/OPERATORS/PRINT/src/", scripts = { "gen_files.sh" }}
T[#T+1] = {dir = "/OPERATORS/PRINT/lua/", scripts = { "gen_files.sh" }}
--========================
return T
