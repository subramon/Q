local extract_fn_proto = require 'Q/UTILS/lua/extract_fn_proto'
local plpath = require 'pl.path'
local plfile = require 'pl.file'
local src_root = assert(os.getenv("Q_SRC_ROOT"))
local q_root = assert(os.getenv("Q_ROOT"))
assert(plpath.isdir(src_root))
corefiles = "core_c_files.txt"
assert(plpath.isfile(corefiles))

local incs=" -I../inc/ "
incs = incs .. " -I../gen_inc/"
incs = incs .. " -I" .. src_root .. "/OPERATORS/PRINT/gen_inc/"
incs = incs .. " -I" .. src_root .. "/OPERATORS/LOAD_CSV/gen_inc/"
incs = incs .. " " 

local qcflags = assert(os.getenv("QC_FLAGS"))
local qlflags = assert(os.getenv("Q_LINK_FLAGS"))

local fn_protos = {}
--[[ special case for mmap_struct
file = assert(io.open(src_root .. "/UTILS/inc/mmap_types.h"))
for line in file:lines() do
  print(line)
  start, stop = string.find(line, "#")
  if ( not start ) then
    fn_protos[#fn_protos+1] = line
  end
end
--]]
--===============================
io.close()
local file = io.open(corefiles, "r");
local arr = {}
local int n = 0
os.execute("rm -f *.o *.so")
for line in file:lines() do
  table.insert (arr, line);
  local filename = src_root .. "/" .. line
  command = "gcc -c " .. qcflags .. " " .. incs .. filename
  fn_protos[#fn_protos+1] = extract_fn_proto(filename)
  status = os.execute(command)
  assert(status == 0, "Failure on " .. command)
  n = n + 1
end

command = "gcc " .. qlflags .. " *.o -o " .. q_root .. "/libq_core.so"
print(command)
status = os.execute(command)
assert(status == 0, "Failure on " .. command)
os.execute("rm -f *.o *.so")
-- TODO Where to create this?
plfile.write(q_root .. "/include/q_core.h", table.concat(fn_protos, "\n"))
plfile.write(src_root .. "/q_core.h", table.concat(fn_protos, "\n"))
print("Successfully generated minimal stuff with " .. n .. " files")

--[[
rm -f *.o
while read line 
do
  gcc -c $QC_FLAGS $INCS "${Q_SRC_ROOT}/$line"
done < core_c_files.txt
gcc *.o $Q_LINK_FLAGS -o libq_core.so
rm -f *.o
cp libq_core.so $Q_ROOT/lib/
echo "Successfully completed $0 in $PWD"
--]]
