import re, sys 
f = open(sys.argv[1])
index = int(sys.argv[2])
s = f.read()
r = re.compile(r"PoolVector2Array\([^)]*\)")
l = (-float(t) if i%2==1 else float(t) for i, t in enumerate(r.findall(s)[index][17:-1].split(",")))
l = map(str, l)
print(", ".join(l))