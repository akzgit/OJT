i=0
j=1

#range of the series
a=10

for x in range(a):
    if x==0:
        print(i)
    elif x==1:
        print(j)
    else:
        x=i+j
        i=j
        j=x
        print(x)        
    