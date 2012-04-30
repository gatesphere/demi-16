// demi-16
// user interface
// Jacob Peck

UI := Object clone do(
  clone := method(self)
  
  rl := ReadLine
  c := CPU
  running := true
  version := "April 2012"
  spec_version := "1.7 RFE"
  
  welcome := method(
    writeln("demi-16, version #{self version} (spec version: #{self spec_version})" interpolate)
  )
  
  initialize := method(
    writeln("  + demi-16 is initializing... please be patient.")
    c initialize
    running := true
    self rl prompt = "demi-16> "
    self load_history
  )
  
  load_history := method(
    try(
      self rl loadHistory(".demi_history")
    )
  )
  
  save_history := method(
    try(
      self rl saveHistory(".demi_history")
    )
  )
  
  read_line := method(
    l := self rl readLine(self rl prompt)
    self rl addHistory(l)
    l
  )
  
  run := method(bin,
    self initialize
    self welcome
    if(bin != nil, self loadProgram(bin))
    while(running,
      in := self read_line
      self parseCommand(in)
    )
    self save_history
  )
  
  parseCommand := method(line,
    splits := line splitNoEmpties
    if(splits isEmpty, return)
    cmd := splits at(0) asLowercase
    arg := splits at(1)
    arg2 := splits at(2)
    cmd switch(
      "quit", self running = false,
      "exit", self running = false,
      "q", self running = false,
      
      "help", self help(arg),
      "?", self help(arg),
      
      "load", self loadProgram(arg),
            
      "step", self step,
      "s", self step,
      
      "reg", self reg(arg),
      
      "ram", self ram(arg),
      
      "dump_ram", self dump_ram(arg),
      
      "reset", self reset,
      
      "exec", self exec(arg),
      
      "stats", self stats,
      
      "set_reg", self set_reg(arg, arg2),
      
      "set_ram", self set_ram(arg, arg2),
      
      cmd, writeln("invalid command: #{cmd}" interpolate)
    )
  )
  
  // instructions
  help := method(arg,
    if(arg == nil,
      writeln("  demi-16 general help:")
      writeln("  Available commands are:")
      writeln("  quit/exit/q   help/?  load  step/s  reg  ram  dump_ram  reset")
      writeln("  exec  stats  set_reg  set_ram")
      writeln("  use help command for help on any command")
      ,
      arg asLowercase switch(
        "quit", writeln("exits demi-16"),
        "exit", writeln("exits demi-16"),
        "q", writeln("exits demi-16"),
        "help", writeln("demi-16 help"),
        "?", writeln("demi-16 help"),
        "load", writeln("loads the program specified by the arg into ram"),
        "step", writeln("steps through program execution by 1 opcode"),
        "s", writeln("steps through program execution by 1 opcode"),
        "reg", writeln("no arg: print all registers, with arg: print specified register"),
        "ram", writeln("no arg: same as dump_ram 10, with arg: print contents of ram at the address specified"),
        "dump_ram", writeln("no arg: same as dump_ram 10, with arg: print the first arg*8 words of ram"),
        "reset", writeln("reset demi-16 back to it's initial state"),
        "exec", writeln("execute the word provided as arg"),
        "stats", writeln("print status information about demi-16"),
        "set_reg", writeln("sets the register arg1 to the value arg2"),
        "set_ram", writeln("sets the ram contents at arg1 to the value arg2"),
        arg, writeln("invalid command: #{arg}" interpolate)
      )
    )
  )
  
  loadProgram := method(bin,
    ex := try(self c loadBin(bin))
    if(ex == nil, 
      writeln("Successfully loaded program #{bin}" interpolate)
      ,
      writeln("Could not open program #{bin}" interpolate)
    )
  )
  
  step := method(
    c step
  )
  
  reg := method(reg,
    if(reg == nil, c printRegisters; return)
    reg = reg asUppercase
    reg switch(
      "A", writeln("A: " .. pad(c A)),
      "B", writeln("B: " .. pad(c B)),
      "C", writeln("C: " .. pad(c C)),
      "X", writeln("X: " .. pad(c X)),
      "Y", writeln("Y: " .. pad(c Y)),
      "Z", writeln("Z: " .. pad(c Z)),
      "I", writeln("I: " .. pad(c I)),
      "J", writeln("J: " .. pad(c J)),
      "PC", writeln("PC: " .. pad(c PC)),
      "SP", writeln("SP: " .. pad(c SP)),
      "EX", writeln("EX: " .. pad(c EX)),
      reg, writeln("invalid register: #{reg}" interpolate)
    )
  )
  
  ram := method(ram,
    if(ram == nil, self dump_ram(10); return)
    addr := -1
    try(addr = ram fromBase(16))
    if(addr < 0x0000 or addr > 0xffff,
      writeln("invalid ram address: #{addr asHex}" interpolate)
      ,
      writeln("ram[#{pad(addr)}]: #{pad(c read_ram(addr))}" interpolate)
    )
  )
  
  dump_ram := method(lines,
    num := 10
    try(num = lines fromBase(10))
    if(num < 0 or num > 8192, num = 10)
    c printRamDump(num)
  )
  
  reset := method(
    writeln("  + resetting demi-16... please be patient.")
    c initialize
  )
  
  exec := method(arg,
    word := nil
    try(word = arg fromBase(16) )
    if(word == nil or word < 0x0000 or word > 0xffff,
      writeln("invalid word: #{arg asHex}" interpolate)
      ,
      c parseOpcode(Word with(word))
    )
  )
  
  stats := method(
    writeln(c)
  )
  
  set_reg := method(reg, val,
    if(reg == nil or val == nil, writeln("not enough arguments"); return)
    value := -1
    try(value = val fromBase(16))
    if(value < 0x0000 or value > 0xffff,
      writeln("invalid value: #{value asHex}" interpolate)
      return
    )
    reg = reg asUppercase
    reg switch(
      "A", c setA(value),
      "B", c setB(value),
      "C", c setC(value),
      "X", c setX(value),
      "Y", c setY(value),
      "Z", c setZ(value),
      "I", c setI(value),
      "J", c setJ(value),
      "PC", c setPC(value),
      "SP", c setSP(value),
      "EX", c setEX(value),
      reg, writeln("invalid register: #{reg}" interpolate)
    )
  )
  
  set_ram := method(ram, val,
    if(ram == nil or val == nil, writeln("not enough arguments"); return)
    value := -1
    try(value = val fromBase(16))
    if(value < 0x0000 or value > 0xffff,
      writeln("invalid value: #{value asHex}" interpolate)
      return
    )
    addr := -1
    try(addr = ram fromBase(16))
    if(addr < 0x0000 or addr > 0xffff,
      writeln("invalid address: #{addr asHex}" interpolate)
      return
    )
    c write_ram(addr, value)
  )
  
)
