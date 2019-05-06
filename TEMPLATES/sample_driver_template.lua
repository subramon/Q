#!/usr/bin/env lua

local tmpl = dofile 'q_vector_vector.tmpl'

tmpl.name = 'add'
tmpl.op1type = 'uint64_t'
tmpl.op2type = 'uint64_t'
tmpl.returntype = 'uint64_t'
tmpl.operation = '+'
-- print(tmpl 'declaration')
doth = tmpl 'declaration'
print("doth = ", doth)
-- print(tmpl 'definition')
dotc = tmpl 'definition'
print("dotc = ", dotc)
