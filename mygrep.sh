#!/bin/bash

# Show help if --help is passed
if [[ "$1" == "--help" ]]; then
    echo "Usage: ./mygrep.sh [-n] [-v] search_string filename"
    echo "Options:"
    echo "  -n    Show line numbers"
    echo "  -v    Invert match (show lines that do NOT match)"
    exit 0
fi

# Initialize option flags
show_line_numbers=false
invert_match=false

# Parse options using getopts
while getopts "nv" opt; do
    case "$opt" in
        n) show_line_numbers=true ;;
        v) invert_match=true ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done

# Shift parsed options
shift $((OPTIND -1))

# Now, $1 is search string, $2 is filename
search_string="$1"
filename="$2"

# Error handling
if [[ -z "$search_string" || -z "$filename" ]]; then
    echo "Error: Missing search string or filename."
    echo "Usage: ./mygrep.sh [-n] [-v] search_string filename"
    exit 1
fi

if [[ ! -f "$filename" ]]; then
    echo "Error: File '$filename' not found."
    exit 1
fi

# Search logic
line_number=0

while IFS= read -r line
do
    ((line_number++))
    
    # Check match (case-insensitive)
    if echo "$line" | grep -iq "$search_string"; then
        matched=true
    else
        matched=false
    fi

    # Invert match if -v is set
    if $invert_match; then
        matched=$(! $matched && echo true || echo false)
    fi

    if $matched; then
        if $show_line_numbers; then
            echo "${line_number}:$line"
        else
            echo "$line"
        fi
    fi
done < "$filename"
