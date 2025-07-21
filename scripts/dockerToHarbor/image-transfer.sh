#!/bin/bash

# Docker Image Transfer Script
# Transfers images from source registry to private registry (Harbor)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SOURCE_REGISTRY=""
TARGET_REGISTRY=""
USERNAME=""
PASSWORD=""
PROJECT=""
IMAGES_FILE=""
SINGLE_IMAGE=""
TAG_PATTERN="latest"
DRY_RUN=false
VERBOSE=false

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Transfer Docker images from source registry to private registry (Harbor)

OPTIONS:
    -s, --source-registry    Source registry URL (e.g., docker.io, gcr.io)
    -t, --target-registry    Target registry URL (e.g., harbor.example.com)
    -u, --username          Username for target registry
    -p, --password          Password for target registry
    -P, --project           Project name in target registry
    -i, --image             Single image to transfer (format: image:tag)
    -f, --file              File containing list of images to transfer
    -T, --tag-pattern       Tag pattern to transfer (default: latest)
    -d, --dry-run           Show what would be transferred without actually doing it
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

EXAMPLES:
    # Transfer single image
    $0 -s docker.io -t http://172.0.0.3:30002 -u admin -p password -P myproject -i nginx:1.20

    # Transfer multiple images from file
    $0 -s docker.io -t http://172.0.0.3:30002 -u admin -p password -P myproject -f images.txt

    # Transfer with tag pattern
    $0 -s gcr.io -t http://172.0.0.3:30002 -u admin -p password -P myproject -i myapp -T "v*"

    # Dry run to see what would be transferred
    $0 -s docker.io -t http://172.0.0.3:30002 -u admin -p password -P myproject -f images.txt -d

IMAGE FILE FORMAT:
    Each line should contain one image in format: image:tag or just image (will use tag-pattern)
    Examples:
        nginx:1.20
        redis:6.2
        postgres
        myapp:v1.0.0

EOF
}

# Function to parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--source-registry)
                SOURCE_REGISTRY="$2"
                shift 2
                ;;
            -t|--target-registry)
                TARGET_REGISTRY="$2"
                shift 2
                ;;
            -u|--username)
                USERNAME="$2"
                shift 2
                ;;
            -p|--password)
                PASSWORD="$2"
                shift 2
                ;;
            -P|--project)
                PROJECT="$2"
                shift 2
                ;;
            -i|--image)
                SINGLE_IMAGE="$2"
                shift 2
                ;;
            -f|--file)
                IMAGES_FILE="$2"
                shift 2
                ;;
            -T|--tag-pattern)
                TAG_PATTERN="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Function to validate inputs
validate_inputs() {
    local errors=0

    if [[ -z "$SOURCE_REGISTRY" ]]; then
        print_error "Source registry is required"
        errors=$((errors + 1))
    fi

    if [[ -z "$TARGET_REGISTRY" ]]; then
        print_error "Target registry is required"
        errors=$((errors + 1))
    fi

    if [[ -z "$USERNAME" ]]; then
        print_error "Username is required"
        errors=$((errors + 1))
    fi

    if [[ -z "$PASSWORD" ]]; then
        print_error "Password is required"
        errors=$((errors + 1))
    fi

    if [[ -z "$PROJECT" ]]; then
        print_error "Project name is required"
        errors=$((errors + 1))
    fi

    if [[ -z "$SINGLE_IMAGE" && -z "$IMAGES_FILE" ]]; then
        print_error "Either single image (-i) or images file (-f) is required"
        errors=$((errors + 1))
    fi

    if [[ -n "$IMAGES_FILE" && ! -f "$IMAGES_FILE" ]]; then
        print_error "Images file '$IMAGES_FILE' does not exist"
        errors=$((errors + 1))
    fi

    if [[ $errors -gt 0 ]]; then
        print_error "Please fix the above errors"
        exit 1
    fi
}

# Function to login to registries
login_registries() {
    print_info "Logging into target registry: $TARGET_REGISTRY"

    if [[ $DRY_RUN == false ]]; then
        echo "$PASSWORD" | docker login "$TARGET_REGISTRY" --username "$USERNAME" --password-stdin
        if [[ $? -eq 0 ]]; then
            print_success "Successfully logged into $TARGET_REGISTRY"
        else
            print_error "Failed to login to $TARGET_REGISTRY"
            exit 1
        fi
    else
        print_info "DRY RUN: Would login to $TARGET_REGISTRY"
    fi
}

# Function to process a single image
process_image() {
    local image="$1"
    local source_image=""
    local target_image=""

    # Parse image and tag
    if [[ "$image" == *":"* ]]; then
        source_image="$image"
    else
        source_image="$image:$TAG_PATTERN"
    fi

    # Add source registry if not already present
    if [[ "$SOURCE_REGISTRY" != "docker.io" && "$source_image" != *"$SOURCE_REGISTRY"* ]]; then
        source_image="$SOURCE_REGISTRY/$source_image"
    fi

    # Create target image name
    local image_name=$(echo "$source_image" | sed "s|.*\/||" | sed "s|$SOURCE_REGISTRY/||") # Remove registry prefix like docker.io or gcr.io
    local registry_no_proto=$(echo "$TARGET_REGISTRY" | sed -E 's|^https?://||')
    target_image="$registry_no_proto/$PROJECT/$image_name"

    print_info "Processing: $source_image -> $target_image"

    if [[ $DRY_RUN == true ]]; then
        print_info "DRY RUN: Would transfer $source_image to $target_image"
        return 0
    fi

    # Pull source image
    print_info "Pulling source image: $source_image"
    if [[ $VERBOSE == true ]]; then
        docker pull "$source_image"
    else
        docker pull "$source_image" > /dev/null 2>&1
    fi

    if [[ $? -ne 0 ]]; then
        print_error "Failed to pull $source_image"
        return 1
    fi

    # Tag for target registry
    print_info "Tagging image for target registry"
    docker tag "$source_image" "$target_image"

    # Push to target registry
    print_info "Pushing to target registry: $target_image"
    if [[ $VERBOSE == true ]]; then
        docker push "$target_image"
    else
        docker push "$target_image" > /dev/null 2>&1
    fi

    if [[ $? -eq 0 ]]; then
        print_success "Successfully transferred: $target_image"
    else
        print_error "Failed to push $target_image"
        return 1
    fi

    # Clean up local images
    # docker rmi "$source_image" "$target_image" > /dev/null 2>&1

    return 0
}

# Function to process multiple images from file
process_images_from_file() {
    local file="$1"
    local total=0
    local success=0
    local failed=0

    print_info "Processing images from file: $file"

    # Check if file exists
    if [[ ! -f "$file" ]]; then
        print_error "File '$file' does not exist"
        exit 1
    fi

    # Read file line by line
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue

        total=$((total + 1))

        if process_image "$line"; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
        fi

        echo "---"
    done < "$file"

    print_info "Transfer Summary:"
    print_info "Total images: $total"
    print_success "Successful: $success"

    if [[ $failed -gt 0 ]]; then
        print_error "Failed: $failed"
    fi
}

# Function to cleanup on exit
cleanup() {
    if [[ $DRY_RUN == false ]]; then
        print_info "Logging out of registries"
        docker logout "$TARGET_REGISTRY" > /dev/null 2>&1
    fi
}

# Main function
main() {
    print_info "Starting Docker image transfer"

    # Parse command line arguments
    parse_args "$@"

    # Validate inputs
    validate_inputs

    # Set up cleanup trap
    trap cleanup EXIT

    # Login to registries
    login_registries

    # Process images
    if [[ -n "$SINGLE_IMAGE" ]]; then
        process_image "$SINGLE_IMAGE"
    elif [[ -n "$IMAGES_FILE" ]]; then
        process_images_from_file "$IMAGES_FILE"
    fi

    print_success "Image transfer completed"
}

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Run main function
main "$@"