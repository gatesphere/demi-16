#!/usr/bin/env io

// demi-16
// test program
// Jacob M. Peck

doFile("../src/main.io")

assert := method(t, 
  t ifFalse(Exception raise("Assertion failed!" interpolate))
)



writeln("-------------------------------SET test: SET PUSH, [A]-------------")
c := CPU initialize
c write_ram(3, 0x32)
c setA(0x0003)

writeln("Initial value of first block of ram")
c printRegisters
c printRamDump(1)
writeln("initial value of ram at 0xffff (should be 0x0000): " .. pad(c read_ram(0xffff)))
assert(c read_ram(0xffff) == 0x0000)
w := Word with("0010001100000001" fromBase(2))
writeln(c)

writeln
writeln("After set op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of ram at 0xffff (should be 0x0032): " .. pad(c read_ram(0xffff)))
assert(c read_ram(0xffff) == 0x0032)
writeln(c)
writeln("\n\n")



writeln("-------------------------------ADD test: ADD A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000000010" fromBase(2))
writeln(c)

writeln
writeln("After ADD op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0035): " .. pad(c A))
assert(c A == 0x0035)
assert(c EX == 0x0000)
writeln(c)
writeln("\n\n")



writeln("-------------------------------SUB test: SUB A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000000011" fromBase(2))
writeln(c)

writeln
writeln("After SUB op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0xffd1): " .. pad(c A))
assert(c A == 0xffd1)
assert(c EX == 0xffff)
writeln(c)
writeln("\n\n")



writeln("-------------------------------MUL test: MUL A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000000100" fromBase(2))
writeln(c)

writeln
writeln("After MUL op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0096): " .. pad(c A))
assert(c A == 0x0096)
writeln(c)
writeln("\n\n")



writeln("-------------------------------MLI test: MLI A, [A]-------------")
c initialize
c write_ram(3, twosCompliment(0x0032)) // 0003: -50
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000000101" fromBase(2))
writeln(c)

writeln
writeln("After MLI op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0xff6a): " .. pad(c A))
assert(c A == 0xff6a)
writeln(c)
writeln("\n\n")



writeln("-------------------------------DIV test: DIV A, [A]-------------")
c initialize
c write_ram(3, 0x0002)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000000110" fromBase(2))
writeln(c)

writeln
writeln("After DIV op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0001): " .. pad(c A))
assert(c A == 0x0001)
assert(c EX == 0x8000)
writeln(c)
writeln("\n\n")



writeln("-------------------------------DVI test: DVI A, [A]-------------")
c initialize
c write_ram(3, twosCompliment(2)) // 0003: -2
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000000111" fromBase(2))
writeln(c)

writeln
writeln("After DVI op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0xffff): " .. pad(c A))
assert(c A == 0xffff)
assert(c EX == 0x8000)
writeln(c)
writeln("\n\n")



writeln("-------------------------------MOD test: MOD A, [A]-------------")
c initialize
c write_ram(3, 0x0002)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000001000" fromBase(2))
writeln(c)

writeln
writeln("After MOD op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0001): " .. pad(c A))
assert(c A == 0x0001)
writeln(c)
writeln("\n\n")



writeln("-------------------------------MDI test: MDI A, [A]-------------")
c initialize
c write_ram(twosCompliment(7), 0x0010)
c setA(twosCompliment(7))
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0xfff9): " .. pad(c A))
assert(c A == 0xfff9)
w := Word with("0010000000001001" fromBase(2))
writeln(c)

writeln
writeln("After MDI op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0xfff9): " .. pad(c A))
assert(c A == 0xfff9)
writeln(c)
writeln("\n\n")



writeln("-------------------------------AND test: AND A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000001010" fromBase(2))
writeln(c)

writeln
writeln("After AND op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0002): " .. pad(c A))
assert(c A == 0x0002)
writeln(c)
writeln("\n\n")



writeln("-------------------------------BOR test: BOR A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000001011" fromBase(2))
writeln(c)

writeln
writeln("After BOR op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0033): " .. pad(c A))
assert(c A == 0x0033)
writeln(c)
writeln("\n\n")



writeln("-------------------------------XOR test: XOR A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000001100" fromBase(2))
writeln(c)

writeln
writeln("After XOR op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0031): " .. pad(c A))
assert(c A == 0x0031)
writeln(c)
writeln("\n\n")



writeln("-------------------------------SHR test: SHR A, [A]-------------")
c initialize
c write_ram(3, 0x0001)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000001101" fromBase(2))
writeln(c)

writeln
writeln("After SHR op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0001): " .. pad(c A))
assert(c A == 0x0001)
writeln(c)
writeln("\n\n")



writeln("-------------------------------ASR test: ASR A, [A]-------------")
c initialize
c write_ram(twosCompliment(4), 0x0002) // fffc: 2
c setA(twosCompliment(4))
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0xfffc): " .. pad(c A))
assert(c A == 0xfffc)
w := Word with("0010000000001110" fromBase(2))
writeln(c)

writeln
writeln("After ASR op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0xffff): " .. pad(c A))
assert(c A == 0xffff)
writeln(c)
writeln("\n\n")



writeln("-------------------------------SHL test: SHL A, [A]-------------")
c initialize
c write_ram(3, 0x0001)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
assert(c A == 0x0003)
w := Word with("0010000000001111" fromBase(2))
writeln(c)

writeln
writeln("After SHL op")
c parseOpcode(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0006): " .. pad(c A))
assert(c A == 0x0006)
writeln(c)
writeln("\n\n")