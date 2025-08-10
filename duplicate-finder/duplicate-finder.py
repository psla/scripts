import argparse
import hashlib
import json
import os
import sys

def calculate_hash(filepath, block_size=65536):
    """Calculates the SHA1 hash of a file."""
    sha1 = hashlib.sha1()
    with open(filepath, 'rb') as f:
        while True:
            data = f.read(block_size)
            if not data:
                break
            sha1.update(data)
    return sha1.hexdigest()

def create_hash_file(folder_paths, output_json):
    """
    Creates a JSON file with hashes for all files in the specified folders.
    """
    file_hashes = {}
    for folder_path in folder_paths:
        for dirpath, _, filenames in os.walk(folder_path):
            for filename in filenames:
                full_path = os.path.join(dirpath, filename)
                try:
                    file_hashes[full_path] = calculate_hash(full_path)
                except IOError as e:
                    print(f"Warning: Could not read file {full_path}. Skipping. Error: {e}", file=sys.stderr)
    
    with open(output_json, 'w') as f:
        json.dump(file_hashes, f, indent=4)
    print(f"Successfully created hash file at {output_json}")

def check_hashes(folder_paths, input_json):
    """
    Checks the hashes of files against a given JSON file.
    """
    try:
        with open(input_json, 'r') as f:
            reference_hashes = json.load(f)
    except FileNotFoundError:
        print(f"Error: JSON file not found at {input_json}", file=sys.stderr)
        return
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON format in file {input_json}", file=sys.stderr)
        return
        
    for folder_path in folder_paths:
        for dirpath, _, filenames in os.walk(folder_path):
            for filename in filenames:
                full_path = os.path.join(dirpath, filename)
                if full_path in reference_hashes:
                    try:
                        current_hash = calculate_hash(full_path)
                        if current_hash == reference_hashes[full_path]:
                            print(full_path)
                        else:
                            print(f"Warning: Hash mismatch for file {full_path}", file=sys.stderr)
                    except IOError as e:
                        print(f"Warning: Could not read file {full_path}. Skipping. Error: {e}", file=sys.stderr)
    
def main():
    parser = argparse.ArgumentParser(description="Calculate or check file hashes.")
    
    subparsers = parser.add_subparsers(dest='mode', required=True, help='Mode of operation')

    # Subparser for creating hash file
    create_parser = subparsers.add_parser('create', help='Create a JSON hash file.')
    create_parser.add_argument('folders', nargs='+', help='List of folders to hash.')
    create_parser.add_argument('--output', '-o', required=True, help='Output JSON file path.')

    # Subparser for checking hashes
    check_parser = subparsers.add_parser('check', help='Check hashes against a JSON file.')
    check_parser.add_argument('folders', nargs='+', help='List of folders to check.')
    check_parser.add_argument('--input', '-i', required=True, help='Input JSON file path with reference hashes.')

    args = parser.parse_args()

    if args.mode == 'create':
        create_hash_file(args.folders, args.output)
    elif args.mode == 'check':
        check_hashes(args.folders, args.input)

if __name__ == "__main__":
    main()
