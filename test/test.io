#!/usr/bin/env io

// demi-16
// test program
// Jacob M. Peck

doFile("../src/main.io")


writeln("-------------------------------SET test: SET PUSH, [A]-------------")
c := CPU initialize
c write_ram(3, 0x32)
c setA(0x0003)

writeln("Initial value of first block of ram")
c printRegisters
c printRamDump(1)
writeln("initial value of ram at 0xffff (should be 0x0000): " .. pad(c read_ram(0xffff)))
w := Word with("0010001100000001" fromBase(2))
writeln(c)

writeln
writeln("After set op")
c SET(w)
c printRegisters
c printRamDump(1)
writeln("final value of ram at 0xffff (should be 0x0032): " .. pad(c read_ram(0xffff)))
writeln(c)
writeln("\n\n")



writeln("-------------------------------ADD test: ADD A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
w := Word with("0010000000000010" fromBase(2))
writeln(c)

writeln
writeln("After ADD op")
c ADD(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0x0035): " .. pad(c A))
writeln(c)
writeln("\n\n")



writeln("-------------------------------SUB test: SUB A, [A]-------------")
c initialize
c write_ram(3, 0x0032)
c setA(0x0003)
c printRegisters
c printRamDump(1)
writeln("initial value of A (should be 0x0003): " .. pad(c A))
w := Word with("0010000000000011" fromBase(2))
writeln(c)

writeln
writeln("After SUB op")
c SUB(w)
c printRegisters
c printRamDump(1)
writeln("final value of A (should be 0xffd1): " .. pad(c A))
writeln(c)
writeln("\n\n")