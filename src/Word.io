// demi-16
// Word proto
// Jacob Peck

Word := Object clone do(
  value ::= 0
  
  init := method(self value = 0; self)
  
  with := method(val,
    self clone setValue(val)
  )
  
  extract := method(start, length,
    mask := 0
    i := 0
    while(i < length,
      mask = mask + (2 pow(i + start))
      i = i + 1
    )
    retval := (self value & mask) >> start
    //writeln("mask: " .. mask asBinary)
    //writeln("retval: " .. retval asBinary .. " " .. retval asHex .. " " .. retval)
    retval
  )
  
  getBasicOp := method(self extract(0,5))
  getExtendedOp := method(self getB)
  getB := method(self extract(5, 5))
  getExtendedA := method(self getA)
  getA := method(self extract(10, 6))
  
  isExtendedOp := method(if(self getBasicOp == 0x00, return true, return false))
  isBasicOp := method(self isExtendedOp not)
)