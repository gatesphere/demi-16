# demi-16
Jacob M. Peck, 2012

## Overview
This is an emulator for the [DCPU-16](https://raw.github.com/gatesphere/demi-16/master/docs/dcpu-specs/dcpu-1-7.txt) architecture.

This emulator has no VRAM, no hardware emulation, and no interrupts.  This is a 
purely memory-mapped emulator for educational purposes.

## Use
This requires an installation of Io (available at the [IoLanguage](http://iolanguage.com/) website).

To start up demi-16, run the demi-16 loader:

    ./demi-16.io
    
You can also provide a binary file as an argument and demi-16 will load it for you:

    ./demi-16.io asm/fib/fib.bin

Once inside, you'll have an interface from which to issue commands.  There is a 
history with readline support, so arrow keys will cycle through your previously
entered commands.

The `help` command provides information about the various commands available.
To get more help on a particular command, simply do `help command`.  For example:

    help set
    
Some commands take no arguments.  These are simple to use: just type them.
    
    stats

Some commands take an argument:

    load asm/fib/fib.bin
    reg a
    dump_ram 3
    exec 8801
    
Some commands work both with and without arguments, providing different modes of
interaction:

    reg
    reg b
    dump_ram
    dump_ram 3
    
Finally, a few commands take two arguments.

    set_reg a 32
    set_ram ffff 12

It should be noted that command names and register names are not case sensitive,
but file names are.  Also, whenever a command is expecting a number or a word,
the number is interpreted as hexadecimal, i.e. `set_reg a 32` will set A to 
32(base 16) = 50(base 10).

## Why?
Because I've never written something like this, and it looks like an approachable 
project.

I'll be happy when I can be assured that it works enough to perform some simple
calculations (i.e., Fibonacci number generation), and most likely won't be testing
it thoroughly.  There may be an assembler included with this, but that is unlikely.

It is my goal to have this emulator binary-compatible with a specifications-abiding
assembler.

## License
BSD Licensed
