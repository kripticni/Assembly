#!/usr/bin/env bash
cd "$HOME/Assembly" || exit #root dir of your project for cd
find ./src -print0 -type f | xargs --null -I{} ./scripts/build.sh {}
