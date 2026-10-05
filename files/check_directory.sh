#!/bin/bash

# check_directory.sh
# Author: Omar Abdeen
# Created on: 2024-03-10

# comments can have an initial space or not, but MUST come after !/bash

#eligibility checks
if [ $# -le 0 ]; then
    echo "Usage: $0 <directory> [extension]"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Error: Directory '$1' not found."
    exit 1
fi

total_file_count=0
#if extension provided exists
if [ -n "$2" ]; then
    total_file_count=$(find "$1" -maxdepth 1 -type f -name "*.$2" | wc -l)
else
    total_file_count=$(find "$1" -maxdepth 1 -type f | wc -l)
fi

echo "Number of regular files in directory '$1':   $total_file_count"
