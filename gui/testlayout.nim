# test layout syntax

type
    PLayout = ref object
        name: string
    
    PWidget = ref object
        name: string

    PContainer = ref object of PWidget
        layout: PLayout
        items: seq[PWidget]
        
    

proc Window(name: string, layout: PLayout): PWindow =
    echo name, $layout
    result.new
    result.layout = layout
    

    
proc FreeLayout(controls: openarray[PWidget]): PContainer =
    
