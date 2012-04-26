#!/usr/bin/env io

doFile("../src/main.io")

c := CPU initialize
c loadBin("fib.bin")

writeln("Initial state:")
c printRegisters
c printRamDump(3)
writeln(c)

writeln

loop(
  x := File standardInput readLine
  c parseOpcode(Word with(c nextWord))
  c printRegisters
  c printRamDump(3)
  writeln(c)
  writeln
)
