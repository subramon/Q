y:set_memo(false); z:set_memo(false);  -- no memo-izing needed
conjoin({y, z}) -- indicate that they need to be evaluated together
assert(z:is_eov() == false) -- z not fully evaluated
y:eval() -- evaluate y when needed
assert(z:is_eov() == true) -- z fully evaluated as a consequence of y eval
