local Q = require 'Q'
local dload = require 'Q/MULTI_DIM/lua/dload'
local mk_ab = require 'Q/MULTI_DIM/lua/mk_ab'
local pldir = require 'pl.dir'
local plfile = require 'pl.file'
local qc    = require 'Q/UTILS/lua/q_core'
local first_time = false
if ( first_time ) then 
  local homedir = os.getenv("HOME")
  local metafile = os.getenv("Q_METADATA_FILE")
  assert(metafile and #metafile > 0 )
  plfile.delete(metafile)
  pldir.rmtree( homedir .. "/local/Q/data/")
  pldir.makepath(homedir .. "/local/Q/data/")
  local T, M = dload()
  local n
  for k, v in pairs(T) do 
    n = v:length() 
  end

  -- Find range for sumby
  for _, vec in pairs(T) do 
    assert(type(vec) == "lVector")
    local x, y, z = Q.max(vec):eval()
    vec:set_meta("max", {x, y, z})
    local x, y, z = Q.min(vec):eval()
    vec:set_meta("min", {x, y, z})
  end
  
  a, b = mk_ab(n, 0.4)
  Q.save()
  os.exit()
end

Q.restore()
print("Setting up computation")

local grp_by = { "f1", "f2", "f3", "f4" }
local avals = {}
local bvals = {}
for _, vec in pairs(T) do 
  local attr = vec:get_name()
  assert(type(vec) == "lVector")
  local x, y = Q.min(vec):eval() -- should not need comoutation
  assert(x:to_num() >= 0)
  local x, y = Q.max(vec):eval() -- should not need comoutation
  local nvals = x:to_num() + 1
  avals[attr] = {}
  bvals[attr] = {}
  for _, metric in pairs(M) do 
    assert(type(metric) == "lVector")
    local optargs = { }; optargs.where = a
    avals[attr][metric] = Q.sumby(metric, vec, nvals, optargs)
    bvals[attr][metric] = Q.sumby(metric, vec, nvals, { where = b })
  end
end
local is_chunking = true
print("Performing computation")
local clockspeed = 2200
local t_start = qc.RDTSC()
if ( is_chunking ) then 
  print("Chunking...")
  local chunk_num = 0
  local keep_going = true
  while true do 
    for attr, _ in pairs(T) do 
      for _, metric in pairs(M) do 
        -- print(chunk_num, ": attr, metric, chunk_num = ", attr, metric:get_name())
        local x = avals[attr][metric]:next()
        local y = bvals[attr][metric]:next()
        assert(x == y)
        if ( not x ) then 
          keep_going = false 
          print("Breaking on chunk ", chunk_num)
        end 
      end
    end
    if ( not keep_going ) then break end 
    chunk_num = chunk_num + 1
    -- print("Chunk = ", chunk_num)
  end
else
  print("NO Chunking...")
  for attr, _ in pairs(T) do 
    for _, metric in pairs(M) do 
      local t0 = qc.RDTSC()
      avals[attr][metric]:eval()
      bvals[attr][metric]:eval()
      local t1 = qc.RDTSC()
      print("computed " .. metric:get_name() .. " for " ..  attr 
        .. " in " ..  tonumber((t1-t0))/(2200.0 * 1000000.0))
  
    end
  end
end
local t_stop = qc.RDTSC()
print("Time = ", tonumber((t_stop-t_start))/(2200.0 * 1000000.0))

print("Successfully completed")
os.exit()
