# the finally clause is also executed when we continue in its body

t = True

while t :
    try :
        t = False
        continue
    finally :
        trace(0, None)

trace(1,None)
