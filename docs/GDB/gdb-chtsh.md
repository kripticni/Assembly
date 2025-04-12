# GNU Debugger (GDB) Reference

## Starting GDB

| Command | Description |
|--------|-------------|
| `gdb <file>` | Start GDB with a program. |
| `gdb <program> <core dump>` | Start GDB with core dump. |
| `core <file>` | Load a core dump into GDB. |
| `symbol <file>` | Load a symbol table. |
| `gdb --args <program> <args...>` | Start GDB with arguments. |
| `set args <args...>` | Set arguments within GDB. |
| `gdb --pid <pid>` | Attach to a running process. |
| `attach <pid>` | Attach to a process by PID. |
| `detach` | Detach from a process. |
| `target <type> <params>` | Connect to a target (machine, process, file). |
| `quit` or `Ctrl+D` | Exit GDB. |

## Running Programs

| Command | Description |
|---------|-------------|
| `run`, `r` | Run the program. |
| `start` | Start at program entry point. |
| `start <args>` | Start with command-line arguments. |

## Stopping Execution

| Command | Description |
|---------|-------------|
| `Ctrl+C` | Send SIGINT to stop execution. |
| `kill` | Terminate the program. |
| `Ctrl+Z` | Send SIGTSTP (pause). |

## Breakpoints

| Command | Description |
|---------|-------------|
| `b <addr/symbol>` | Set a breakpoint. |
| `tb <addr/symbol>` | Set a temporary breakpoint. |
| `rb <regex>` | Set a breakpoint by regex. |
| `i b` or `info breakpoints` | Show breakpoints. |

## Watchpoints / Catchpoints

| Command | Description |
|---------|-------------|
| `watch <addr>` | Watch for changes to memory. |
| `awatch <addr>` | Watch for read/write access. |
| `rwatch <addr>` | Watch for read access. |
| `catch <event>` | Catch events like `throw`, `exec`, etc. |

## Conditional Breakpoints

| Command | Description|
|---------|------------|
|`b <loc> if <expr>`| Checks if a condition at loc is met for any C expr |


## Managing Breakpoints

| Command | Description |
|---------|-------------|
| `clear` or `clear *<addr>` | Remove breakpoint at location. |
| `delete <num>` | Delete a breakpoint. |
| `delete` | Delete all breakpoints. |
| `disable <num>` | Disable breakpoint. |
| `enable <num>` | Enable breakpoint. |
| `ignore <num> <count>` | Ignore breakpoint N times. |

## Stepping Through Code

| Command | Description |
|---------|-------------|
| `n`, `nexti` | Step over. |
| `s`, `stepi` | Step into. |
| `finish`, `fi` | Step out. |
| `u <addr>` | Step until address (or until return). |
| `c`, `continue` | Resume execution. |
| `return <val>` | Force function to return. |
| `jump <addr>` | Set instruction pointer (RIP). |

## Redirection

| Command | Description |
|---------|-------------|
| `tty <device>` | Set device for stdio. |
| `run < <input >output` | Redirect input/output. |

## Signal Handling

| Command | Description |
|---------|-------------|
| `handle <sig> <opts>` | Control signal handling. |
| Options | `(no)print`, `(no)stop`, `(no)pass` |
| `signal <sig>` | Send signal to program. |

## Source & Disassembly

| Command | Description |
|---------|-------------|
| `dir <dir>` | Add source directory. |
| `l` | List code near RIP. |
| `l .` | Reset listing to RIP. |
| `l <func>` | List function source. |
| `l <file>:<line>` | List specific line. |
| `l <start>:<end>` | List a range. |
| `disas` | Disassemble code. |
| `disas/rm <addr>` | Disassemble with raw and mixed source. |
| `set listsize <n>` | Set number of lines per `list`. |

## Examining Memory

### Format Specifiers

| Format | Meaning |
|--------|---------|
| `x` | Hexadecimal |
| `d` | Signed decimal |
| `u` | Unsigned decimal |
| `o` | Octal |
| `t` | Binary |
| `a` | Address with symbol |
| `c` | Character constant |
| `f` | Floating-point |
| `s` | String |
| `z` | Hex with leading zeros |
| `r` | Raw formatting |

### Unit Sizes

| Unit | Size | Description |
|------|------|-------------|
| `b`  | 1 byte | Byte |
| `h`  | 2 bytes | Half-word |
| `w`  | 4 bytes | Word |
| `g`  | 8 bytes | Giant-word |

### Memory & Register Inspection

| Command | Description |
|---------|-------------|
| `x/<n><fmt><unit> <addr>` | Examine memory. |
| `x/<n>i <addr>` | View instructions. |
| `i r` | Info registers. |
| `p/x $rax` | Print value. |
| `whatis <var>` | Show variable type. |
| `ptype <expr>` | Show detailed type. |
| `show <value>` | Display settings. |
| `disp/16i $rsp` | Auto display memory every stop. |
| `i disp` | List display settings. |
| `undisp <num>` | Remove display. |

## Stack & Frames

| Command | Description |
|---------|-------------|
| `bt`, `where` | Show call stack. |
| `bt full` | Show call stack with vars. |
| `frame <n>` | Change stack frame. |
| `info frame` | Show current frame info. |
| `up <n>` / `down <n>` | Navigate call frames. |
| `disp/10xg $rsp` | Stack display. |

## Modifying State

| Command | Description |
|---------|-------------|
| `set $reg = val` | Modify register. |
| `set {type}<addr> = val` | Modify memory. |

## Info

| Command | Description |
|---------|-------------|
| `info proc mappings` | Shows where segments are mapped in memory. |
| `info file` | Shows where the entry point is. |

## Preferences

```bash
set disassembler-options numeric
set disassembler-options no-aliases
```

---

## Sources

- [OpenSecurityTraining2 – Debuggers 1012: Introductory GDB](https://apps.p.ost2.fyi/learning/course/course-v1:OpenSecurityTraining2+Dbg1012_IntroGDB+2024_v1/home)
- [Marc Haisenko's GDB Cheat Sheet](https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf)
- [UTexas GDB Reference Card](https://users.ece.utexas.edu/~adnan/gdb-refcard.pdf)
