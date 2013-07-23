# Paulina is the name of a gui library.

type 
    TPaulinaContext* = object
        msgQue: seq[int]



proc paulinaInit*(c: var TPaulinaContext) =
    # TODO

proc paulinaDone*(c: TPaulinaContext) =
    # TODO


proc paulinaStep(c: TPaulinaContext): bool =
    ## checks for messages and handles them. Waits until 
    ## there are events/messages available. Returns false when quit message
    ## received.

proc paulinaStepNoWait(c: TPaulinaContext): bool =
    ## Same as paulinaStep but returns immediately.
    # TODO




proc paulinaLoop*() =
    ## main loop function for simple app. Runs gui thread message loop.
    # TODO
    var c: TPaulinaContext
    c.paulinaInit
    while c.paulinaStep:
        pass
    c.paulinaDone


