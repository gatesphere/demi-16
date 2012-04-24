#!/usr/bin/env io

// demi-16
// test program
// Jacob M. Peck

doFile("../src/CPU.io")
doFile("../src/Word.io")

c := CPU initialize
c write_ram(0, 0x03)
c write_ram(3, 0x32)
c setA(0x03)

writeln("Initial value of first block of ram")
c printRamDump(1)
writeln("initial value of ram at 0xffff (should be 0x0000): " .. c pad(c read_ram(0xffff)))
w := Word with("0010000110100001" fromBase(2))
writeln(c)

writeln
writeln("After set op")
c SET(w)
c printRegisters
c printRamDump(1)
writeln("final value of ram at 0xffff (should be 0x0032): " .. c pad(c read_ram(0xffff)))
writeln(c)
