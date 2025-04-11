#!/usr/bin/env bash
#SPECIFY THE PROJECT ROOT DIR HERE
DIR=$HOME/Assembly

set -e

command -v gcc >/dev/null 2>&1 || {
  echo "nasm is required but not installed."
  exit 1
}
command -v objdump >/dev/null 2>&1 || {
  echo "objdump is required but not installed."
  exit 1
}

echo "Required commands exist, now building $1"

mkdir -p "$DIR/bin/obj" \
  "$DIR/bin" \
  "$DIR/debug/disasm" \
  "$DIR/debug/obj" \
  "$DIR/debug/dwarf" \
  "$DIR/src"

relative_path=$(dirname "$(realpath --relative-to="$DIR" "$(pwd)/$1")")
relative_path=${relative_path#*/}
clean_name=$(basename "$1" | awk -F. '{print $1}')

mkdir -p "$DIR/bin/obj/$relative_path" \
  "$DIR/bin/$relative_path" \
  "$DIR/debug/disasm/$relative_path" \
  "$DIR/debug/obj/$relative_path" \
  "$DIR/debug/dwarf/$relative_path" \
  "$DIR/src/$relative_path"

echo "Ensured the subdirectories exist"
echo "$relative_path/$clean_name"

gcc -c "$1" -O2 -o "$DIR/bin/obj/$relative_path/$clean_name.o"
gcc "$1" -Wall -O2 -o "$DIR/bin/$relative_path/$clean_name"
objdump -d -M intel "$DIR/bin/$relative_path/$clean_name" >"$DIR/debug/disasm/$relative_path/$clean_name.disasm"

gcc -c -g "$1" -O0 -o "$DIR/debug/obj/$relative_path/$clean_name.o"
gcc -Wall -g "$1" -O0 -o "$DIR/debug/dwarf/$relative_path/$clean_name"

rsync -u "$1" "$DIR/src/$relative_path"

echo "Completed and synced"
