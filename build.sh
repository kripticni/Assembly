#!/usr/bin/env bash

set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <filename.asm>"
  exit 1
fi

clean_name=$(basename "$1" | awk -F. '{print $1}')
nasm -f elf64 "$1" -o "$HOME"/Assembly-Dasm/obj/"$clean_name.o"
ld "$HOME"/Assembly-Dasm/obj/"$clean_name.o" -o "$HOME"/Assembly-Dasm/elf/"$clean_name"
objdump -d -M intel "$HOME"/Assembly-Dasm/elf/"$clean_name" > "$HOME"/Assembly-Dasm/disassembled/"$clean_name.dasm"

nasm -f elf64 -g -F dwarf "$1" -o "$HOME"/Assembly-Dasm/debug/obj/"$clean_name.o"
ld "$HOME"/Assembly-Dasm/debug/obj/"$clean_name.o" -o "$HOME"/Assembly-Dasm/debug/dwarf/"$clean_name"

rsync -u "$1" "$HOME"/Assembly-Dasm/asm/
