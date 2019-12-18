  local plpath = require 'pl.path'
  local srcdir = "../gen_src/"
  local incdir = "../gen_inc/"
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end

  local gen_code = require("Q/UTILS/lua/gen_code")

  local operator_file = assert(arg[1])
  assert(plpath.isfile(operator_file))
  local operators = dofile(operator_file)

  local types = { 'B1', 'I1', 'I2', 'I4', 'I8','F4', 'F8' }
  local comparisons = { 'gt', 'geq', 'lt', 'leq', 'eq', 'neq' }

  for i, operator in ipairs(operators) do
    local num_produced = 0
    local sp_fn = assert(require(operator .. "_specialize"))
    for i, intype in ipairs(types) do 
     local status, subs
      if ( operator == "is_next" ) then 
        if ( intype == "B1" ) then
          -- nothing to do 
            -- TODO P3 This special case is dirty. Clean it up
        else
          for _, comparison in ipairs(comparisons) do 
            for j = 1, 2 do 
              local optargs = {}
              if ( j == 2 ) then optargs.mode = "fast" end 
              status, subs = pcall(sp_fn, intype, 
                comparison, optargs)
              if ( status ) then 
                assert(type(subs) == "table")
                gen_code.doth(subs, incdir)
                gen_code.dotc(subs, srcdir)
                print("Generated ", subs.fn)
                num_produced = num_produced + 1
              else
                print("Failed ", intype, subs)
              end
            end
          end
        end
      else
        status, subs = pcall(sp_fn, intype)
        print(operator, intype)
        if ( status ) then 
          assert(type(subs) == "table")
          if ( ( intype == "B1" ) and ( operator == "sum" ) ) then
            -- TODO P3 This special case is dirty. Clean it up
            print("skipping")
          else 
            gen_code.doth(subs, incdir)
            gen_code.dotc(subs, srcdir)
            print("Generated ", subs.fn)
            num_produced = num_produced + 1
          end
        end
      end
    end
    assert(num_produced > 0)
  end
