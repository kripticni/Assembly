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

## Getting to main 

After making a ghidra project and analysing the stripped binary  
ive noticed that it still hasn't fully resolved all symbols.

Going straight to the entry point which we already know, we can  
check the first few functions and notice that they are decoys that  
call nothing at all.  

Along the way I also learned that about the elf structure.
FINI is whats called after main for cleanup purposes, also known as destructor code.  
INIT is the equivalent for constructing, before main.
Also symbols for DT_INIT and DT_FINI are simply dynamic tags to these functions.
The entry point is the first instruction to be executed in a program and is  
used by the OS loader.

However in modern glibc, init is always null (but executed if not null) and  
fini is completely unused.

There is also things to learn from glibc,  
starting with __libc_start_main.

```c
int __libc_start_main(
  int (*main)(int, char**, char**),
  int argc,
  char **ubp_av,
  void (*init)(void),
  void (*fini)(void),
  void (*rtld_fini)(void),
  void *stack_end
);
```
Obviously we provide the address of main, argc and argv (by an unbounded pointer)  
there is also an optional auxiliary vector for kernel related stuff.  
There is rtld_fini which is used which is a cleanup provided by the dynamic  
linker, stack_end which is the lowest address on the stack.


```asm
        00101373 4c 8d 05        LEA        R8,[FUN_00102a80]
                 06 17 00 00
        0010137a 48 8d 0d        LEA        RCX,[FUN_00102a10]
                 8f 16 00 00
        00101381 48 8d 3d        LEA        RDI,[FUN_00101449]
                 c1 00 00 00
        00101388 ff 15 52        CALL       qword ptr [-><EXTERNAL>::__libc_start_main]      undefined __libc_start_main()
                 3c 00 00                                                                    = 00106050

```

For this I'll remind you the argument registers for System V ABI.  
In order: RDI, RSI, RDX, RCX, R8, R9
From this and the function signature/declaration we can conclude that  
our main function is indeed FUN_00101449

From here I renamed the function to name and changed its definition accordingly

```c
int main(int argc,char **argv)

{
  char *pcVar1;
  
  if (argc == 1) {
    DAT_00105698 = stdin;
  }
  else {
    if (argc != 2) {
      __printf_chk(1,"Usage: %s [<input_file>]\n",*argv);
                    /* WARNING: Subroutine does not return */
      exit(8);
    }
    DAT_00105698 = fopen(argv[1],"r");
    if (DAT_00105698 == (FILE *)0x0) {
      __printf_chk(1,"%s: Error: Couldn\'t open %s\n",*argv,argv[1]);
                    /* WARNING: Subroutine does not return */
      exit(8);
    }
  }
  FUN_00101b31();
  puts("Welcome to my fiendish little bomb. You have 6 phases with");
  puts("which to blow yourself up. Have a nice day!");
  pcVar1 = FUN_00101c56();
  FUN_001015a7(pcVar1);
  FUN_00101d9e();
  puts("Phase 1 defused. How about the next one?");
  pcVar1 = FUN_00101c56();
  FUN_001015cb(pcVar1);
  FUN_00101d9e();
  puts("That\'s number 2.  Keep going!");
  pcVar1 = FUN_00101c56();
  FUN_00101639(pcVar1);
  FUN_00101d9e();
  puts("Halfway there!");
  pcVar1 = FUN_00101c56();
  FUN_0010174b(pcVar1);
  FUN_00101d9e();
  puts("So you got that one.  Try this one.");
  pcVar1 = FUN_00101c56();
  FUN_001017c4(pcVar1);
  FUN_00101d9e();
  puts("Good work!  On to the next...");
  pcVar1 = FUN_00101c56();
  FUN_0010185b(pcVar1);
  FUN_00101d9e();
  return 0;
}
```

This seems to be the main hub where everything will happen,  
however maybe there could be a function that never returns  
and leads us elsewhere.  

```c
  if (argc == 1) {
    input = stdin;
  }
  else {
    if (argc != 2) {
      __printf_chk(1,"Usage: %s [<input_file>]\n",*argv);
                    /* WARNING: Subroutine does not return */
      exit(8);
    }
    input = fopen(argv[1],"r");
    if (input == (FILE *)0x0) {
      __printf_chk(1,"%s: Error: Couldn\'t open %s\n",*argv,argv[1]);
                    /* WARNING: Subroutine does not return */
      exit(8);
    }
  }
```

This part is clearly used to setup where input will be read from,  
if the only argument is the filename itself, then input is stdin  
if there is another argument, that argument is the file to read from.  


## Phase 1

The first function call in main, it just calls the signal  
function which sets up a signal trap of X signal to call Y function.  

And the Y function is just telling us that we cannot disarm the bomb  
using Ctrl+C, so i named it sigtrap_ctrl-c.

The next function returns a string (char*), and at the beginning  
it sets up 5 variables.
```c
  char cVar1;
  char *pcVar2;
  long lVar3;
  long lVar4;
  byte bVar5;
  
  bVar5 = 0;
  pcVar2 = FUN_00101b93();
```

Lets go down the stack and analyze the function it calls,  
```c
char * FUN_00101b93(void)

{
  char *pcVar1;
  undefined8 uVar2;
  
  do {
    pcVar1 = fgets(&DAT_001056a0 + (long)DAT_00105690 * 0x50,0x50,input);
    if (pcVar1 == (char *)0x0) {
      return (char *)0x0;
    }
    uVar2 = FUN_00101b54(pcVar1);
  } while ((int)uVar2 != 0);
  return pcVar1;
}
```

```c
input_string = fgets(&input_string_array + (long)DAT_00105690 * 0x50,0x50,input);
```

Here, input_string_array seems to obviously be an array of strings with each string  
occupying 16*5 bytes, for a total of 80 bytes and DAT_00105690 seems to be the index?
Upon further review we can see that it is a global integer which means its initialized
to zero, so its safe to assume that this stores 80 bytes into the first index of the

sarray (string array)
```asm
DAT_00105690                                    XREF[6]:     FUN_00101b93:00101ba4(R), 
                                                FUN_00101c56:00101c6d(R), 
                                                FUN_00101c56:00101cce(W), 
                                                FUN_00101c56:00101d60(R), 
                                                FUN_00101c56:00101d69(W), 
                                                FUN_00101d9e:00101db6(R)  
```
If we find an error or EOF in fgets we'll return null, in other case we return  
input string.

```c
  do {
    input_string = fgets(&input_string_array + (long)sarray_index * 0x50,0x50,input);
    if (input_string == (char *)0x0) {
      return (char *)0x0;
    }
    uVar1 = FUN_00101b54(input_string);
  } while ((int)uVar1 != 0);
  return input_string;
```

Now this calls into a function 00101b54, which seems to be an implementation of  
some sort of isdigit/isalpha... function, since the use of __ctype_b_loc which
provide the character classification data which is a bitmask array even though
the underlying variable is a double pointer, it ultimately resolves to a pointer
to the threads threadsafe byte bitmask array for character classification data.
We can also see that it goes into a while loop which goes through the entire
string until a null byte is found at which it returns 1.

```c
long FUN_00101b54(char *str_arg)

{
  ushort **character_classification_data;
  char current_character;
  
  do {
    current_character = *str_arg;
    if (current_character == '\0') {
      return 1;
    }
    character_classification_data = __ctype_b_loc();
    str_arg = str_arg + 1;
  } while ((*(byte *)((long)*character_classification_data + (long)current_character * 2 + 1) & 0x20
           ) != 0);
  return 0;
}
```

Now the while loop is interesting, we can obviously see that it first dereferences  
the double pointer to get array address, and from there it does pointer arithmetic to  
get the correct index for the character, since we are doing byte arithmetic we need to  
multiply the integer by two and add 1 to access the 2nd byte of the 2-byte long short.

Now we'll go into the glibc ctype.h to see what the 0x20 represents.
But first we need to find which version of glibc is used.
(this is also doable in ghidra by searching to defined strings)
```bash
$ strings bomb | grep -i glibc
GLIBC_2.3
GLIBC_2.7
GLIBC_2.3.4
GLIBC_2.4
GLIBC_2.2.5
```

Then we'll go into the [GLIBC source code explorer](https://elixir.bootlin.com/glibc/glibc-2.2.5/source/ctype/ctype.h).
Also check for 2.7 to see if there was any changes.
```c
# include <endian.h>
# if __BYTE_ORDER == __BIG_ENDIAN
#  define _ISbit(bit)	(1 << (bit))
# else /* __BYTE_ORDER == __LITTLE_ENDIAN */
#  define _ISbit(bit)	((bit) < 8 ? ((1 << (bit)) << 8) : ((1 << (bit)) >> 8))
# endif

enum
{
  _ISupper = _ISbit (0),	/* UPPERCASE.  */
  _ISlower = _ISbit (1),	/* lowercase.  */
  _ISalpha = _ISbit (2),	/* Alphabetic.  */
  _ISdigit = _ISbit (3),	/* Numeric.  */
  _ISxdigit = _ISbit (4),	/* Hexadecimal numeric.  */
  _ISspace = _ISbit (5),	/* Whitespace.  */
  _ISprint = _ISbit (6),	/* Printing.  */
  _ISgraph = _ISbit (7),	/* Graphical.  */
  _ISblank = _ISbit (8),	/* Blank (usually SPC and TAB).  */
  _IScntrl = _ISbit (9),	/* Control character.  */
  _ISpunct = _ISbit (10),	/* Punctuation.  */
  _ISalnum = _ISbit (11)	/* Alphanumeric.  */
};
```
And see that that classification calls a macro to set the bitmask of
the space.
So we can see that ISspace is the 0x20 flag.
That loop reads all the whitespace.
And the function returns 1 if the argument string is only whitespace,  
but if there is a character that isnt whitespace, it returns 0.
Hence we'll call the function has_only_spaces.
The entire function keeps reading into the same address  
80 bytes at a time until there is a non space string.
We'll call it first_nonspace_string_from_input, but its  
important to remember that it also saves the string into  
the string_array.

```c
char * first_nonspace_string_from_input(void)

{
  char *input_string;
  long only_spaces;
  
  do {
    input_string = fgets(&input_string_array + (long)sarray_index * 0x50,0x50,input);
    if (input_string == (char *)0x0) {
      return (char *)0x0;
    }
    only_spaces = has_only_spaces(input_string);
  } while ((int)only_spaces != 0);
  return input_string;
}
```

Now we can return down the stack to our pervious function.

```c
  input_string = first_nonspace_string_from_input();
  if (input_string == (char *)0x0) {
    if (input == stdin) {
      puts("Error: Premature EOF on stdin");
                    /* WARNING: Subroutine does not return */
      exit(8);
    }
    input_string = getenv("GRADE_BOMB");
    if (input_string != (char *)0x0) {
                    /* WARNING: Subroutine does not return */
      exit(0);
    }
    input = stdin;
    input_string = first_nonspace_string_from_input();
    if (input_string == (char *)0x0) {
      puts("Error: Premature EOF on stdin");
                    /* WARNING: Subroutine does not return */
      exit(0);
    }
  }
```

This checks if input string is null which only happens
when we have a premature EOF or error in fgets  
(or only whitespace strings), but it also reads from  
the environment variable GRADE_BOMB.
So if there was an null on input_string but not from
stdin it reads GRADE_BOMB and exists if its also NULL,
if its not NULL then it switches to stdin and checks for
NULL again.

```c
  lVar2 = (long)sarray_index;
  lVar3 = -1;
  input_string = &input_string_array + lVar2 * 0x50;
  do {
    if (lVar3 == 0) break;
    lVar3 = lVar3 + -1;
    cVar1 = *input_string;
    input_string = input_string + (ulong)bVar4 * -2 + 1;
  } while (cVar1 != '\0');
  if ((int)(~(uint)lVar3 - 1) < 0x4f) {
    (&input_string_array)[(long)(int)(~(uint)lVar3 - 2) + (long)sarray_index * 0x50] = 0;
    sarray_index = sarray_index + 1;
    return &input_string_array + lVar2 * 0x50;
  }
  puts("Error: Input line too long");
  lVar2 = (long)sarray_index;
  sarray_index = sarray_index + 1;
  *(undefined8 *)(&input_string_array + lVar2 * 0x50) = 0x636e7572742a2a2a;
  *(undefined8 *)(&DAT_001056a8 + lVar2 * 0x50) = 0x2a2a2a64657461;
                    /* WARNING: Subroutine does not return */
  FUN_00101be5();
}
```

Suspecting some weird activity with sarray_index I went to try
some dynamic analysis with the debugger, however it was not working
on my system, because of an issue with the pentoo-overlay.
You can see my fix here (pentoo-overlay issue #2469)[https://github.com/pentoo/pentoo-overlay/pull/2469].

Running into the next code blocks, I've noticed this strange code that is basically a noop
```c
  l_sarray_index = (long)sarray_index;
  lVar2 = -1;
  // input_string was already input_string = fgets(&input_string_array + (long)sarray_index * 0x50,0x50,input);
  input_string = &input_string_array + l_sarray_index * 0x50;
```

Then we have this loop.

```c
  do {
    if (lVar2 == 0) break;
    lVar2 = lVar2 + -1;
    cVar1 = *input_string;
    input_string = input_string + (ulong)bVar3 * -2 + 1;
  } while (cVar1 != '\0');
```

This makes it pretty clear that lVar2 was  
some sort of a counter/index that was initialized to -1 so that
the loop could start, why the first if isnt put in as a condition
into the while loop is a mystery to me, but i can imagine that its
something to do with how the code gets compiled and then later
decompiled. Looking into it, lVar2 is only setup here
to get used further down the code and the if statement is useless.

lVar2 stores the negative strlen - 1.
cVar2 is the current character processed by the loop.
bVar3 is a literal zero.

So the product of the loop is a literal negative strlen negative 1.

Next we have this if statement.
```c
  if ((int)(~(uint)neglen_neg1 - 1) < 0x4f) {
    (&input_string_array)[(long)(int)(~(uint)neglen_neg1 - 2) + (long)sarray_index * 0x50] = 0;
    sarray_index = sarray_index + 1;
    return &input_string_array + l_sarray_index * 0x50;
  }
```
The first part basically converts the negative number (2s complement)
to a positive number and then checks if its less than 79 but considering
the that the strlen starts with -1 for the null terminator, its len - 1 < 79 or len < 80.

The first line indexes the first character before the null terminator and
replaces it with the null terminator, effectively cutting off the string a character early.
Then it also updates the sarray_index to 1 instead of 0.
After that it returns the same address of input_string_array since l_sarray_index is still zero.

```c
  puts("Error: Input line too long");
  l_sarray_index = (long)sarray_index;
  sarray_index = sarray_index + 1;
  *(undefined8 *)(&input_string_array + l_sarray_index * 0x50) = 0x636e7572742a2a2a;
  *(undefined8 *)(&DAT_001056a8 + l_sarray_index * 0x50) = 0x2a2a2a64657461;
                    /* WARNING: Subroutine does not return */
  FUN_00101be5();
```
In case its bigger than 79, it changes the string to truncated, we can see that
DAT_001056a8 is just input_string_array + 0x8 in the disassembly which lines it up.
The function it calls simply blows up the bomb, I named it blow_up.

The entire function FUN_00101c56, simply validates input by making sure there
is at least one character thats not a whitespace in an input string and the 
input we already know can be stdin or a file, then it checks for the string
to be less than 79 characters long. Because the input string array only 
reserves 80 bytes for each string.

Going back to main we have a really short function.
```c
void FUN_001015a7(char *param_1)

{
  undefined8 uVar1;
  
  uVar1 = FUN_00101ad1(param_1,"I am just a renegade hockey mom.");
  if ((int)uVar1 == 0) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  blow_up();
}
```

This calls another bool function and if it doesnt return
with 0, it blows up.

```c
undefined8 FUN_00101ad1(char *input_string,char *arg_string)

{
  int iVar1;
  int iVar2;
  undefined8 uVar3;
  long lVar4;
  char cVar5;
  
  iVar1 = FUN_00101ab0(input_string);
  iVar2 = FUN_00101ab0(arg_string);
  uVar3 = 1;
  if (iVar1 == iVar2) {
    cVar5 = *input_string;
    if (cVar5 == '\0') {
      uVar3 = 0;
    }
    else {
      lVar4 = 0;
      do {
        if (arg_string[lVar4] != cVar5) {
          return 1;
        }
        lVar4 = lVar4 + 1;
        cVar5 = input_string[lVar4];
      } while (cVar5 != '\0');
      uVar3 = 0;
    }
  }
  return uVar3;
}
```

This calls a function for both input_string and arg_string, im assuming
it is strlen but lets check.

```c
int strlen(char *string)

{
  int counter;
  
  if (*string != '\0') {
    counter = 0;
    do {
      string = string + 1;
      counter = counter + 1;
    } while (*string != '\0');
    return counter;
  }
  return 0;
}
```
Its exactly strlen.
This lets us know that iVar1 and iVar2 are actually input_len and arg_len.
If they are not the same length the program exits early with an error so we can assume
this simply checks for equality (strcmp), cVar3 is also an current_char again.
uVar1 is our exit code or status since thats what is returned, ill call it is_not_equal.
The first if checks if the first char is null and if so returns 0 (wanted result) but this
is basically a noop for us because it could never occur that they are of the same non-zero length
and that the input_string starts with null, its useful in a case where both are 0 or 1 sized.
Then the else case with the while loop simply checks for equality of each character until null,
we can conclude that this is a strcmp.

That solves the second function to 
```c
void is_input_string_correct_string(char *input_string)

{
  undefined8 flag;
  
  flag = strcmp(input_string,"I am just a renegade hockey mom.");
  if ((int)flag == 0) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  blow_up();
}
```

For now we know that our first string must be "I am just a renegade hockey mom."
and that we can input it through a file or stdin based on argv.
Putting this into the program tells us that we've solved phase 1!

```bash
$ ./bomb
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
I am just a renegade hockey mom.
Phase 1 defused. How about the next one?
```

## Phase 2

First off we find a function call after phase one, its the secret phase
that I'll be looking into later on.

```c
void secret_phase(void)

{
  int iVar1;
  undefined8 uVar2;
  long in_FS_OFFSET;
  undefined1 local_70 [4];
  undefined1 local_6c [4];
  char local_68 [88];
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  if (sarray_index == 6) {
    iVar1 = __isoc99_sscanf(&DAT_00105790,"%d %d %s",local_70,local_6c,local_68);
    if (iVar1 == 3) {
      uVar2 = strcmp(local_68,"DrEvil");
      if ((int)uVar2 == 0) {
        puts("Curses, you\'ve found the secret phase!");
        puts("But finding it and solving it are quite different...");
        FUN_001019c4();
      }
    }
    puts("Congratulations! You\'ve defused the bomb!");
  }
  if (local_10 == *(long *)(in_FS_OFFSET + 0x28)) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  __stack_chk_fail();
}
```

This is unimportant for now, but it does reuse a lot of functions
we've already been over.

Now we validate input again, but considering sarray_index was incremented
last time, now this will store the second string 80 bytes from the first, correctly.

```c
void phase2(undefined8 param_1)

{
  int *piVar1;
  long in_FS_OFFSET;
  int local_38 [6];
  long local_20;
  
  piVar1 = local_38;
  local_20 = *(long *)(in_FS_OFFSET + 0x28);
  FUN_00101c11(param_1,(long)local_38);
  if (local_38[0] != 1) {
                    /* WARNING: Subroutine does not return */
    blow_up();
  }
  do {
    if (piVar1[1] != *piVar1 * 2) {
                    /* WARNING: Subroutine does not return */
      blow_up();
    }
    piVar1 = piVar1 + 1;
  } while (piVar1 != local_38 + 5);
  if (local_20 == *(long *)(in_FS_OFFSET + 0x28)) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  __stack_chk_fail();
}
```

Here we see that local_38[6] is an integer array, and piVar1 is
a pointer to the beginning of the array.
in_FS_OFFSET is referring to the FS segment register, basically
the only segment registers used these days are FS and GS, they
are used for thread_local storage, stack canaries and security data,
and thread control blocks, as in pointers to main memory.
The FS and GS are set by the os kernel and you access their contents
via offsets.

In this case since we are having offset 0x28 for FS, after readin:
from the internet, can be sure that it stores the stack canary.

Going further down the stack into the checking function.

```c

void FUN_00101c11(char *input_string,int *array)

{
  int len;
  
  len = __isoc99_sscanf(input_string,"%d %d %d %d %d %d",array,array + 1,array + 2,array + 3,
                        array + 4,array + 5);
  if (5 < len) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  blow_up();
}
```

sscanf applies scanf on the input_string and reads into the array, if there is less than
5 variables succesfully assigned it blows up, so it requires more than 6 or in this case
exactly 6 since we cant get any more.

Going back down the stack to our phase2 function we can resolve the following.

```c
void phase2(char *input_string)

{
  int *array_ptr;
  long in_FS_OFFSET;
  int array [6];
  long stack_canary;
  
  array_ptr = array;
  stack_canary = *(long *)(in_FS_OFFSET + 0x28);
  string_to_iarray_of_6(input_string,array);
  if (array[0] != 1) {
                    /* WARNING: Subroutine does not return */
    blow_up();
  }
  do {
    if (array_ptr[1] != *array_ptr * 2) {
                    /* WARNING: Subroutine does not return */
      blow_up();
    }
    array_ptr = array_ptr + 1;
  } while (array_ptr != array + 5);
  if (stack_canary == *(long *)(in_FS_OFFSET + 0x28)) {
    return;
  }
                    /* WARNING: Subroutine does not return */
  __stack_chk_fail();
}
```

Here we can see that array[0] must be 1.
Then we loop from the beginning of the array to the end, 
and each time the next element must be the last times 2 so,
solution is: 1 2 4 8 16 32

## Phase 3

This tries to look obfuscated and complicated but it truly isnt.

```c
void phase3(char *input_string)

{
  int scan_success;
  long in_FS_OFFSET;
  int decision;
  int value;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  scan_success = __isoc99_sscanf(input_string,"%d %d",&decision,&value);
  if (scan_success < 2) {
                    /* WARNING: Subroutine does not return */
    blow_up();
  }
  switch(decision) {
  case 0:
    scan_success = 0x274;
    break;
  case 1:
    scan_success = 0;
    break;
  case 2:
    scan_success = 0;
    goto LAB_00101699;
  case 3:
    scan_success = 0;
    goto LAB_0010169e;
  case 4:
    scan_success = 0;
    goto LAB_001016a1;
  case 5:
    scan_success = 0;
    goto LAB_001016a4;
  case 6:
    scan_success = 0;
    goto LAB_001016a7;
  case 7:
    scan_success = 0;
    goto LAB_001016aa;
  default:
                    /* WARNING: Subroutine does not return */
    blow_up();
  }
  scan_success = scan_success + -0x24c;
LAB_00101699:
  scan_success = scan_success + 0x2b0;
LAB_0010169e:
  scan_success = scan_success + -0x7e;
LAB_001016a1:
  scan_success = scan_success + 0x7e;
LAB_001016a4:
  scan_success = scan_success + -0x7e;
LAB_001016a7:
  scan_success = scan_success + 0x7e;
LAB_001016aa:
  if ((decision < 6) && (value == scan_success + -0x7e)) {
    if (local_10 != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
      __stack_chk_fail();
    }
    return;
  }
                    /* WARNING: Subroutine does not return */
  blow_up();
}
```

The end conditions contrained by the switch require for decision
to less than 6, going to condition 5 simply has it be zero and 
in the later if we simply have to have value = -0x7e which is
-126, simple as that.

Solution: 5 -126

## Phase 4

This seems to be pretty simple. At this point it doesnt even
feel like a stripped binary anymore, I believe we know most
symbols.

```c
void phase4(char *input_string)

{
  int scan_success;
  long in_FS_OFFSET;
  uint local_18;
  int local_14;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  scan_success = __isoc99_sscanf(input_string,"%d %d",&local_18,&local_14);
  if ((scan_success != 2) || (0xe < local_18)) {
                    /* WARNING: Subroutine does not return */
    blow_up();
  }
  scan_success = FUN_00101715(local_18,0,0xe);
  if ((scan_success == 10) && (local_14 == 10)) {
    if (local_10 == *(long *)(in_FS_OFFSET + 0x28)) {
      return;
    }
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
                    /* WARNING: Subroutine does not return */
  blow_up();
}
```

First of all lets ignore in_FS_OFFSET since that is for the stack canary.
local_18 has to be <= 0xe which is 14, and then we go down the stack, lets see.
Now this is a recursive function.

```c
int FUN_00101715(int param_1,undefined8 param_2,int param_3)

{
  int iVar1;
  int iVar2;
  
  iVar2 = (param_3 - (int)param_2) / 2 + (int)param_2;
  if (param_1 < iVar2) {
    iVar1 = FUN_00101715(param_1,param_2,iVar2 + -1);
    iVar2 = iVar2 + iVar1;
  }
  else if (iVar2 < param_1) {
    iVar1 = FUN_00101715(param_1,(ulong)(iVar2 + 1),param_3);
    iVar2 = iVar2 + iVar1;
  }
  return iVar2;
}
```

We can recognize some sort of a recursive sum for a binary search
from 0 to 14 here, I'll make a simple C program to help with this.
The program can be found in `./helper/binary_search_sum.c`.

```bash
projects/binary_bomb/helper main
$ gcc binary_search_sum.c

projects/binary_bomb/helper main
$ ./a.out
0 -> 11
1 -> 11
2 -> 13
3 -> 10
4 -> 19
5 -> 15
6 -> 21
7 -> 7
8 -> 35
9 -> 27
10 -> 37
11 -> 18
12 -> 43
13 -> 31
```

Here we see that the only right answer is 3,
simple enough the solution is: 3 10

## Phase 5

Here is the function, I'll resolve what I can before putting
it into here.

```c
void phase5(char *input_string)

{
  int sum;
  int counter;
  long in_FS_OFFSET;
  uint index;
  int match_sum;
  long local_10;
  
  local_10 = *(long *)(in_FS_OFFSET + 0x28);
  sum = __isoc99_sscanf(input_string,"%d %d",&index,&match_sum);
  if (sum < 2) {
                    /* WARNING: Subroutine does not return */
    blow_up();
  }
  index = index & 0xf;
  if (index != 0xf) {
    sum = 0;
    counter = 0;
    do {
      counter = counter + 1;
      index = *(uint *)(&DAT_001031c0 + (long)(int)index * 4);
      sum = sum + index;
    } while (index != 0xf);
    index = 0xf;
    if ((counter == 0xf) && (match_sum == sum)) {
      if (local_10 == *(long *)(in_FS_OFFSET + 0x28)) {
        return;
      }
                    /* WARNING: Subroutine does not return */
      __stack_chk_fail();
    }
  }
                    /* WARNING: Subroutine does not return */
  blow_up();
}
```

A really interesting thing is the DAT_001031c0 which is some sort of array we know 
nothing about, so we'll use the `G` shortcut to go to it, and then open bytes view
to see what it hold.

0a 00 00 00 02 00 00 00
0e 00 00 00 07 00 00 00
08 00 00 00 0c 00 00 00
0f 00 00 00 0b 00 00 00
00 00 00 00 04 00 00 00
01 00 00 00 0d 00 00 00
03 00 00 00 09 00 00 00
06 00 00 00 05 00 00 00

This is also 10, 2, 14, 7, 8, 12, 15, 11, 0, 4, 1, 13, 3, 9, 6, 5
Which is also why there is a check for having to not be 0xf and
for it being anded with 0xf (which means it has to be less than 0xf).

The loop requires us to exit with counter being 15, so 15 repetitions
and the loop ends when index becomes 15. So we need to find how to
get to index equal to 15 in 15 turns.

For this we simply write a helper C program, find it in `./helper/randomizer_sum.c`.
Another solution would be to write a topological sort.

## Phase 6

I'll split this into two parts, here is the first.

```c
void phase6(char *input_string)

{
  int iVar1;
  int *array_ptr;
  long j;
  long i;
  long in_FS_OFFSET;
  int array [8];
  int *local_68;
  long local_60;
  long local_58;
  long local_50;
  long local_48;
  long local_40;
  long stack_canary;
  
  array_ptr = array;
  stack_canary = *(long *)(in_FS_OFFSET + 0x28);
  string_to_iarray_of_6(input_string,array);
  i = 1;
  while( true ) {
    if (5 < *array_ptr - 1U) {
                    /* WARNING: Subroutine does not return */
      blow_up();
    }
    j = i;
    if (5 < (int)i) break;
    do {
      if (*array_ptr == array[j]) {
                    /* WARNING: Subroutine does not return */
        blow_up();
      }
      j = j + 1;
    } while ((int)j < 6);
    i = i + 1;
    array_ptr = array_ptr + 1;
  }
  i = 0;
```

Even tho the array can store 8 ints, so far we only
store 6 from our string.

Each of the first 6 values in the array cannot be more than 6,
and no two values can be equal.

Here is the second part.

```c
  do {
    iVar1 = 1;
    array_ptr = (int *)&DAT_00105200;
    if (1 < array[i]) {
      do {
        array_ptr = *(int **)(array_ptr + 2);
        iVar1 = iVar1 + 1;
      } while (iVar1 != array[i]);
    }
    (&local_68)[i] = array_ptr;
    i = i + 1;
  } while (i != 6);
  *(long *)(local_68 + 2) = local_60;
  *(long *)(local_60 + 8) = local_58;
  *(long *)(local_58 + 8) = local_50;
  *(long *)(local_50 + 8) = local_48;
  *(long *)(local_48 + 8) = local_40;
  *(undefined8 *)(local_40 + 8) = 0;
  iVar1 = 5;
  do {
    if (*local_68 < **(int **)(local_68 + 2)) {
                    /* WARNING: Subroutine does not return */
      blow_up();
    }
    local_68 = *(int **)(local_68 + 2);
    iVar1 = iVar1 + -1;
  } while (iVar1 != 0);
  if (stack_canary != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return;
}
```

This reads from DAT_00105200, which stores an array of {530, 1}.
So array_ptr is practically moves to a different array.

If array[i] is more than 1, array_ptr moves 2 ints forward
and iVar1 gets increased by 1 while they are unequal.
local_68 gets reassigned constantly but finally settles down
on array[5].

After looking deeper into the code structure we can figure out
that this is infact using a long with weird pointer arithmetic
instead of an actual structure, we can fix this by setting up
a ghidra structure and retyping the variables.

```c
typedef struct node{
  int value;
  int index;
  struct node* next;
}Node;
```

After that the code is infinitely more readable.

```c
void phase6(char *input_string)

{
  int node_index;
  node *node_ptr;
  long j;
  int *array_ptr;
  long i;
  long in_FS_OFFSET;
  int array [8];
  node *node1;
  node *node2;
  node *node3;
  node *node4;
  node *node5;
  node *node6;
  long stack_canary;
  
  array_ptr = array;
  stack_canary = *(long *)(in_FS_OFFSET + 0x28);
  string_to_iarray_of_6(input_string,array);
  i = 1;
  while( true ) {
    if (5 < *array_ptr - 1U) {
                    /* WARNING: Subroutine does not return */
      blow_up();
    }
    j = i;
    if (5 < (int)i) break;
    do {
      if (*array_ptr == array[j]) {
                    /* WARNING: Subroutine does not return */
        blow_up();
      }
      j = j + 1;
    } while ((int)j < 6);
    i = i + 1;
    array_ptr = array_ptr + 1;
  }
  i = 0;
  do {
    node_index = 1;
    node_ptr = (node *)&DAT_00105200;
    if (1 < array[i]) {
      do {
        node_ptr = node_ptr->next;
        node_index = node_index + 1;
      } while (node_index != array[i]);
    }
    (&node1)[i] = node_ptr;
    i = i + 1;
  } while (i != 6);
  node1->next = node2;
  node2->next = node3;
  node3->next = node4;
  node4->next = node5;
  node5->next = node6;
  node6->next = (node *)0x0;
  node_index = 5;
  do {
    if (node1->value < node1->next->value) {
                    /* WARNING: Subroutine does not return */
      blow_up();
    }
    node1 = node1->next;
    node_index = node_index + -1;
  } while (node_index != 0);
  if (stack_canary != *(long *)(in_FS_OFFSET + 0x28)) {
                    /* WARNING: Subroutine does not return */
    __stack_chk_fail();
  }
  return;
}
```

The last checks simply require us to order the linked list in
such a way for it to be sorted in descending order so that
the bomb doesnt explode.
I wont be writing a helper program for this since its trivially
easy to sort the values from smallest to biggest by hand.

After defining the correct data types to the program memory we can
read that the values of the nodes are:
1: 212h
2: 1C2h
3: 215h
4: 393h
5: 3A7h
6: 200h

Solution: 5 4 3 1 6 2
