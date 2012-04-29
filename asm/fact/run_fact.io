#!/usr/bin/env io

doFile("../../src/main.io")

writeStatus := method(c,
  writeln(c)
  c printRegisters
  c printRamDump(2)
)

c := CPU initialize
c loadBin("fact.bin")

writeln("Initial state:")
writeStatus(c)

writeln

loop(
  x := File standardInput readLine
  c parseOpcode(Word with(c nextWord(true)))
  writeStatus(c)
  writeln
)
