Packs several fields into one, assuming space exists
For example, if  u = Q.pack({x, y, z, w, v, }, "UI16")
x F8
y F4
z I2
w I1
v BL
then

(1) u:qtype() == "UI16"
(2) x:width() + y:width() + z:width() + w:width() + v:width() <= u:width()

Bits 64-127 of u contain x 
Bits 32-63  of u contain y
Bits 16-31  of u contain z
Bits 8-15   of u contain w 
Bits 0-7    of u contain v 

If u = Q.pack(w, v), "UI8") then
Bits 8-15   of u contain w 
Bits 0-7    of u contain v 
