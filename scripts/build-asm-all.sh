#!/usr/bin/env bash
cd "$HOME/Assembly" || exit #root dir of your project for cd
find ./src/yt-courses -print0 -type f | xargs --null -I{} ./scripts/build.sh {}
find ./src/C-testing -print0 -type f | xargs --null -I{} ./scripts/build.sh {}
