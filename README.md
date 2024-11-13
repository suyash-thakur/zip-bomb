 ⚠️ **WARNING: This is for educational purposes only!** ⚠️

# Zip Bomb Implementation

This repository demonstrates zip bombs to help understand compression, recursive archives, and potential security implications.

## What is a Zip Bomb?

A zip bomb (also known as a zip of death or decompression bomb) is a malicious archive file designed to crash or render useless the system attempting to process it. It is a small file that, when decompressed, consumes excessive system resources (disk space, memory, CPU), potentially causing a denial of service.

## How Compression Works

Compression works by finding and eliminating redundancy in data. For example:
- Instead of storing "AAAAAAAAAA", we can store "10A" (meaning "10 times A")
- The string "ABCABCABC" could be stored as "3(ABC)"

Common compression algorithms:
1. **DEFLATE** (used in ZIP): Combines LZ77 and Huffman coding
2. **BZIP2**: Uses Burrows-Wheeler transform and Huffman coding
3. **GZIP**: Similar to DEFLATE but with different headers

### Example of High Compression
A file containing 1GB of zeros might compress to just a few kilobytes because it's highly repetitive:

```text
Original: 000000000000... (1GB of zeros)
Compressed: "1GB of 0" (few bytes)
```

## Types of Zip Bombs

### 1. Flat Zip Bomb
A flat zip bomb contains multiple compressed files that decompress to the same data.

#### How it works:

```
archive.zip (1MB)
├── file1.txt (100MB of zeros)
├── file2.txt (100MB of zeros)
├── file3.txt (100MB of zeros)
...
└── file100.txt (100MB of zeros)
```

- Total compressed size: ~1MB
- Decompressed size: 10GB (100 files × 100MB)
- Compression ratio: 1:10000

### 2. Nested Zip Bomb
A nested zip bomb contains archives within archives, creating an exponential growth pattern.

#### Layer structure:
```
layer3.zip
├── dummy.txt (100MB)
├── copy1_layer2.zip
│   ├── dummy.txt (100MB)
│   ├── copy1_layer1.zip
│   │   └── dummy.txt (100MB)
│   ├── copy2_layer1.zip
│   │   └── dummy.txt (100MB)
│   └── copy3_layer1.zip
│       └── dummy.txt (100MB)
├── copy2_layer2.zip
│   └── [same structure as copy1]
└── copy3_layer2.zip
    └── [same structure as copy1]
```

#### Size calculation:
- Layer 1: 100MB
- Layer 2: 300MB (3 × 100MB)
- Layer 3: 900MB (3 × 300MB)
- Layer 4: 2.7GB (3 × 900MB)
- And so on...

The size grows exponentially: Size = 100MB × 3^(layers-1)

## Security Implications

Zip bombs are often used to:
1. Crash antivirus software for further malware delivery
2. Cause denial of service attacks on systems
3. Overwhelm file upload services and parsers
4. Attack backup systems to corrupt archives
5. Disrupt automated file processing pipelines
6. Target continuous integration/deployment systems
7. Exploit web application file handlers
8. Attack document management systems

Modern systems protect against zip bombs by:
- Checking compression ratios
- Limiting recursive depth
- Scanning without full decompression
- Setting resource limits



## Target Systems Analysis

### Nested Zip Bomb Targets
The nested implementation (`nested_zip_bomb.sh`) is particularly effective against:

1. **Recursive Scanners**
   - Antivirus software that scans archive contents
   - File indexers that process nested archives
   - Document management systems

2. **Systems with Limited Memory**
   - Each layer requires additional memory to process
   - Memory usage grows exponentially with depth
   - Can cause out-of-memory errors

3. **Impact Characteristics**
   - Slower to process (must extract each layer)
   - Higher CPU usage due to multiple decompression steps
   - Can trigger recursion limits in scanning software

### Flat Zip Bomb Targets
The flat implementation (`flat_zip_bomb.sh`) is more effective against:

1. **Storage Systems**
   - Backup systems
   - File servers
   - Storage quotas
   - Cloud storage services

2. **Systems with Limited Disk Space**
   - Quick extraction to fill disk space
   - No recursion needed
   - Immediate impact on storage

3. **Impact Characteristics**
   - Faster extraction time
   - Lower CPU usage
   - Primary impact is on storage space

## Implementation Details

This repository contains two implementations:

### 1. Flat Zip Bomb (`flat_zip_bomb.sh`)
- Creates a single highly compressible file (zeros)
- Makes multiple references to the same compressed data
- Uses BZIP2 for maximum compression
- Example: 1GB of data in a 1MB archive

### 2. Nested Zip Bomb (`nested_zip_bomb.sh`)
- Creates nested layers of archives
- Each layer contains 3 copies of the previous layer
- Also uses BZIP2 for better compression
- Exponential growth with each layer

### Nested Zip Bomb Implementation (`nested_zip_bomb.sh`)
```bash
# Process flow:
1. Create 100MB zero file
2. Create hard links for requested copies
3. Compress all copies with bzip2
```

Key implementation features:
1. **Layered Structure**
   - Each layer contains a dummy file and previous layer copies
   - Uses temporary directories for layer construction
   - Cleans up intermediate files to save space

2. **Multiplication Effect**
   - Each layer triples the previous layer's size
   - Growth formula: 100MB × 3^(layers-1)
   - Example: 5 layers = 100MB × 3⁴ = 8.1GB

3. **Resource Management**
   - Uses temporary directories (`mktemp -d`)
   - Removes intermediate files after use
   - Maintains small working space during creation

### Flat Zip Bomb Implementation (`flat_zip_bomb.sh`)
```bash
# Process flow:
1. Create 100MB zero file
2. Create hard links for requested copies
3. Compress all copies with bzip2
```

Key implementation features:
1. **Layered Structure**
   - Each layer contains a dummy file and previous layer copies
   - Uses temporary directories for layer construction
   - Cleans up intermediate files to save space

2. **Multiplication Effect**
   - Each layer triples the previous layer's size
   - Growth formula: 100MB × 3^(layers-1)
   - Example: 5 layers = 100MB × 3⁴ = 8.1GB

3. **Resource Management**
   - Uses temporary directories (`mktemp -d`)
   - Removes intermediate files after use
   - Maintains small working space during creation


## Why BZIP2?

BZIP2 was chosen for this implementation for several reasons:

1. **Superior Compression Ratio**
   - BZIP2 uses the Burrows-Wheeler transform algorithm
   - Achieves better compression than DEFLATE (used in standard ZIP)
   - Particularly effective for repetitive data (like our zero-filled files)
   - Can achieve compression ratios up to 1:1000 or better

2. **Block-sorting Compression**
   - Processes data in blocks (900KB default)
   - Better at finding and eliminating repetitive patterns
   - More effective for large files with repeated content

3. **Resource Usage**
   - Uses more CPU and memory during compression/decompression
   - Higher resource usage amplifies the bomb effect
   - Makes the attack more effective against target systems

⚠️ **Note**: Both implementations use BZIP2's maximum compression (-9 flag) to achieve the highest possible compression ratios while maintaining the ability to extract the files successfully.

## Usage
```bash
# Create a flat zip bomb (2GB total size)
./flat_zip_bomb.sh 2000 bomb.tar.bz2

# Create a nested zip bomb (10 layers)
./nested_zip_bomb.sh 10 bomb.tar.bz2
```

## Performance Comparison

| Aspect | Nested Bomb | Flat Bomb |
|--------|-------------|-----------|
| Creation Time | Slower (multiple layers) | Faster (single layer) |
| Extraction Time | Slower (recursive) | Faster (single step) |
| CPU Impact | Higher | Lower |
| Memory Impact | Higher | Lower |
| Disk Impact | Gradual | Immediate |
| Compression Ratio | Very High | High |
| Detection Difficulty | Harder to detect | Easier to detect |


## Safety Notes

⚠️ **Important Safety Warnings:**
- Use only in controlled test environments
- Never use maliciously
- Ensure adequate disk space before testing
- May crash your system if not careful
- Some antivirus software may flag these files
- The code is not optimized or thoroughly tested. Use at your own risk!

## References
- [Wikipedia: Zip Bomb](https://en.wikipedia.org/wiki/Zip_bomb)
- [BZIP2 Compression](https://en.wikipedia.org/wiki/Bzip2)
- [42.zip Analysis](https://www.bamsoftware.com/hacks/zipbomb/)




