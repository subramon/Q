local utils 	= require 'Q/UTILS/lua/utils'

local function process_opt_args(
  inV, 
  opt_args
  )
  if ( type(inV) == "lVector" ) then inV = { inV } end 
  assert(type(inV) == "table")
  local opfile
  local filter
  local print_order
  local outV
  local lenV
  
  outV = inV
  if opt_args then
    assert(type(opt_args) == "table")
    if opt_args.opfile ~= nil then
      opfile = opt_args.opfile
      assert(type(opfile) == "string")
    end
    if opt_args.filter then
      filter = opt_args.filter
    end
    if opt_args.print_order then
      print_order = opt_args.print_order
      assert(type(print_order) == "table")
      -- sort inV according to given print_order
      outV = utils.sort_table(vec_list, print_order)
    end
  end

  for i, v in ipairs(outV) do 
    assert(type(v) == "lVector")
    assert(v:is_eov())
    if ( i == 1 ) then
      lenV = v:num_elements()
    else
      assert(lenV == v:num_elements())
    end
  end
  return outV, opfile, filter, lenV
end
return  process_opt_args
