#!/bin/bash

# text_to_array.sh
# Author: Omar Abdeen
# Created on: 2024-03-10
# Needs bash for the array and [[ ]], so run it as ./text_to_array.sh or bash text_to_array.sh, not with sh


# check if filename is entered and if its readable
if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
elif [ ! -f "$1" ]; then
    echo "Error: File '$1' not found."
    exit 1
fi

word_array=()
curr_word=""

#char reading loop
while IFS= read -r -n1 char; do
    # letters and numbers build the current word. quotes around $char, a bare space would break the test
    if [[ "$char" =~ [[:alnum:]] ]]; then
        curr_word+="$char"
    # a space, a newline (read gives an empty char) or punctuation ends the word, and isn't added itself
    elif [ -n "$curr_word" ]; then
        word_array+=("$curr_word")
        curr_word=""
    fi
done < "$1"

# the last word, when the file doesn't end with a space or newline
if [ -n "$curr_word" ]; then
    word_array+=("$curr_word")
fi

echo "Array elements:"
for word in "${word_array[@]}"; do
    echo "$word"
done
