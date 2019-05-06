#!/usr/bin/env lua
  local gen_code = require 'Q/UTILS/lua/gen_code'
  local plpath = require 'pl.path'
  local srcdir = '../gen_src/'
  local incdir = '../gen_inc/'
  if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
  if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
  local operators = assert(dofile 'cmp_operators.lua')
  local types = { 'I1', 'I2', 'I4', 'I8','F4', 'F8' }

  local num_produced = 0
  for i, operator in ipairs(operators) do
    local sp_fn = assert(require (operator .. '_specialize'))

    for i, in1type in ipairs(types) do 
      for j, in2type in ipairs(types) do 
        local status, subs, tmpl = pcall(sp_fn, in1type, in2type)
        if ( status ) then 
          gen_code.doth(subs, tmpl, incdir)
          gen_code.dotc(subs, tmpl, srcdir)
          print("Produced ", subs.fn)
          num_produced = num_produced + 1
        else
          print(subs)
        end
      end
    end
  end
  assert(num_produced > 0)
