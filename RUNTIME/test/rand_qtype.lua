local qtypes = { "I1",  "I2",  "I4",  "I8",  "F4",  "F8", }

local function rand_qtype()

local x = math.floor(math.random() * #qtypes)
if ( x == 0 ) then x = 1 end
return qtypes[x]
end
return rand_qtype

