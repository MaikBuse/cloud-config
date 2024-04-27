#!/bin/bash

terraform output --raw kubeconfig >cluster_kubeconfig.yaml

# Define source and destination directories
SOURCE_DIR="./secrets"
DEST_DIR="./helm/secrets"

# Loop through all .yaml files in the source directory
for file in "$SOURCE_DIR"/*.yaml; do
	# Extract the filename without the path
	filename=$(basename "$file")

	# Modify the filename by replacing 'secret' with 'sealed-secret'
	output_filename=$(echo "$filename" | sed 's/secret/sealed-secret/')

	# Define the full path for the output file
	output_file="$DEST_DIR/$output_filename"

	# Seal the secret and write the output
	kubeseal --kubeconfig cluster_kubeconfig.yaml --controller-name sealed-secrets --controller-namespace sealed-secrets \
		-f "$file" -w "$output_file"

	echo "Processed $file -> $output_file"
done

echo "All files processed."
