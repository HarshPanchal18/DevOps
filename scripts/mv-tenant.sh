#!/bin/bash

# Script to move buckets from one MinIO tenant to another using MinIO Client (mc)

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Move buckets from one MinIO tenant to another using MinIO Client (mc)"
    echo "Usage: $0 <SOURCE-TENANT> <DESTINATION-TENANT>"
    exit 1
fi

echo "Tenant $1's buckets"
mc ls $1 | awk '{print $4 $5}'

for bucket in $(mc ls $1 | awk '{print $5}'); do
    mc mb $2/$bucket --ignore-existing
    mc mv $1/$bucket $2/$bucket --recursive
    echo "Moved $1/$bucket..."
done

# echo "All buckets moved from $1 to $2."

echo "Verifying the move..."

echo "Tenant $1's buckets"
mc ls $1 | awk '{print $5}'

echo "Tenant $2's buckets"
mc ls $2 | awk '{print $5}'

# Asking for confirmation to delete old buckets
echo "Do you want to delete the old buckets from $1? (yes/no)"
read -r confirmation
if [ "$confirmation" == "yes" ]; then
    for bucket in $(mc ls $1 | awk '{print $5}'); do
        mc rb --force $1/$bucket
        echo "Deleted old bucket $1/$bucket..."
    done
else
    echo "Old buckets from $1 are retained."
fi

echo "Please verify the data integrity after the move."
echo "Operation completed successfully."
exit 0

# Installation commands for mc
# curl --progress-bar -L https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o $HOME/minio-binaries/mc
# chmod +x ~/minio-binaries/mc
# ~/minio-binaries/mc --help
# mv ~/minio-binaries/mc /usr/local/bin/mc