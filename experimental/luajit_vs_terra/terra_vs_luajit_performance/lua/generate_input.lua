local gen_csv = require 'gen_csv_metadata_file'

metadata_file_path = "./meta_info/meta_info_1mr_256c.lua"
local M = dofile(metadata_file_path)

local unique_string_tables = gen_csv.generate_unique_varchar_strings(M)
local metadata_table = gen_csv.generate_metadata(M)

local csv_file_path = arg[1]
local row_count = tonumber(arg[2])
local chunk_print_size = 1000 -- Keeping default value

local start_time = os.time()
gen_csv.generate_csv_file(csv_file_path, metadata_table, row_count, chunk_print_size,unique_string_tables)
local end_time = os.time()

print("--------------------------------------------")
print("Input file generated at location: "..csv_file_path)
print(string.format("File Generation Time: %.2f secs", end_time-start_time))
print("--------------------------------------------")
