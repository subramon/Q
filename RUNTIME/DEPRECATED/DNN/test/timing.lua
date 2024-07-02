--                   forw = 22913482880
--                   back = 28776104315
--
f_flops = 22108176384
b_flops = 27156859648
--total num flops         = 49258880704

fcycles  = 5642214953
bcycles  = 7830304974
tcycles  = 13472519927

fnsec   = fcycles / 2.5
bnsec   = bcycles / 2.5

f = f_flops / fnsec
b = b_flops / bnsec

print("forward  speed flops = ", f)
print("backward speed flops = ", b)
print("time = ", (fnsec + bnsec)/1000000000.0)
