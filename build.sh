#!/usr/bin/env bash

set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <filename.asm>"
  exit 1
fi

clean_name=$(echo "$1" | awk -F. '{print $1}')
nasm -f elf64 "$1" -o "$HOME"/Assembly/obj/"$clean_name.o"
ld "$HOME"/Assembly/obj/"$clean_name.o" -o "$HOME"/Assembly/elf/"$clean_name"
objdump -d "$HOME"/Assembly/elf/"$clean_name" > "$HOME"/Assembly/disassembled/"$clean_name.dasm"

nasm -f elf64 -g -F dwarf "$1" -o "$HOME"/Assembly/debug/obj/"$clean_name.o"
ld "$HOME"/Assembly/debug/obj/"$clean_name.o" -o "$HOME"/Assembly/debug/dwarf/"$clean_name"

cp "$1" "$HOME"/Assembly/asm/
