-- Specify script in order in which they should run
local T = {}
T[#T+1] = { dir = "/OPERATORS/A_IN_B/test/", scripts = { "run_tests.sh" }}
T[#T+1] = { dir = "/OPERATORS/F_TO_S/test/", scripts = { "run_tests.sh" }}
T[#T+1] = { dir = "/OPERATORS/F1F2OPF3/test/", scripts = { "run_tests.sh" }}
T[#T+1] = { dir = "/OPERATORS/IDX_SORT/test/", scripts = { "run_tests.sh" }}

T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/", scripts = { "test_get_cell.sh" }}
-- RS TODO T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/", scripts = { "run_tests.sh" }}
-- RS TODO T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/", scripts = { "test_get_cell.sh" }}
T[#T+1] = { dir = "/RUNTIME/COLUMN/code/test/", scripts = { "make clean && make" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/", scripts = { "test_load.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/testcases/", scripts = { "test_meta_data.sh" }}
T[#T+1] = { dir = "/OPERATORS/LOAD_CSV/test/testcases/", scripts = { "test_load_csv.sh" }}

T[#T+1] = { dir = "/OPERATORS/DATA_LOAD/test/", scripts = { "test_load.sh" }}
-- VJ TODO T[#T+1] = { dir = "/OPERATORS/DATA_LOAD/test/", scripts = { "test_dictionary.sh" }}
T[#T+1] = { dir = "/OPERATORS/DATA_LOAD/test/testcases/", scripts = { "test_meta_data.sh" }}
T[#T+1] = { dir = "/OPERATORS/DATA_LOAD/test/testcases/", scripts = { "test_load_csv.sh" }}


-- VJ TODO T[#T+1] = { dir = "/OPERATORS/PRINT/test/", script = "test_print_csv.sh" }
-- VJ TODO T[#T+1] = { dir = "/OPERATORS/PRINT/test/", script = "test_meta_data.sh" }
-- VJ TODO T[#T+1] = { dir = "/OPERATORS/PRINT/test/", script = "run_tests.sh" }
T[#T+1] = { dir = "/OPERATORS/PRINT/test/", script = "test_print.sh" }

T[#T+1] = { dir = "/OPERATORS/SORT/test/", scripts = { "run_tests.sh" }}
-- VJ TODO T[#T+1] = { dir = "/UTILS/test/", scripts = { "RUN_TEST.sh" }}
T[#T+1] = { dir = "/UTILS/test/", scripts = { "test_bytes_to_bits.sh" }}
return T
