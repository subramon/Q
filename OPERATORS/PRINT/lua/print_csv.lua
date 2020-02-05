local ffi       = require 'ffi'
local cVector   = require 'libvctr'
local cutils    = require 'libcutils'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local cmem	= require 'libcmem'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local process_opt_args = require 'Q/OPERATORS/PRINT/lua/process_opt_args'
local process_filter = require 'Q/OPERATORS/PRINT/lua/process_filter'

-- this implementation works but is not particularly fast - we are 
-- crossing the Lua/C boundary much too often. a faster version would
-- use get_chunk. For later TODO P3
local print_csv = function (
  inV,  --- table of lVectors to be printed
  opt_args
  )
local doc_string = [[ Signature: Q.print_csv({T}, opt_args)
  -- Q.print_csv prints the Columns contents where specified to.(default is stdout)
  opt_args: table of 3 arguments { opfile, <filter>, print_order }
  1) opfile: where to print the columns
            -- "file_name" : will print to file
            --  ""         : will return a string
            --  nil        : will print to stdout
  2) <filter> 
]]
  -- this call has been just done for docstring
  if vec_list and vec_list == "help" then
      return doc_string
  end

  -- processing opt_args of print_csv
  local V -- table of vectors to be printed in desired order
  local opfile -- file to write output to 
  local filter -- if we don't want all rows
  local lenV -- length of vectors
  V, opfile, filter, lenV = process_opt_args(inV, opt_args)
  local lb, ub, where = process_filter(filter, lenV)
  local nV = #nV
  
  -- Output ALWAYS go to a file, to stdout if no filename given 
  local fp = nil -- file pointer
  if ( ( not opfile )  or ( opfile == "" ) ) then
    io.output(io.stdout)
  else
    assert(type(opfile) == "string")
    fp = assert(io.open(opfile, "w+"))
    io.output(fp)
  end
  if ( lenV == 0 ) then io.close(fp) return true end 
  --==========================================
  local bfalse = Scalar.new(false, "B1")
  for rowidx = lb, ub do
    local to_print = true
    if ( where ) then 
      local  w = assert(where:get1(rowidx))
      if ( w == bfalse ) then 
        to_print = false
      end
    end
    if ( to_print ) then 
      for colidx, v in ipairs(V) do
        local  s, s_nn = assert(v:get1(rowidx))
        assert(not s_nn, "To be implemented") -- TODO P2
        if ( type(s) == "Scalar" ) then 
          -- TODO P0 Write scalar
        elseif ( type(s) == "CMEM" ) then 
          -- TODO P0 Write CMEM
        else
          error("")
        end
        if ( colidx == nV ) then 
          assert(io.write("\n"), "Write failed")
        else
          assert(io.write(","), "Write failed")
        end
      end
    end
  end
  io.close(fp) 
  return true
end
return require('Q/q_export').export('print_csv', print_csv)
