local pldir = require 'pl.dir'
local plpath = require 'pl.path'
local q_root = assert(os.getenv("Q_ROOT"))
-- local dbg = require 'Q/UTILS/lua/debugger'
local ignore_files = {

}

function exclude_non_test_files(files)
  local xfiles = {}
  if ( files and #files > 0 ) then 
    for _, full_name in ipairs(files) do
      local is_excl = false
      local reason 
      local base_name = string.gsub(full_name, "%..*/test_", "test_")
      start, stop = string.find(base_name, "test_") 
      -- print(base_name, start, stop)
      if ( ( start == nil ) or ( start ~= 1 ) ) then
        is_excl = true
        reason = 1
      end
      start, stop = string.find(base_name, ".lua") 
      -- print(base_name, start, stop)
      if ( stop == nil ) or ( stop ~= string.len(base_name) ) then 
        is_excl = true
        reason = 2
      end
      if ( is_excl == false ) then 
        xfiles[#xfiles+1] = full_name
      end
      --[[
      if ( is_excl ) then 
        print(reason, "Excluding ", full_name, base_name)
      else
        print(reason, "NOT Excluding ", full_name, base_name)
      end
      --]]
    end
  end
  return xfiles
end
--===============================
local ignore_dirs = {
   DEPRECATED = true,
   experiment = true,
   DOC = true,
   doc = true,
}

local valid_tags = {
   FUNCTIONAL = true,
   NO_OP = true,
   PERFORMANCE = true,
   STRESS = true,
}

local function get_line_from_file(filename, line)
   line = line or 1
   local n = 0;
   for l in io.lines(filename) do
      n = n + 1
      if n == line then return l end
   end
   assert(nil, "End of file is reached")
end

local function get_tags(filename)
   local line = get_line_from_file(filename)
   local tags = {}
   for word in line:gmatch("%w+") do 
      if valid_tags[word] == true then
         tags[word] = true
      end
   end
   return tags
end

local function is_dir_exception(dir)
   local sub_dir = string.match(dir, "[^/]*$")
   return ignore_dirs[sub_dir] == true or ignore_dirs[dir] == true
end

local function is_file_exception(file)
   local sub_filename = string.match(file, "[^/]*$")
   return ignore_files[sub_filename] == true or ignore_files[file] == true
end

local function append_dirs(dest, src)
   for i=1,#src do
      if not is_dir_exception(src[i]) then
         dest[#dest + 1] = src[i]
      end
   end
   return dest
end

local function find_test_files(directory, pattern)
   local iter_list, next_iter_list = {}, {}
   pattern = pattern or "*.lua"
   iter_list[1] = directory
   local list = {}
   repeat
      for i=1,#iter_list do
         local dir = iter_list[i]
         local exclude = false
         if ( ( string.find(dir, ".git") ) or 
              ( string.find(dir, "DEPRECATED") ) ) then 
           exclude = true
         end
         if ( not exclude ) then 
           local files = pldir.getfiles(dir, pattern)
           local xfiles = exclude_non_test_files(files)
           local dirs = pldir.getdirectories(dir)
           next_iter_list = append_dirs(next_iter_list, dirs)
           for j=1,#xfiles do
             local xfile = xfiles[j]
             if not is_file_exception(xfile) then
               -- print("SCHEDULED ",file)
               list[#list + 1] = tostring(xfile)
             end
           end
         end
      end

      iter_list = next_iter_list
      next_iter_list = {}
   until #iter_list == 0
   return list
end

local function run_files(list, command, coverage_command, total, success, fail, nop)
   assert(list ~= nil, "Need a list of files to execute")
   assert( command ~= nil, "Need a command to run the program (the file name will be appeneded)" )
   total = total or 0
   success = success or 0
   fail = fail or 0
   nop = nop or 0
   for i=1,#list do
      os.execute("rm -r -f " .. q_root .. "/data/*")
      local file = list[i]
      local tags = get_tags(file)
      if tags.NO_OP == true then
         nop = nop + 1
      elseif tags.FUNCTIONAL == true then
        print("Starting evaluation ", file)
         local ret_val = os.execute(string.format(command  .. " 2>&1 >/dev/null", file) )
         os.execute(string.format(coverage_command  .. " 2>&1 >/dev/null", file))
         if ret_val == 0 then  -- success
            success = success + 1
            total = total + 1
            print(string.format("Succeeded: %s",file ))
         elseif ret_val == 2 then -- NOP
            nop = nop + 1
         else
            fail = fail + 1
            total = total + 1
            print(string.format("Failed: %s",file ))
         end
      else
         print(string.format("Unsupported: %s",file ))
      end
   end
   return total, success, fail, nop
end

assert(plpath.isdir(q_root))
assert(plpath.isdir(q_root .. "/data/"))

require('Q/UTILS/lua/cleanup')()
local TOTAL, SUCCESS, FAIL, NOP = run_files(find_test_files("./", "*.lua"),
   "luajit %s",
   "luajit -lluacov %s",
   0, 0, 0, 0)

--[[ TOTAL, SUCCESS, FAIL, NOP = run_files(find_test_files("./", "spec_*.lua"),
   "busted --lua=luajit %s &>/dev/null",
   "busted --lua=luajit -c -v %s &>/dev/null",
   TOTAL, SUCCESS, FAIL, NOP)
]]

print(string.format("SUCCESS/ FAIL/ TOTAL/ NOP : %s/ %s/ %s/ %s", SUCCESS, FAIL, TOTAL, NOP))
