#!/bin/bash
file=$(echo $1 | cut -d':' -f 1)
line=$(echo $1 | cut -d':' -f 2)
range=$(awk "BEGIN { s = $line - 20; print((s < 0 ? 0 : s) \":\")}")
bat --style=numbers --color=always -H "$line" -r "$range" "$file"
