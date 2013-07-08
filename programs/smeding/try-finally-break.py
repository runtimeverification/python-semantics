# the finally clause is also executed when we break from its body

while True :
    try :
        break
    finally :
        trace(0, None)

trace(1,None)
