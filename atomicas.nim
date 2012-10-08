# nimrod.exe c --threads:on -t:-march=i686 -r atomicas.nim -- for win32 mingw
# otherwise it will compiled for i386 where atomic builtins are not available
# TODO version for ref, tests

const
  hasThreadSupport = compileOption("threads")


when (defined(gcc) or defined(llvm_gcc)) and hasThreadSupport:
  proc compareAndSwap[T: ptr|ref|pointer](mem: var T, expected: T, newValue: T): bool {.nodecl, 
      importc: " __sync_bool_compare_and_swap".}
      
elif defined(windows) and hasThreadSupport:
    proc InterlockedCompareExchangePointer(mem: ptr pointer,
      newValue: pointer, comparand: pointer) : pointer {.nodecl, 
        importc: "InterlockedCompareExchangePointer", header:"windows.h".}

    proc compareAndSwap[T: ptr|ref|pointer](mem: var T, 
      expected: T, newValue: T): bool {.inline.}=
      return InterlockedCompareExchangePointer(addr(mem), 
        newValue, expected) == expected
    
elif not hasThreadSupport:
  proc compareAndSwap[T: ptr|ref|pointer](mem: var T, 
    expected: T, newValue: T): bool {.inline.} =
      var oldval = mem
      if oldval == expected:
        mem = newValue
        return true
      return false



when isMainModule:
  var 
    a: int = 32
    i: ref int
    p: pointer
    r: ref int
    
  new(i)
  i[] = 34
    
  var cur1 = compareAndSwap(p, nil, addr(a))
  if (cur1 != true) or (p != addr(a)):
    echo "failed cur1"
    
  cur1 = compareAndSwap(p, addr(a), nil)
  if (p != nil) or (cur1 != true):
    echo "failed cur1 two"
  
  var cur2 = compareAndSwap(r, nil, i)
  if (cur2 != true) or (r != i):
    echo "failed cur2"
    
  cur2 = compareAndSwap(r, i, nil)
  if (cur2 != true) or (r != nil):
    echo "failed cur2 two"
    
  