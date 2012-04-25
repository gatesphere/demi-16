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
  EX ::= 0x0000 // overflow/extra
  
  // ram, 65536 16-bit words
  ram := List clone setSize(65536)
  
  // the address pointer, used internally
  /* -63<=>-32 = literal values... negate and subtract 0x20
   * -12  = next word literal 
   * -11  = SP
   * -10  = PC
   * -9   = EX
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
    self EX = 0x0000
    self addr_pointer = 0
    self ram size repeat(i, self ram atPut(i, 0x00))
    self
  )
  
  // opcode mapping
  parseOpcode := method(word,
    if(word isBasicOp,
      op := word getBasicOp
      op switch(
        0x01, self SET(word),
        0x02, self ADD(word),
        0x03, self SUB(word),
        0x04, self MUL(word),
        0x05, self MLI(word),
        0x06, self DIV(word),
        0x07, self DVI(word),
        0x08, self MOD(word),
        0x09, self AND(word),
        0x0a, self BOR(word),
        0x0b, self XOR(word),
        0x0c, self SHR(word),
        0x0d, self ASR(word),
        0x0e, self SHL(word),
        0x0f, nil, // as yet undefined
        0x10, self IFB(word),
        0x11, self IFC(word),
        0x12, self IFE(word),
        0x13, self IFN(word),
        0x14, self IFG(word),
        0x15, self IFA(word),
        0x16, self IFL(word),
        0x17, self IFU(word)
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
  parseValue := method(value, a_mode,
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
      
      // peek/pop, push, pick
      0x18, if(a_mode, self setAddr_pointer(self stackPop), self setAddr_pointer(self stackPush))
      0x19, self setAddr_pointer(self stackPeek),
      0x1a, self setAddr_pointer(self SP + self nextWord),
      
      // special registers
      0x1b, self setAddr_pointer(-11), // SP
      0x1c, self setAddr_pointer(-10), // PC
      0x1d, self setAddr_pointer(-9),  // EX
      
      // next word values
      0x1e, self setAddr_pointer(self nextWord)
      0x1f, self setAddr_pointer(-12),
      
      // literal value 0x00 - 0x1f
      true, self setAddr_pointer(-value)
    )
    self
  )
  
  // nitty gritty
  incCycle := method(
    self setCycle(self cycle + 1)
  )
    
      
  
  nextWord := method(
    retval := self read_ram(self PC)
    self setPC(self PC + 1) incCycle
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
    
    parseValue(a, true)
    a_ptr := self addr_pointer
    parseValue(b, false)
    b_ptr := self addr_pointer
    
    a_val := nil
    
    // determine value to set
    if(a_ptr < 0,
      a_ptr = -a_ptr
      if(a_ptr >= 0x20 and a_ptr <= 0x3f,
        if(a_ptr == 0x20, 
          a_val = 0xffff
          ,
          a_val = (a_ptr - 0x21)
        )
      )
      if(a_ptr == 1, a_val = self J)
      if(a_ptr == 2, a_val = self I)
      if(a_ptr == 3, a_val = self Z)
      if(a_ptr == 4, a_val = self Y)
      if(a_ptr == 5, a_val = self X)
      if(a_ptr == 6, a_val = self C)
      if(a_ptr == 7, a_val = self B)
      if(a_ptr == 8, a_val = self A)
      if(a_ptr == 9, a_val = self EX)
      if(a_ptr == 10, a_val = self PC)
      if(a_ptr == 11, a_val = self SP)
      if(a_ptr == 12, a_val = self nextWord)
      ,
      a_val = self read_ram(a_ptr)
    )
    //writeln("a_val: #{a_val asHex}" interpolate)
    
    if(a_val == nil, return)
    
    // determine location
    if(b_ptr < 0,
      b_ptr = -b_ptr
      if(b_ptr >= 0x20 and b_ptr <= 0x3f, return)
      if(b_ptr == 12, return)
      if(b_ptr == 1, self setJ(a_val))
      if(b_ptr == 2, self setI(a_val))
      if(b_ptr == 3, self setZ(a_val))
      if(b_ptr == 4, self setY(a_val))
      if(b_ptr == 5, self setX(a_val))
      if(b_ptr == 6, self setC(a_val))
      if(b_ptr == 7, self setB(a_val))
      if(b_ptr == 8, self setA(a_val))
      if(b_ptr == 9, self setO(a_val))
      if(b_ptr == 10, self setPC(a_val))
      if(b_ptr == 11, self setSP(a_val))
      ,
      self write_ram(b_ptr, a_val)
    )
    
    //writeln("a_ptr: #{a_ptr asHex} b_ptr: #{b_ptr asHex} a_val: #{a_val asHex}" interpolate)
    //writeln("setting value at addr #{a_ptr asHex} to #{a_val asHex}" interpolate) 
    
    self incCycle
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
  printRegisters := method(
    a := pad(self A)
    b := pad(self B)
    c := pad(self C)
    x := pad(self X)
    y := pad(self Y)
    z := pad(self Z)
    i := pad(self I)
    j := pad(self J)
    pc := pad(self PC)
    sp := pad(self SP)
    ex := pad(self EX)
    writeln(" A: #{a}  B: #{b}  C: #{c}"   interpolate)
    writeln(" X: #{x}  Y: #{y}  Z: #{z}"   interpolate)
    writeln(" I: #{i}  J: #{j}"           interpolate)
    writeln("PC: #{pc} SP: #{sp} EX: #{ex}" interpolate) 
    self
  )
  
  printRamDump := method(lines, start,
    if(lines == nil, lines = ram size / 8)
    k := 0
    if(start != nil, k = start, k = 0)
    lines repeat(i,
      write(pad((i + k) * 8) .. ": ")
      8 repeat(j, write(pad(self read_ram(i * 8 + j)) .. " "))
      writeln
    )
    self
  )
  
  asString := method("<demi-16 emu -- cycle: #{cycle}>" interpolate)
)