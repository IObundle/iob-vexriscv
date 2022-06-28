#!/usr/bin/python3

from sys import argv

nFiles = int((len(argv)-2)/2)
mem_size = 2**(int(argv[-1]))
binfile = []
binaddr = []
bindata = []
aux = []

i = 0
for i in range(nFiles):
    binfile.append(argv[i*2+1])
    binaddr.append(int(argv[i*2+2], 16))
    with open(binfile[i], "rb") as f:
        bindata.append(f.read())
    aux.append(0)

i = 0
for i in range(nFiles):
    assert binaddr[i]+len(bindata[i]) <= mem_size
    assert len(bindata[i]) % 4 == 0
    assert binaddr[i] % 4 == 0

valid = False
i = 0
for i in range(int(mem_size/4)):
    j = 0
    for j in range(nFiles):
        aux[j] = i - int(binaddr[j]/4)
        if (aux[j] < (len(bindata[j])/4)) and (aux[j] >= 0):
            w = bindata[j]
            print('%02x%02x%02x%02x' % (w[4*aux[j]+3], w[4*aux[j]+2], w[4*aux[j]+1], w[4*aux[j]+0]))
            valid = True
            break;
    if not valid:
        print("00000000")
    valid = False
