// demi-16
// CPU proto
// Jacob Peck

// ram access
List squareBrackets := method(arg, self at(arg))

CPU := Object clone do(
  // cycle count
  cycle := 0
  
  // registers
  A := 0
  B := 0
  C := 0
  X := 0
  Y := 0
  Z := 0
  I := 0
  J := 0
  PC := 0 // program counter
  SP := 0 // stack pointer
  O := 0  // overflow
  
  // ram, 65536 16-bit words
  ram := List clone setSize(65536)
  
  clone := method(self)
  
  initialize := method(
    A = 0
    B = 0
    C = 0
    X = 0
    Y = 0
    Z = 0
    I = 0
    J = 0
    PC = 0
    SP = 0
    O = 0
    ram size repeat(i, ram atPut(i, 0))
    self
  )
  
  
  printRamDump := method(lines,
    if(lines == nil, lines = ram size / 8)
    lines repeat(i,
      label := (i * 8) toBase(16)
      while(label size < 4, label prependSeq("0"))
      write(label .. ": ")
      8 repeat(j,
        value := ram[i * 8 + j] toBase(16)
        while(value size < 4, value prependSeq("0"))
        write(value .. " ")
      )
      writeln
    )
    self
  )
)
