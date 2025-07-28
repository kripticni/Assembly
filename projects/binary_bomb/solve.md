# Binary Bomb Lab

This is a part of OST2's course on [arch1001](https://apps.p.ost2.fyi/learning/course/course-v1:OpenSecurityTraining2+Arch1001_x86-64_Asm+2021_v1/)

I will be taking it in expert mode, with only gdb 
and with a stripped binary.

However it was originally made for CMU arch course.
To improve my writeup skills and note-taking I'll be
writing down the steps I take here.

## _start

As I want to learn the most at actual debugging,  
and reverse engineering, I'll be using the ghidra kit  
and also stripping the binary for increased difficulty.  

## Reconnaissance

Firstly, we'll strip our binary for added difficulty.  

```bash
$ strip bomb
$ file bomb
bomb: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=7dd166a66acce52fc6103bbf61a0c32b7e667841, for GNU/Linux 3.2.0, stripped
```

Having done that, I'll also read the elf for any  
kind of useful hints, see the readelf in readelf.txt  
I'll also checksec it and run strings  

```bash
readelf -a bomb > readelf.txt
strings bomb > strings.txt
checksec bomb
objdump -d bomb -Mintel > bomb.disas
```

**Readelf** gives us some nice hints by confirming
the use of:
puts, write alarm, close, read, fgets fopen, exit
sleep, stdin, stderr, stdout, memmove strtol, fflush, sprintf, socket
gethostbyname, signal, strcpy, getenv
OS/ABI: UNIX - System V
Clib: glibc
`Entry point address: 0x1360`
So now we know where to start and what to expect


**Strings** lets us know that gcc 9.3.0 was used,
it also lets us know that there is a weird GET request
for http, also these sites:
- [greatwhite.ics.cs.cmu.edu](greatwhite.ics.cs.cmu.edu)
- [angelshark.ics.cs.cmu.edu](angelshark.ics.cs.cmu.edu)
- [makoshark.ics.cs.cmu.edu](makoshark.ics.cs.cmu.edu)
Along with some error/success messages.
It also reveals that there are 6 phases.

**Checksec** gives us the following:
    Arch:       amd64-64-little
    RELRO:      Full RELRO
    Stack:      Canary found
    NX:         NX enabled
    PIE:        PIE enabled
    FORTIFY:    Enabled
    SHSTK:      Enabled
    IBT:        Enabled

Because I dont have enough experience with reverse
engineering, I first needed to find out what are
FORTITY and SHSTK

Its also my first time encountering a full relro binary
but I doubt I'll have to do anything with the global offset table

SHSTK, a shadow stack (sound familiar with the shadow store from MS)
its used for maintaining a separate stack that mirrors return addresses
if there is a mismatch (a overwrite of the return has occured) it 
instantly halts

## Phase 1

Since I'm now using Gentoo which complies to the FHS  
I'll no longer need to use distrobox for dynamic analysis  
as i once did on NixOS.  

Blindly running it also tells us there is 6 phases,
sending it a Ctrl+C gives us a message:
"So you think you can stop the bomb with ctrl-c, do you?
Well...OK. :-)"
This obviously means that it wasnt the right way to go 
about it (no suprises there) but it also reveals that
there is a signal handler in the binary.

The entry point of our binary is hardcoded into
the elf header, that we already found with readelf
is at 0x1360 aka .text

Also noticing ill need to do a lot of hex math
i found a project on github that has an implementation
of a hex calculator in python: [https://github.com/zachMelby/Hex_Calculator](https://github.com/zachMelby/Hex_Calculator)
But it ended up not working as I wanted it to, 
so I just decided to write my own, but I ended
up scraping it too in favor of improving at
hex math myself.

Looking down through .text
we can see that the first thing that is called is 
socket, but thats due to the disassembler 
giving misinformation due to no symbols

To start debugging a stripped binary we want to
run info file to see the entry point, then break
at the entry point and run the file, to see the 
next instructions we can only use the
x/<n>i $rip

To get to our main function we'll just
break on __libc_start_call_main, then 
we obtain 

```
Breakpoint 3, __libc_start_call_main (main=main@entry=0x555555555449, argc=argc@entry=1, argv=argv@entry=0x7fffffffbd98)
```

Break at the main addr main=main@entry=0x555555555449
from there we can disable the __libc_start_call_main breakpoint

From here on, I'll be using ghidra and making
a project instead of going at it with gdb and
raw assembly understanding.
