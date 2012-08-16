import macros

when false:
    dumpTree:
        type
            PMyObj* = ref TMyObj 
            TMyObj* = object of TObject
                a, b : int

        proc newTMyObj*() : PMyObj =
            var o : PMyObj
            new(o)
            #initTMyObj(o[])
            return o    
    
#proc initTMyObj*(o : var TMyObj) = nil
    
when false:
    proc newTMyObj*() : PMyObj =
        var o : PMyObj
        new(o)
        #initTMyObj(o[])
        return o
    
    
macro objdecl(clsbase : expr) : stmt =
    result = newNimNode(nnkStmtList)#, clsbase)
    #for i in 1..clsbase.len-1:
    #echo(repr(clsbase[i]))
    let clsName = repr(clsbase[1])
    let baseName = repr(clsbase[2])
    let tname = "T" & clsName
    let pname = "P" & clsName
    echo("base = " & baseName & ", type = " & tname)
    var fields = clsbase[3][0][0] # [0] skip stmt list, [0] skip var section
    
    
    echo("fields = " & repr(fields))
    
    
    # start 'type' section
    var tsection = newNimNode(nnkTypeSection)
    result.add(tsection)
    
    block:
        # define 'type' node for Pclass * = ref Tclass
        var tnode = newNimNode(nnkTypeDef)
        tsection.add(tnode)
        
        # define type name with * operator
        var tpostf = newNimNode(nnkPostfix)
        tpostf.add(newIdentNode("*"))
        tpostf.add(newIdentNode(pname))
        tnode.add(tpostf)
        
        # don't know why but need an empty node
        tnode.add(newNimNode(nnkEmpty))
        
        # the actual type = ref
        var reft = newNimNode(nnkRefTy)
        reft.add(newIdentNode(tname))
        tnode.add(reft)
    
    
    block:
        # define 'type' node for Tclass * = object of base
        var tnode = newNimNode(nnkTypeDef)
        tsection.add(tnode)
        
        # define type name with * operator
        var tpostf = newNimNode(nnkPostfix)
        tpostf.add(newIdentNode("*"))
        tpostf.add(newIdentNode(tname))
        tnode.add(tpostf)
        
        # don't know why but need an empty node
        tnode.add(newNimNode(nnkEmpty))
        
        # the actual type = object of
        var objt = newNimNode(nnkObjectTy)
        tnode.add(objt)
        
        # needed, don't know why
        objt.add(newNimNode(nnkEmpty))
        
        var inh = newNimNode(nnkOfInherit)
        objt.add(inh)
        inh.add(newIdentNode(baseName))
        
        var recs = newNimNode(nnkRecList)
        objt.add(recs)
        
        recs.add(fields)
        
        #var identDefs = newNimNode(nnkIdentDefs)
        #recs.add(identDefs)
        
        #identDefs.add(getAST(fields))
        #for i in 0..len(fields)-1:
        #    identDefs.add(fields[i])
            
            
        # needed, don't know why
        #identDefs.add(newNimNode(nnkEmpty))
        
    
    #echo(fields.len)
    echo(treeRepr(tsection))
    #echo(repr(tsection))
    
    
    
    
    
    #tnode.add(new
    
    
template declClass(clsName : expr, baseCls : expr, fields : stmt) : stmt = 
    
    
    objdecl(clsName, baseCls, fields)
    when false:
        #`P clsName`* = ref `T clsName`
        #`T clsName`* = object of baseCls
        #    putfields

    proc `new clsName`() : `P clsName` =
        var o : `P clsName`
        new(o)
        return o
        
    
        
# ----- the usage:
    
 
declClass MyTempClass, TObject:
    var x, y : int
    

      
var o = newMyTempClass()
o.x = 3
echo("x,y = " & $o.x & " " & $o.y)


