import macros

type 
    TBaseObject = ref object of TObject
        className : string
        
    TBaseInterface = ref object of TObject
        interfaceName : string
        implObject : TBaseObject
        
    
    # ----------
    
template declMediator(med, par : expr) : stmt=
    type TMed = ref object of med
            parent : par


    proc abc(a,b:int) : int =
        return a+b

               
    proc newTMed(p : par) : TMed =
        var a : TMed
        new(a)
        a.parent = p
        return a
        
# ------

type
    TBaseMed =  object
        doSmth : proc()
        
    TParent = object
        doda : int
# ------

#proc nnn(p : ref TParent) : ref TBaseMed =
#    return nil

declMediator(TBaseMed, TParent)

var a = "abc" & " ddd"

echo(a)

template tm(m:stmt) : stmt = 
    emit("""
        var
            """ & repr(m))
            
   
tm:
    dd : int
            

    

