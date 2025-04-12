# Gnu Debugger

To select a file you simply need to put it as 
an cmdline argument, or input 
`file <filename>`

To start gdb with a core dump we use 
`gdb <program> <core dump>`
or before running
`core <file>`

For a symbol table
`symbol <file>`

To specify args ahead of time 
`gdb --args <program> <args...>`
or before running
`set args <args...>`


To attach to a running process 
`gdb --pid <pid>`
For choosing a thread which to operate on 
`thread <thread>`
or before running
`attach <pid>`
and to resume control
`detach`

To connect to a target machine, process, file
`target <type> <param>`

For exiting its either 
`quit`
or Ctrl + D

## Running

To run a binary you can use 
r, run 
start, to start at _start aka the entry point
by setting a temporary breakpoint there

To pass cmdline arguments you add them
to the end of your command for
starting ex: r arg1 arg2 arg3 ex: start 123

## Stoping

To terminate a binary you can either send it
a sigint with Ctrl + C (^C) while
its running or use 
kill, terminates the process

To take control you can do Ctrl + Z (^Z) 
to send a sigtstp to it

## Breaking

You can break simply using 
b <addr or symbol>, sets a breakpoint there
also workes for setting breakpoints at lines

To set a temporary breakpoint
tb <addr or symbol>
For breaking at regex
rb <regex>

Info a very valuable command that is used to 
inspect anything and everything, it
can be used to list breakpoints by doing 
i b, i breakpoints

## Watching/Catching

To set a watch point, for detecting changes 
in memory at certain addresses
wa <addr>, watch <addr>
This will use hardware watchpoint 
instead of a software one

To set a read/write watchpoint, we use 
awa <addr>, awatch 
For a read only, we
have rwa <addr>, rwatch

For handling catch events such as 
catch throw, exec, fork, vfork, load, unload
we use the
cat <event>

## Conditionals

Checks if a given condition is met when the 
given location is reached for any C
like expression b <addr> if <expression>

## Point management

To remove a point you have two options 
clear 
which removes a breakpoint at a specific address 
cl *0xffff 

Or using delete, to delete a specific numbered point 
d 1
delete with no argument removes all points

To temporarily disable and enable points 
dis <number> 
ena <number> 
(using en is also possible)

To ignore a point a number of times
ig <point number> <times>

## Stepping

Step over is nexti, n 
Step into is stepi, s 
Step out is finish, fi

To step until an address is reached is 
until <addr>, u <addr> 
however it also breaks
upon exiting the function

to continue a paused binary
c, continue

To force a function to return immediatly 
with passing a given value 
ret <value>, return <value>

To change rip and jump to an adress
j <addr or symbol>

## Redirection
Incredibly useful for running with
the gef (gdb extended functionality)

To use dev for stdio for next run
tty <dev>

To have files for io
run <in_file >out_file

## Signals

How to handle signals is decided only using one 
fairly long command handle 
ha <signal> <options>

Options: (no)print, (no)stop, (no)pass 
To print a message or not 
To stop or not at the signal 
To pass the signal to the program or not

We can also resume execution with a signal
sig <signal>, signal

## Code/Disasm

This is only available with debugging symbols 
being enabled so its only useful
when you already have the source

To add a directory where to search for sources 
dir <dir>, directory <dir>

l, lists surrounding code from rip 
l ., resets the showcase back to rip 
l <func>, shows the source of a func and the surrounding code 
l <source name>:<line number>, code surrounding that line 
l <first>:<last>, shows all lines between first and last

Disassembling on the other hand is always available 
disas <addr or symbol>, disassemble <addr or symbol>
disassembles the specified memory additionaly 
/r for raw bytes, 
/m for mixing,
with source code you can also stack them by doing /rm

set listsize <count>, sets how many lines to show per each list

## Examining

Firstly we need to know the format specifiers 
and also the unit sizes

| Format | Description                                                                                 |
| ------ | ------------------------------------------------------------------------------------------- |
| `x`    | Print as **hexadecimal**.                                                                   |
| `d`    | Print as **decimal** (signed).                                                              |
| `u`    | Print as **decimal** (unsigned).                                                            |
| `o`    | Print as **octal**.                                                                         |
| `t`    | Print as **binary** (`t` stands for "two").                                                 |
| `a`    | Print as an **address**, showing the symbol and offset (e.g., `0x54320 <_func+396>`).       |
| `c`    | Print as a **character constant** (numeric value + character). Non-ASCII printed as `\nnn`. |
| `f`    | Print as a **floating point number**.                                                       |
| `s`    | Print as a **string**, if possible (null-terminated or fixed-length arrays).                |
| `z`    | Print as **hex**, with **leading zeros** padded to the size of the type.                    |
| `r`    | Print using **raw formatting**, bypassing Python pretty-printers.                           |

| Unit | Size    | Description    |
| ---- | ------- | -------------- |
| `b`  | 1 byte  | **Byte**       |
| `h`  | 2 bytes | **Half-word**  |
| `w`  | 4 bytes | **Word**       |
| `g`  | 8 bytes | **Giant-word** |

To examine certain memory you can simply do 
x/<n><fmt><unit> <addr or symbol>
ex: x/10xg main

Alternatively for disassembly you can also use the examine command to look at
instructions 
x/<n>i <addr> shows you n instructions from the addr

For viewing registers you can once again use the info command 
i r, info registers

The print command is used for printing the value of any symbol/variable 
or even a single register 
p/x $rax 
p/u a

To see the type of a variable we do 
whatis <symbol>
Or for more detail
ptype <expr>

We can also use the show command to see values
show conv
show values <n>

The display/format command is used to get information every 
time the program is stopped 
To see a number of instructions like this 
disp/<n>i <instruction pointer for arch> 
ex: disp/16i $rsp 
ex: disp/16i $pc

List with i disp,
To remove a display is undisp

To see the mappings in memory
info proc mappings

## Stack

To setup an updating stack view, we can also use the display 
disp/10xg $rsp

To get a call stack we use the backtrace command 
bt, backtrace

To get the entire call stack 
whe, where

To get the call stack and variables 
whe full, where full 
bt full, backtrace full

To get the information about a certain stack frame 
f <num>, frame <num>

To see the saved registers, arglist, locals pervious frame...
i f, info frame 
possibly the most important command

to go up or down n frames
up <n>
down <n>

## Modifying

For registers we use the set command 
set $rax = 0xface

For modifying memory we also use the set command with a C-style 
type and all of its values are zero extended 
set {long long}$rsp = 0x13371337

## Preferences

To disable the use of ABI register names for Risc-V we can do set
disassembler-options numeric also for pseudo-instructions aka aliases set
disassembler-options no-aliases

## Sources

- [OpenSecurityTraining2 – Debuggers 1012: Introductory GDB](https://apps.p.ost2.fyi/learning/course/course-v1:OpenSecurityTraining2+Dbg1012_IntroGDB+2024_v1/home)
- [Marc Haisenko's GDB Cheat Sheet](https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf)
- [UTexas GDB Reference Card](https://users.ece.utexas.edu/~adnan/gdb-refcard.pdf)
