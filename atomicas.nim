# nimrod.exe c --threads:on -t:-march=i686 -r atomicas.nim -- for win32 mingw
# otherwise it will compiled for i386 where atomic builtins are not available

const
  hasThreadSupport = compileOption("threads")


when (defined(gcc) or defined(llvm_gcc)) and hasThreadSupport:
  proc compareAndSwap(mem: ptr pointer, expected: pointer, newValue: pointer): pointer {.nodecl, 
      importc: " __sync_val_compare_and_swap".}
      
elif defined(windows) and hasThreadSupport:
    proc InterlockedCompareExchangePointer(mem: ptr pointer,
      newValue: pointer, comparand: pointer) : pointer {.nodecl, 
        importc: "InterlockedCompareExchangePointer", header:"windows.h".}

    proc compareAndSwap(mem: ptr pointer, 
      expected: pointer, newValue: pointer): pointer =
      return InterlockedCompareExchangePointer(mem, newValue, expected)
    
elif not hasThreadSupport:
  proc compareAndSwap(mem: ptr pointer, 
    expected: pointer, newValue: pointer): pointer {.inline.} =
      var oldval = mem[]
      if oldval == expected:
        mem[] = newValue
      return oldval



when isMainModule:
  var 
    p: pointer
    r: ref int
  discard compareAndSwap(addr(p), nil, nil)
  discard compareAndSwap(cast[ptr pointer](addr(r)), nil, nil)
  