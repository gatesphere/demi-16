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
    self A = 0
    self B = 0
    self C = 0
    self X = 0
    self Y = 0
    self Z = 0
    self I = 0
    self J = 0
    self PC = 0
    self SP = 0
    self O = 0
    self ram size repeat(i, self ram atPut(i, 0))
    self
  )
  
  
  
  
  // display
  pad := method(val,
    v := val toBase(16)
    while(v size < 4, v prependSeq("0"))
    v
  )
  
  printRegisters := method(
    a := self pad(self A)
    b := self pad(self B)
    c := self pad(self C)
    x := self pad(self X)
    y := self pad(self Y)
    z := self pad(self Z)
    i := self pad(self I)
    j := self pad(self J)
    pc := self pad(self PC)
    sp := self pad(self SP)
    o := self pad(self O)
    writeln(" A: #{a}  B: #{b} C: #{c}"   interpolate)
    writeln(" X: #{x}  Y: #{y} Z: #{z}"   interpolate)
    writeln(" I: #{i}  J: #{j}"           interpolate)
    writeln("PC: #{pc} SP: #{sp} O: #{o}" interpolate) 
    self
  )
  
  printRamDump := method(lines,
    if(lines == nil, lines = ram size / 8)
    lines repeat(i,
      write(self pad(i * 8) .. ": ")
      8 repeat(j, write(self pad(self ram[i * 8 + j]) .. " "))
      writeln
    )
    self
  )
)
