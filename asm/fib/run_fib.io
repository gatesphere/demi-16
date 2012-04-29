#!/usr/bin/env io

doFile("../../src/main.io")

writeStatus := method(c,
  writeln(c)
  c printRegisters
  c printRamDump(3)
)

c := CPU initialize
c loadBin("fib.bin")

writeln("Initial state:")
writeStatus(c)

writeln

loop(
  x := File standardInput readLine
  c parseOpcode(Word with(c nextWord(true)))
  writeStatus(c)
  writeln
)
