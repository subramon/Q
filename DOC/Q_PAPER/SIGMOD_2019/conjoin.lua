-- indicate no memo-izing needed
y:set_memo(false); z:set_memo(false);  
-- indicate that y,z need to be evaluated together
conjoin({y, z}) 
-- z not fully evaluated
assert(z:is_eov() == false) 
-- evaluate y when needed
y:eval() 
-- z fully evaluated as a consequence of y eval
assert(z:is_eov() == true) 
