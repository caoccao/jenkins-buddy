#!/bin/sh
set -eu

find "Jenkins Buddy" -name '*.swift' -type f -print0 | while IFS= read -r -d '' source_file; do
    line_count=$(wc -l < "$source_file" | tr -d ' ')
    if [ "$line_count" -gt 500 ]; then
        echo "$source_file exceeds 500 lines ($line_count)"
        exit 1
    fi
done
