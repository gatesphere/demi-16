// demi-16
// CPU proto
// Jacob Peck

// ram access
List squareBrackets := method(arg, self at(arg))

CPU := Object clone do(
  // cycle count
  cycle ::= 0
  
  // registers
  A  ::= 0x0000
  B  ::= 0x0000
  C  ::= 0x0000
  X  ::= 0x0000
  Y  ::= 0x0000
  Z  ::= 0x0000
  I  ::= 0x0000
  J  ::= 0x0000
  PC ::= 0x0000 // program counter
  SP ::= 0x0000 // stack pointer
  O  ::= 0x0000 // overflow
  
  // ram, 65536 16-bit words
  ram := List clone setSize(65536)
  
  // the address pointer, used internally
  /* -63<=>-32 = literal values... negate and subtract 0x20
   * -12  = next word literal 
   * -11  = SP
   * -10  = PC
   * -9   = O register
   * -8   = A register
   * -7   = B register
   * -6   = C register
   * -5   = X register
   * -4   = Y register
   * -3   = Z register
   * -2   = I register
   * -1   = J register
   * >= 0 = actual address
   */
  addr_pointer ::= 0
  
  clone := method(self)
  
  initialize := method(
    self A = 0x0000
    self B = 0x0000
    self C = 0x0000
    self X = 0x0000
    self Y = 0x0000
    self Z = 0x0000
    self I = 0x0000
    self J = 0x0000
    self PC = 0x0000
    self SP = 0x0000
    self O = 0x0000
    self addr_pointer = 0
    self ram size repeat(i, self ram atPut(i, 0x00))
    self
  )
  
  // opcode mapping
  parseOpcode := method(word,
    if(word isBasicOp,
      op := word getBasicOp
      op switch(
        0x1, self SET(word),
        0x2, self ADD(word),
        0x3, self SUB(word),
        0x4, self MUL(word),
        0x5, self DIV(word),
        0x6, self MOD(word),
        0x7, self SHL(word),
        0x8, self SHR(word),
        0x9, self AND(word),
        0xa, self BOR(word),
        0xb, self XOR(word),
        0xc, self IFE(word),
        0xd, self IFN(word),
        0xe, self IFG(word),
        0xf, self IFB(word)
      )
      ,
      op := word getExtendedOp
      op switch(
        0x01, self JSR(word)
      )
    )
    self
  )
  
  // value mapping
  parseValue := method(value,
    value switch(
      // registers
      0x00, self setAddr_pointer(-8),
      0x01, self setAddr_pointer(-7),
      0x02, self setAddr_pointer(-6),
      0x03, self setAddr_pointer(-5),
      0x04, self setAddr_pointer(-4),
      0x05, self setAddr_pointer(-3),
      0x06, self setAddr_pointer(-2),
      0x07, self setAddr_pointer(-1),
      
      // memory contents at the address pointed to by registers
      0x08, self setAddr_pointer(self A),
      0x09, self setAddr_pointer(self B),
      0x0a, self setAddr_pointer(self C),
      0x0b, self setAddr_pointer(self X),
      0x0c, self setAddr_pointer(self Y),
      0x0d, self setAddr_pointer(self Z),
      0x0e, self setAddr_pointer(self I),
      0x0f, self setAddr_pointer(self J),
      
      // [next word + register]
      0x10, self setAddr_pointer(self A + self nextWord),
      0x11, self setAddr_pointer(self B + self nextWord),
      0x12, self setAddr_pointer(self C + self nextWord),
      0x13, self setAddr_pointer(self X + self nextWord),
      0x14, self setAddr_pointer(self Y + self nextWord),
      0x15, self setAddr_pointer(self Z + self nextWord),
      0x16, self setAddr_pointer(self I + self nextWord),
      0x17, self setAddr_pointer(self J + self nextWord),
      
      // peek, pop, push
      0x18, self setAddr_pointer(self stackPop),
      0x19, self setAddr_pointer(self stackPeek),
      0x1a, self setAddr_pointer(self stackPush),
      
      // special registers
      0x1b, self setAddr_pointer(-11),
      0x1c, self setAddr_pointer(-10),
      0x1d, self setAddr_pointer(-9),
      
      // next word values
      0x1e, self setAddr_pointer(self nextWord)
      0x1f, self setAddr_pointer(-12),
      
      // literal value 0x00 - 0x1f
      true, self setAddr_pointer(-value)
    )
    self
  )
  
  // nitty gritty
  nextWord := method(
    retval := self read_ram(self PC)
    self setPC(self PC + 1) setCycle(self cycle + 1)
    retval
  )
  
  stackPop := method(
    retval := self SP
    self setSP(self SP + 1)
    if(self SP < 0, self SP = 0xffff)
    if(self SP > 0xffff, self SP = 0)
    retval
  )
  
  stackPeek := method(
    retval := self SP
    retval
  )
  
  stackPush := method(
    self setSP(self SP - 1)
    if(self SP < 0, self SP = 0xffff)
    if(self SP > 0xffff, self SP = 0)
    self SP
  )
   
  // ops
  SET := method(word,
    a := word getA
    b := word getB
    
    parseValue(a)
    a_ptr := self addr_pointer
    parseValue(b)
    b_ptr := self addr_pointer
    
    b_val := nil
    
    // determine value to set
    if(b_ptr < 0,
      b_ptr = -b_ptr
      if(b_ptr >= 0x20 and b_ptr <= 0x3f, b_val = (b_ptr - 0x20))
      if(b_ptr == 1, b_val = self J)
      if(b_ptr == 2, b_val = self I)
      if(b_ptr == 3, b_val = self Z)
      if(b_ptr == 4, b_val = self Y)
      if(b_ptr == 5, b_val = self X)
      if(b_ptr == 6, b_val = self C)
      if(b_ptr == 7, b_val = self B)
      if(b_ptr == 8, b_val = self A)
      if(b_ptr == 9, b_val = self O)
      if(b_ptr == 10, b_val = self PC)
      if(b_ptr == 11, b_val = self SP)
      if(b_ptr == 12, b_val = self nextWord)
      ,
      b_val = self read_ram(b_ptr)
    )
    
    if(b_val == nil, return)
    
    // determine location
    if(a_ptr < 0,
      a_ptr = -a_ptr
      if(a_ptr >= 0x20 amd a_ptr <= 0x3f, return)
      if(a_ptr == 12, return)
      if(a_ptr == 1, self setJ(b_val))
      if(a_ptr == 2, self setI(b_val))
      if(a_ptr == 3, self setZ(b_val))
      if(a_ptr == 4, self setY(b_val))
      if(a_ptr == 5, self setX(b_val))
      if(a_ptr == 6, self setC(b_val))
      if(a_ptr == 7, self setB(b_val))
      if(a_ptr == 8, self setA(b_val))
      if(b_ptr == 9, self setO(b_val))
      if(b_ptr == 10, self setPC(b_val))
      if(b_ptr == 11, self setSP(b_val))
      ,
      self write_ram(a_ptr, b_val)
    )
    
    writeln("a_ptr: #{a_ptr} b_ptr: #{b_ptr} b_val: #{b_val}" interpolate)
    writeln("setting value at addr #{a_ptr} to #{b_val}" interpolate) 
    
    self setCycle(self cycle + 1)
  )
   
  // ram manipulations  
  read_ram := method(addr,
    while(addr > 0xff, addr = addr - 0xff)
    self ram[addr]
  )
  
  write_ram := method(addr, value,
    //writeln("writing... #{addr} #{value}" interpolate)
    while(addr > 0xff, addr = addr - 0xff)
    while(value > 0xff, value = value - 0xff)
    self ram atPut(addr, value)
    self
  )
  
  
  // load binary
  loadBin := method(bin,
    f := File with(bin) openForReading
    i := 0
    j := 0
    while(i < f size,
      hibyte := f at(i)
      //writeln(lobyte asHex)
      lobyte := f at(i + 1)
      //writeln(hibyte asHex)
      if(lobyte == nil, lobyte = 0x00)
      if(hibyte == nil, hibyte = 0x00)
      word := ((hibyte << 8) + lobyte)
      i = i + 2
      self write_ram(j, word)
      j = j + 1
    )
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
  
  printRamDump := method(lines, start,
    if(lines == nil, lines = ram size / 8)
    k := 0
    if(start != nil, k = start, k = 0)
    lines repeat(i,
      write(self pad((i + k) * 8) .. ": ")
      8 repeat(j, write(self pad(self read_ram(i * 8 + j)) .. " "))
      writeln
    )
    self
  )
  
  asString := method("<demi-16 emu -- cycle: #{cycle}>" interpolate)
)
