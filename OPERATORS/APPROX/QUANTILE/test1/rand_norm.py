import numpy as np
np.random.seed(1)
vals = np.random.binomial(n = 1000, p=0.5, size = 1000000)
vals = [int(i) for i in vals]
idx = []
for i in xrange(1, 21):
   idx.append(i*5)
quantiles = np.percentile(vals, idx)
for i,q in zip(idx, quantiles):
   print(i,int(q))
f = open("data1.txt", 'w')
for i in vals:
   f.write(str(i) + "\n")
f.close()
