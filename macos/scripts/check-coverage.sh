#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <result.xcresult>" >&2
    exit 2
fi

result_path=$1
minimum_percent=90

if [ ! -d "$result_path" ]; then
    echo "coverage result does not exist: $result_path" >&2
    exit 2
fi

coverage_line=$(xcrun xccov view --report --only-targets "$result_path" | awk '/Jenkins Buddy.app/ { print $NF }')
covered_lines=$(printf '%s\n' "$coverage_line" | sed -E 's/.*\(([0-9]+)\/([0-9]+)\).*/\1/')
executable_lines=$(printf '%s\n' "$coverage_line" | sed -E 's/.*\(([0-9]+)\/([0-9]+)\).*/\2/')

if [ -z "$covered_lines" ] || [ -z "$executable_lines" ] || [ "$executable_lines" -eq 0 ]; then
    echo "unable to read Jenkins Buddy coverage from $result_path" >&2
    exit 2
fi

coverage_percent=$(awk -v covered="$covered_lines" -v executable="$executable_lines" 'BEGIN { printf "%.2f", covered * 100 / executable }')
passes=$(awk -v coverage="$coverage_percent" -v minimum="$minimum_percent" 'BEGIN { print (coverage >= minimum ? "yes" : "no") }')

echo "Jenkins Buddy coverage: $coverage_percent% ($covered_lines/$executable_lines)"
if [ "$passes" != "yes" ]; then
    echo "coverage is below the required $minimum_percent%" >&2
    exit 1
fi
