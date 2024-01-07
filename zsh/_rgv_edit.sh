#!/bin/bash
file=$(echo $1 | cut -d':' -f 1)
line=$(echo $1 | cut -d':' -f 2)
nvim "$file" "+${line}j"
