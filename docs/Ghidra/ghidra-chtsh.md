# Ghidra

## Loading

| Action           | Key         | Menu -> Path               |
|------------------|-------------|-----------------------------|
| New Project      | Ctrl + N    | File -> New Project         |
| Open Project     | Ctrl + O    | File -> Open Project        |
| Close Project    | Ctrl + W    | File -> Close Project       |
| Save Project     | Ctrl + S    | File -> Save Project        |
| Import File      | I           | File -> Import File         |
| Export Program   | O           | File -> Export Project      |
| Open FileSystem  | Ctrl + I    | File -> Open File System    |

## Help/Info

| Action         | Key | Menu -> Path                  |
|----------------|-----|-------------------------------|
| Help           | F1  | Help -> Contents              |
| About          |     | Help -> About Ghidra          |
| About Program  |     | Help -> About Program name    |
| Preferences    |     | Edit -> Tool Options          |

## Windows

| Action               | Key       | Menu -> Path                          |
|----------------------|-----------|---------------------------------------|
| Bookmarks            | Ctrl+B    | Window → Bookmarks                    |
| Byte Viewer          |           | Window → Bytes: program name          |
| Function Call Trees  |           |                                       |
| Data Types           |           | Window → Data Type Manager            |
| Decompiler           | Ctrl+E    | Window → Decompile: function name     |
| Function Graph       |           | Window → Function Graph               |
| Script Manager       |           | Window → Script Manager               |
| Memory Map           |           | Window → Memory Map                   |
| Register Values      | V         | Window → Register Manager             |
| Symbol Table         |           | Window → Symbol Table                 |
| Symbol References    |           | Window → Symbol References            |
| Symbol Tree          |           | Window → Symbol Tree                  |

## Markup

| Action               | Key            | Menu -> Path                                    |
|----------------------|----------------|-------------------------------------------------|
| Undo                 | Ctrl+Z         | Edit → Undo                                     |
| Redo                 | Ctrl+Shift+Z   | Edit → Redo                                     |
| Save Program         | Ctrl+S         | File → Save program name                        |
| Disassemble          | D              | Context Menu → Disassemble                      |
| Clear Code/Data      | C              | Context Menu → Clear Code Bytes                 |
| Add Label            | L              | Context Menu → Add Label                        |
| Edit Label           | L              | Context Menu → Edit Label                       |
| Rename Function      | L              | Context Menu → Function → Rename Function       |
| Remove Label         | Del            | Context Menu → Remove Label                     |
| Remove Function      | Del            | Context Menu → Function → Delete Function       |
| Define Data          | T              | Context Menu → Data → Choose Data Type          |
| Repeat Define Data   | Y              | Context Menu → Data → Last Used: type           |
| Rename Variable      | L              | Context Menu → Rename Variable                  |
| Retype Variable      | Ctrl+L         | Context Menu → Retype Variable                  |
| Cycle Integer Types  | B              | Context Menu → Data → Cycle → byte, word, dword, qword |
| Cycle String Types   | '              | Context Menu → Data → Cycle → char, string, unicode |
| Cycle Float Types    | F              | Context Menu → Data → Cycle → float, double     |
| Create Array2        | [              | Context Menu → Data → Create Array              |
| Create Pointer2      | P              | Context Menu → Data → pointer                   |
| Create Structure     | Shift+[        | Context Menu → Data → Create Structure          |
| New Structure        |                | Context Menu → New → Structure                  |
| Import C Header      |                | File → Parse C Source                           |
| Cross References     |                | Context Menu → References → Show References to context |

## Search

| Action              | Key            | Menu -> Path              |
|---------------------|----------------|---------------------------|
| Search Memory       | S              | Search → Memory           |
| Search Program Text | Ctrl+Shift+E   | Search → Program Text     |
| Search For ...      |                | Search → For what         |

## Customize

| Action            | Key  | Menu -> Path                                 |
|-------------------|------|----------------------------------------------|
| Set Key Binding   | F4   | Edit -> Tool Options -> Key Bindings         |
| Processor Manual  |      | Context Menu -> Processor Manual             |

## Misc.

| Action          | Key              | Menu -> Path                        |
|-----------------|------------------|-------------------------------------|
| Select          |                  | Select -> *what                     |
| Program Diff    | 2                | Tools -> Program Differences        |
| Rerun Script    | Ctrl + Shift + R |                                     |
| Assemble        | Ctrl + Shift + G | Context Menu -> Patch Instruction   |

## Source

[https://ghidra-sre.org/CheatSheet.html](https://ghidra-sre.org/CheatSheet.html)
