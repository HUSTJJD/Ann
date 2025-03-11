#!/bin/bash

files=$(git status --porcelain | awk '/\.lua$/ {print $2}')

if [ -z "$files" ]; then
    exit 0
fi

echo "$files" | while read -r file; do
    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        continue
    fi
    Tools/GitHook/stylua "$file"
    Tools/GitHook/luacheck "$file"
    ret="$?"
    if [ "$ret" != 0 ]; then
        exit 1
    fi

done